# frozen_string_literal: true

require "active_support"
require "active_support/concern"
require_relative "../../../lib/opengraphplus/rails/helper"
require_relative "../../../lib/opengraphplus/rails/controller"

# Minimal mock of Rails controller behavior for testing
module ActionController
  class Base
    class << self
      def before_action(method_name = nil, &block)
        if block
          before_actions << block
        else
          before_actions << method_name
        end
      end

      def append_before_action(method_name = nil, &block)
        if block
          appended_before_actions << block
        else
          appended_before_actions << method_name
        end
      end

      def before_actions
        @before_actions ||= []
      end

      def appended_before_actions
        @appended_before_actions ||= []
      end

      def inherited(subclass)
        subclass.instance_variable_set(:@before_actions, before_actions.dup)
        subclass.instance_variable_set(:@appended_before_actions, appended_before_actions.dup)
      end

      def helper_method(*methods)
        # no-op for testing
      end
    end

    attr_accessor :request

    def initialize(request = nil)
      @request = request
    end

    def run_before_actions
      self.class.before_actions.each do |action|
        if action.is_a?(Symbol)
          send(action)
        else
          instance_eval(&action)
        end
      end
      self.class.appended_before_actions.each do |action|
        if action.is_a?(Symbol)
          send(action)
        else
          instance_eval(&action)
        end
      end
    end
  end
end

RSpec.describe OpenGraphPlus::Rails::Controller do
  let(:mock_request) { double("request", original_url: "https://example.com/test") }

  let(:base_controller_class) do
    Class.new(ActionController::Base) do
      include OpenGraphPlus::Rails::Controller

      open_graph do |og|
        og.type = "website"
        og.url = request.original_url
        og.site_name = "Test Site"
      end
    end
  end

  let(:child_controller_class) do
    Class.new(base_controller_class) do
      open_graph do |og|
        og.title = "Child Title"
        og.type = "article"
      end
    end
  end

  after do
    OpenGraphPlus.reset_configuration!
  end

  describe ".open_graph" do
    it "registers a before_action" do
      expect(base_controller_class.before_actions.size).to eq(1)
    end

    it "registers set_default_open_graph_image as appended before_action" do
      expect(base_controller_class.appended_before_actions).to eq([:set_default_open_graph_image])
    end

    it "child class inherits parent before_actions" do
      expect(child_controller_class.before_actions.size).to eq(2)
    end
  end

  describe "instance behavior" do
    it "sets open graph tags from class-level block" do
      controller = base_controller_class.new(mock_request)
      controller.run_before_actions

      expect(controller.open_graph.type).to eq("website")
      expect(controller.open_graph.url).to eq("https://example.com/test")
      expect(controller.open_graph.site_name).to eq("Test Site")
    end

    it "child class inherits and overrides parent tags" do
      controller = child_controller_class.new(mock_request)
      controller.run_before_actions

      # Inherited from parent
      expect(controller.open_graph.url).to eq("https://example.com/test")
      expect(controller.open_graph.site_name).to eq("Test Site")

      # Overridden by child
      expect(controller.open_graph.type).to eq("article")
      expect(controller.open_graph.title).to eq("Child Title")
    end

    it "sets default image URL when api_key is configured and no image set" do
      bundled_key = OpenGraphPlus::APIKey.new(public_key: "test_pk", secret_key: "test_sk").to_s
      OpenGraphPlus.configure do |config|
        config.api_key = bundled_key
      end

      controller = base_controller_class.new(mock_request)
      controller.run_before_actions

      expect(controller.open_graph.image.url).to start_with("https://opengraphplus.com/v2/")
      expect(controller.open_graph.image.url).to include("/opengraph?url=https%3A%2F%2Fexample.com%2Ftest")
    end

    it "does not override image URL if already set" do
      bundled_key = OpenGraphPlus::APIKey.new(public_key: "test_pk", secret_key: "test_sk").to_s
      OpenGraphPlus.configure do |config|
        config.api_key = bundled_key
      end

      controller_class = Class.new(ActionController::Base) do
        include OpenGraphPlus::Rails::Controller

        open_graph do |og|
          og.image_url = "https://example.com/my-image.png"
        end
      end

      controller = controller_class.new(mock_request)
      controller.run_before_actions

      expect(controller.open_graph.image.url).to eq("https://example.com/my-image.png")
    end
  end
end
