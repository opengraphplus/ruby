# frozen_string_literal: true

require "active_support"
require "active_support/concern"

# Minimal mock of Rails controller behavior for testing
module ActionController
  class Base
    class << self
      def before_action(&block)
        before_actions << block
      end

      def before_actions
        @before_actions ||= []
      end

      def inherited(subclass)
        subclass.instance_variable_set(:@before_actions, before_actions.dup)
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
      self.class.before_actions.each { |action| instance_eval(&action) }
    end
  end
end

# Load controller after ActionController mock is defined
require_relative "../../lib/open_graph_plus/controller"

RSpec.describe OpenGraphPlus::Controller do
  let(:mock_request) { double("request", original_url: "https://example.com/test") }

  let(:base_controller_class) do
    Class.new(ActionController::Base) do
      include OpenGraphPlus::Controller

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
  end
end
