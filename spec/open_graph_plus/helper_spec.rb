# frozen_string_literal: true

RSpec.describe OpenGraphPlus::Helper do
  let(:helper_class) do
    Class.new do
      include OpenGraphPlus::Helper

      attr_accessor :request

      def initialize(request = nil)
        @request = request
      end
    end
  end

  let(:mock_request) do
    double("request", original_url: "https://example.com/test")
  end

  let(:helper) { helper_class.new(mock_request) }

  after do
    OpenGraphPlus.reset_configuration!
  end

  describe "#open_graph" do
    it "returns a Tags::Root" do
      expect(helper.open_graph).to be_a(OpenGraphPlus::Tags::Root)
    end

    it "accepts keyword arguments" do
      helper.open_graph(title: "Test Title", description: "Test Description")

      expect(helper.open_graph.title).to eq("Test Title")
      expect(helper.open_graph.description).to eq("Test Description")
    end

    it "yields the Root when block given" do
      yielded = nil
      helper.open_graph do |og|
        yielded = og
      end

      expect(yielded).to be_a(OpenGraphPlus::Tags::Root)
    end

    it "returns the same Root on multiple calls" do
      root1 = helper.open_graph
      root2 = helper.open_graph
      expect(root1).to eq(root2)
    end
  end

  describe "#open_graph_tags" do
    it "returns an array of Tag objects" do
      helper.open_graph(title: "Test")
      expect(helper.open_graph_tags).to all(be_a(OpenGraphPlus::Tag))
    end
  end

  describe "#open_graph_meta_tags" do
    it "returns meta tags as a string" do
      helper.open_graph(title: "Test Title")

      result = helper.open_graph_meta_tags

      expect(result).to include('<meta property="og:title" content="Test Title">')
    end

    it "passes request URL for image generation" do
      OpenGraphPlus.configure { |c| c.api_key = "test_key" }

      result = helper.open_graph_meta_tags

      expect(result).to include("og:image")
      expect(result).to include("https%3A%2F%2Fexample.com%2Ftest")
    end

    context "when request is not defined" do
      let(:helper) { helper_class.new(nil) }

      it "works without request URL" do
        helper.open_graph(title: "Test")

        result = helper.open_graph_meta_tags

        expect(result).to include("og:title")
      end
    end

    context "when no open_graph was called" do
      it "returns meta tags with defaults" do
        result = helper.open_graph_meta_tags
        expect(result).to include("og:type")
      end
    end
  end
end
