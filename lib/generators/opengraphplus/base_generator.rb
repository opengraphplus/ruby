# frozen_string_literal: true

require "rails/generators"

module Opengraphplus
  module Generators
    class BaseGenerator < Rails::Generators::Base
      API_KEY_PREFIXES = %w[ogp_ ogplus_].freeze

      argument :api_key, type: :string, required: true,
        desc: "Your OpenGraphPlus API key"

      def validate_api_key
        unless API_KEY_PREFIXES.any? { |prefix| api_key.start_with?(prefix) }
          say_status :error, "Invalid API key: must start with '#{API_KEY_PREFIXES.join("' or '")}'", :red
          raise SystemExit
        end
      end
    end
  end
end
