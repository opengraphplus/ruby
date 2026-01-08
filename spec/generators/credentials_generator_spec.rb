# frozen_string_literal: true

require "spec_helper"
require "fileutils"
require "tmpdir"
require "generators/opengraphplus/credentials/credentials_generator"

RSpec.describe Opengraphplus::Generators::CredentialsGenerator do
  let(:tmpdir) { Dir.mktmpdir }
  let(:api_key) { "ogp_test_12345" }
  let(:credentials_double) { double(key?: true, read: "", write: nil) }
  let(:application_double) { double(credentials: credentials_double) }

  before do
    @original_dir = Dir.pwd
    Dir.chdir(tmpdir)
    FileUtils.mkdir_p("config/initializers")
    allow(Rails).to receive(:application).and_return(application_double)
  end

  after do
    Dir.chdir(@original_dir)
    FileUtils.rm_rf(tmpdir)
  end

  describe "API key validation" do
    it "accepts keys starting with ogp_" do
      expect { described_class.start([api_key], destination_root: tmpdir) }.not_to raise_error
    end

    it "rejects keys not starting with ogp_" do
      expect {
        described_class.start(["invalid_key"], destination_root: tmpdir)
      }.to raise_error(SystemExit)
    end
  end

  describe "initializer creation" do
    it "creates the initializer with credentials config" do
      described_class.start([api_key], destination_root: tmpdir)

      initializer = File.read("config/initializers/opengraphplus.rb")
      expect(initializer).to include("Rails.application.credentials.opengraphplus.api_key")
    end
  end

  describe "credentials modification" do
    it "writes the API key to credentials" do
      written_content = nil
      creds = double(key?: true, read: "secret_key_base: abc123\n")
      allow(creds).to receive(:write) { |content| written_content = content }
      allow(Rails).to receive(:application).and_return(double(credentials: creds))

      described_class.start([api_key], destination_root: tmpdir)

      expect(written_content).to include("opengraphplus")
      expect(written_content).to include("api_key")
      expect(written_content).to include(api_key)
    end

    it "preserves existing credentials" do
      written_content = nil
      creds = double(key?: true, read: "secret_key_base: abc123\naws:\n  access_key: xyz\n")
      allow(creds).to receive(:write) { |content| written_content = content }
      allow(Rails).to receive(:application).and_return(double(credentials: creds))

      described_class.start([api_key], destination_root: tmpdir)

      expect(written_content).to include("secret_key_base")
      expect(written_content).to include("aws")
      expect(written_content).to include("opengraphplus")
    end

    it "errors when no credentials key exists" do
      creds = double(key?: false)
      allow(Rails).to receive(:application).and_return(double(credentials: creds))

      expect {
        described_class.start([api_key], destination_root: tmpdir)
      }.to output(/No credentials key found/).to_stdout
    end
  end
end
