# frozen_string_literal: true

require "opengraphplus"

module OpenGraphPlus
  module Minitest
    # Assert that all required OpenGraph tags are present
    #
    # @param html [String] The HTML to check
    # @param message [String, nil] Custom failure message
    #
    # @example
    #   assert_open_graph_tags(response.body)
    #
    def assert_open_graph_tags(html, message = nil)
      parser = OpenGraphPlus::Parser.new(html)
      message ||= "Expected HTML to have all required OpenGraph tags, but missing: #{parser.errors.join(', ')}"
      assert parser.valid?, message
    end

    # Assert that a specific OpenGraph/Twitter tag is present
    #
    # @param html [String] The HTML to check
    # @param property [String] The tag property (e.g., "og:title")
    # @param content [String, nil] Expected content (optional)
    # @param message [String, nil] Custom failure message
    #
    # @example
    #   assert_og_tag(response.body, "og:title")
    #   assert_og_tag(response.body, "og:title", "My Title")
    #
    def assert_og_tag(html, property, content = nil, message = nil)
      parser = OpenGraphPlus::Parser.new(html)
      actual_content = parser[property]

      if content.nil?
        message ||= "Expected HTML to have #{property} tag, but it was not found"
        assert !actual_content.nil?, message
      else
        message ||= "Expected #{property} to have content #{content.inspect}, but got #{actual_content.inspect}"
        assert_equal content, actual_content, message
      end
    end

    # Assert that a specific OpenGraph/Twitter tag is NOT present
    #
    # @param html [String] The HTML to check
    # @param property [String] The tag property (e.g., "og:title")
    # @param message [String, nil] Custom failure message
    #
    # @example
    #   refute_og_tag(response.body, "og:private")
    #
    def refute_og_tag(html, property, message = nil)
      parser = OpenGraphPlus::Parser.new(html)
      actual_content = parser[property]
      message ||= "Expected HTML not to have #{property} tag, but it was found with content #{actual_content.inspect}"
      assert actual_content.nil?, message
    end
  end
end
