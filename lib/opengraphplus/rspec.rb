# frozen_string_literal: true

require "opengraphplus"
require "rspec/expectations"

module OpenGraphPlus
  module RSpec
    extend ::RSpec::Matchers::DSL

    # Matches if all required OpenGraph tags are present
    #
    # @example
    #   expect(response.body).to have_open_graph_tags
    #
    matcher :have_open_graph_tags do
      match do |html|
        @parser = OpenGraphPlus::Parser.new(html)
        @parser.valid?
      end

      failure_message do
        "expected HTML to have all required OpenGraph tags, but missing: #{@parser.errors.join(', ')}"
      end

      failure_message_when_negated do
        "expected HTML not to have all required OpenGraph tags, but all were present"
      end
    end

    # Matches if a specific OpenGraph/Twitter tag is present
    #
    # @example
    #   expect(response.body).to have_og_tag("og:title")
    #   expect(response.body).to have_og_tag("og:title").with_content("My Title")
    #
    matcher :have_og_tag do |property|
      chain :with_content do |expected_content|
        @expected_content = expected_content
      end

      match do |html|
        @parser = OpenGraphPlus::Parser.new(html)
        @actual_content = @parser[property]

        if @actual_content.nil?
          false
        elsif @expected_content
          @actual_content == @expected_content
        else
          true
        end
      end

      failure_message do
        if @actual_content.nil?
          "expected HTML to have #{property} tag, but it was not found"
        else
          "expected #{property} to have content #{@expected_content.inspect}, but got #{@actual_content.inspect}"
        end
      end

      failure_message_when_negated do
        if @expected_content
          "expected #{property} not to have content #{@expected_content.inspect}, but it did"
        else
          "expected HTML not to have #{property} tag, but it was found with content #{@actual_content.inspect}"
        end
      end
    end
  end
end

RSpec.configure do |config|
  config.include OpenGraphPlus::RSpec
end
