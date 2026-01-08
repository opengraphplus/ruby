# frozen_string_literal: true

require "yaml"
require "active_support/core_ext/hash/keys"
require_relative "../base_generator"

module Opengraphplus
  module Generators
    class CredentialsGenerator < BaseGenerator
      source_root File.expand_path("templates", __dir__)

      desc "Configures OpenGraphPlus using Rails encrypted credentials"

      def add_to_credentials
        credentials = Rails.application.credentials

        unless credentials.key?
          say_status :error, "No credentials key found. Run `rails credentials:edit` first.", :red
          return
        end

        # Read existing content, merge, write back
        yaml_content = credentials.read.presence || ""
        config = parse_yaml(yaml_content)

        config["opengraphplus"] ||= {}
        config["opengraphplus"]["api_key"] = api_key

        credentials.write(yaml_dump(config))
        say_status :insert, "credentials.yml.enc (opengraphplus.api_key)", :green
      end

      def create_initializer
        template "initializer.rb.tt", "config/initializers/opengraphplus.rb"
      end

      private

      def parse_yaml(content)
        return {} if content.blank?
        YAML.safe_load(content, permitted_classes: [Symbol], aliases: true) || {}
      end

      def yaml_dump(config)
        # Preserve nice formatting
        YAML.dump(config.deep_stringify_keys)
      end
    end
  end
end
