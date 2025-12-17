# frozen_string_literal: true

require "rails"
require "action_controller/railtie"
require "rack/test"
require_relative "../../lib/opengraphplus"
require_relative "../../lib/opengraphplus/rails"

# Minimal Rails app for testing
class TestApp < Rails::Application
  config.eager_load = false
  config.secret_key_base = "test_secret_key_base_for_testing_only"
  config.hosts << "example.org"
  config.logger = Logger.new($stdout)
  config.log_level = :warn
end

TestApp.initialize!

# Test controller
class ScreenshotsController < ActionController::Base
  include OpenGraphPlus::Rails::Signature::Routes

  def show
    if signature_verifier&.public_key
      render plain: "public_key:#{signature_verifier.public_key}"
    else
      render plain: "no_verifier", status: :bad_request
    end
  end

  def verify
    api_key = OpenGraphPlus::APIKey.parse(ENV["TEST_API_KEY"])
    if signature_verifier&.public_key && signature_verifier.valid?(api_key.secret_key)
      render plain: "valid"
    else
      render plain: "invalid", status: :unauthorized
    end
  end
end

def draw_routes!
  TestApp.routes.draw do
    scope "signed/:signature", constraints: OpenGraphPlus::Rails::Signature::Scope.new do
      get "opengraph", to: "screenshots#show"
      get "verify", to: "screenshots#verify"
      get "some/nested/path", to: "screenshots#verify"
    end

    scope "custom/:token", constraints: OpenGraphPlus::Rails::Signature::Scope.new(param: :token) do
      get "image", to: "screenshots#show"
    end
  end
end

draw_routes!

RSpec.describe "SignedScope and SignedRoutes" do
  include Rack::Test::Methods

  def app
    TestApp
  end

  let(:api_key) { OpenGraphPlus::APIKey.generate }

  before do
    ENV["TEST_API_KEY"] = api_key.to_s
  end

  after do
    ENV.delete("TEST_API_KEY")
  end

  def generate_signature(path_and_query)
    OpenGraphPlus::Signature::Generator.new(api_key).generate(path_and_query)
  end

  describe "SignedScope" do
    it "extracts signature and sets up verifier" do
      signature = generate_signature("/opengraph?url=https://example.com")
      get "/signed/#{signature}/opengraph?url=https://example.com"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("public_key:#{api_key.public_key}")
    end

    it "handles missing signature gracefully" do
      get "/signed//opengraph"

      # Route won't match without signature segment
      expect(last_response.status).to eq(404)
    end

    it "works with custom param name" do
      signature = generate_signature("/image?url=https://example.com")
      get "/custom/#{signature}/image?url=https://example.com"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("public_key:#{api_key.public_key}")
    end

    it "builds correct path_and_query for verification" do
      path_and_query = "/opengraph?url=https://example.com"
      signature = generate_signature(path_and_query)
      get "/signed/#{signature}#{path_and_query}"

      expect(last_response.status).to eq(200)
    end

    it "handles paths with multiple segments" do
      path_and_query = "/some/nested/path?foo=bar&baz=qux"
      signature = generate_signature(path_and_query)

      get "/signed/#{signature}#{path_and_query}"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("valid")
    end
  end

  describe "SignedRoutes concern" do
    it "provides signature_verifier method" do
      signature = generate_signature("/opengraph?url=https://example.com")
      get "/signed/#{signature}/opengraph?url=https://example.com"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to include("public_key:")
    end

    it "verifier validates correct signatures" do
      signature = generate_signature("/verify?test=1")
      get "/signed/#{signature}/verify?test=1"

      expect(last_response.status).to eq(200)
      expect(last_response.body).to eq("valid")
    end

    it "verifier rejects tampered paths" do
      signature = generate_signature("/verify?test=1")
      get "/signed/#{signature}/verify?test=2"  # Changed query param

      expect(last_response.status).to eq(401)
      expect(last_response.body).to eq("invalid")
    end

    it "verifier rejects invalid signatures" do
      get "/signed/invalid_signature_here/verify?test=1"

      expect(last_response.status).to eq(401)
      expect(last_response.body).to eq("invalid")
    end
  end

  describe "URL generation consistency" do
    it "generates same signature for same input" do
      path_and_query = "/opengraph?url=https://example.com/page"
      sig1 = generate_signature(path_and_query)
      sig2 = generate_signature(path_and_query)

      expect(sig1).to eq(sig2)
    end

    it "generates different signatures for different inputs" do
      sig1 = generate_signature("/opengraph?url=https://example.com/page1")
      sig2 = generate_signature("/opengraph?url=https://example.com/page2")

      expect(sig1).not_to eq(sig2)
    end
  end
end
