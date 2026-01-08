# frozen_string_literal: true

require "rails/command"

module Rails
  module Command
    class OpengraphCommand < Base
      namespace "opengraph"

      desc "verify URL", "Verify OpenGraph tags at a URL"
      def verify(url)
        require "opengraphplus"

        say "Verifying OpenGraph tags at #{url}..."
        say ""

        begin
          parser = OpenGraphPlus::Verifier.new(url).verify
        rescue OpenGraphPlus::Verifier::FetchError => e
          say_error e.message
          exit 1
        end

        tags = parser.all_tags

        if tags.any?
          say "Found tags:"
          max_key_length = tags.keys.map(&:length).max
          tags.each do |property, content|
            say "  #{property.ljust(max_key_length)} → #{content.inspect}"
          end
          say ""
        else
          say "No OpenGraph or Twitter tags found."
          say ""
        end

        if parser.errors.any?
          say "Missing required tags:"
          parser.errors.each do |tag|
            say "  ✗ #{tag}"
          end
          say ""
        end

        if parser.warnings.any?
          say "Missing recommended tags:"
          parser.warnings.each do |tag|
            say "  - #{tag}"
          end
          say ""
        end

        if parser.valid?
          say "✓ All required OpenGraph tags present"
        else
          say "Verification failed: #{parser.errors.length} required tag(s) missing"
          exit 1
        end
      end
    end
  end
end
