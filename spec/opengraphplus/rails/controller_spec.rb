# frozen_string_literal: true

require "action_controller"
require_relative "../../../lib/opengraphplus/rails/helper"
require_relative "../../../lib/opengraphplus/rails/controller"

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
    it "registers before_action callbacks" do
      callbacks = base_controller_class._process_action_callbacks.map(&:filter)
      expect(callbacks).to include(:set_default_open_graph_image)
    end

    it "child class inherits parent callbacks" do
      callbacks = child_controller_class._process_action_callbacks.map(&:filter)
      expect(callbacks).to include(:set_default_open_graph_image)
    end
  end

  describe "instance behavior" do
    def run_callbacks(controller, controller_class)
      controller.instance_variable_set(:@_request, mock_request)
      controller_class._process_action_callbacks.each do |callback|
        case callback.filter
        when Symbol
          controller.send(callback.filter)
        when Proc
          controller.instance_exec(&callback.filter)
        end
      end
    end

    it "sets open graph tags from class-level block" do
      controller = base_controller_class.new
      run_callbacks(controller, base_controller_class)

      expect(controller.open_graph.type).to eq("website")
      expect(controller.open_graph.url).to eq("https://example.com/test")
      expect(controller.open_graph.site_name).to eq("Test Site")
    end

    it "child class inherits and overrides parent tags" do
      controller = child_controller_class.new
      run_callbacks(controller, child_controller_class)

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

      controller = base_controller_class.new
      run_callbacks(controller, base_controller_class)

      expect(controller.open_graph.image.url).to start_with("https://opengraphplus.com/api/websites/v1/")
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

      controller = controller_class.new
      run_callbacks(controller, controller_class)

      expect(controller.open_graph.image.url).to eq("https://example.com/my-image.png")
    end
  end
end
