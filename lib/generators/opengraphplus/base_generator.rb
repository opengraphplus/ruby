# frozen_string_literal: true

require "rails/generators"

module Opengraphplus
  module Generators
    class BaseGenerator < Rails::Generators::Base
      API_KEY_PREFIX = "ogp_"

      argument :api_key, type: :string, required: true,
        desc: "Your OpenGraphPlus API key"

      def validate_api_key
        unless api_key.start_with?(API_KEY_PREFIX)
          say_status :error, "Invalid API key: must start with '#{API_KEY_PREFIX}'", :red
          raise SystemExit
        end
      end
    end
  end
end
