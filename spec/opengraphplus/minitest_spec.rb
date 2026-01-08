# frozen_string_literal: true

require "opengraphplus/minitest"

RSpec.describe OpenGraphPlus::Minitest do
  # Create a test class that includes the Minitest assertions
  let(:test_instance) do
    Class.new do
      include OpenGraphPlus::Minitest

      # Mimic Minitest's assert and assert_equal methods
      def assert(condition, message = nil)
        raise AssertionError, message unless condition
      end

      def assert_equal(expected, actual, message = nil)
        raise AssertionError, message unless expected == actual
      end

      class AssertionError < StandardError; end
    end.new
  end

  let(:valid_html) do
    <<~HTML
      <html>
        <head>
          <meta property="og:title" content="My Title">
          <meta property="og:type" content="website">
          <meta property="og:image" content="https://example.com/image.png">
          <meta property="og:url" content="https://example.com">
        </head>
      </html>
    HTML
  end

  let(:invalid_html) do
    <<~HTML
      <html>
        <head>
          <meta property="og:title" content="My Title">
        </head>
      </html>
    HTML
  end

  describe "#assert_open_graph_tags" do
    it "passes when all required tags are present" do
      expect { test_instance.assert_open_graph_tags(valid_html) }.not_to raise_error
    end

    it "fails when required tags are missing" do
      expect {
        test_instance.assert_open_graph_tags(invalid_html)
      }.to raise_error(/missing: og:type, og:image, og:url/)
    end

    it "uses custom message when provided" do
      expect {
        test_instance.assert_open_graph_tags(invalid_html, "Custom message")
      }.to raise_error("Custom message")
    end
  end

  describe "#assert_og_tag" do
    it "passes when tag is present" do
      expect { test_instance.assert_og_tag(valid_html, "og:title") }.not_to raise_error
    end

    it "fails when tag is missing" do
      expect {
        test_instance.assert_og_tag(valid_html, "og:missing")
      }.to raise_error(/og:missing tag, but it was not found/)
    end

    it "passes when content matches" do
      expect { test_instance.assert_og_tag(valid_html, "og:title", "My Title") }.not_to raise_error
    end

    it "fails when content does not match" do
      expect {
        test_instance.assert_og_tag(valid_html, "og:title", "Wrong Title")
      }.to raise_error(/Expected og:title to have content "Wrong Title", but got "My Title"/)
    end

    it "uses custom message when provided" do
      expect {
        test_instance.assert_og_tag(valid_html, "og:missing", nil, "Custom message")
      }.to raise_error("Custom message")
    end
  end

  describe "#refute_og_tag" do
    it "passes when tag is missing" do
      expect { test_instance.refute_og_tag(valid_html, "og:missing") }.not_to raise_error
    end

    it "fails when tag is present" do
      expect {
        test_instance.refute_og_tag(valid_html, "og:title")
      }.to raise_error(/not to have og:title tag, but it was found/)
    end

    it "uses custom message when provided" do
      expect {
        test_instance.refute_og_tag(valid_html, "og:title", "Custom message")
      }.to raise_error("Custom message")
    end
  end
end
