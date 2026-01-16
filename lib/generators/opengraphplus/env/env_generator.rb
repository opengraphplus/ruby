# frozen_string_literal: true

require_relative "../base_generator"

module Opengraphplus
  module Generators
    class EnvGenerator < BaseGenerator
      source_root File.expand_path("templates", __dir__)

      desc "Configures OpenGraphPlus using environment variables"

      class_option :envfile, type: :string, aliases: "-e",
        desc: "Specific env file to write to (e.g., .env, .envrc)"

      ENV_FILES = %w[.env .env.local .env.development .env.development.local .envrc].freeze
      ENV_VAR_NAME = "OGPLUS__API_KEY"

      def append_to_env_file
        if options[:envfile]
          write_to_env_file(options[:envfile], create: true)
        else
          env_file = detect_env_file
          if env_file
            write_to_env_file(env_file)
          else
            say_status :skip, "No env file found (create one or use -e)", :yellow
          end
        end
      end

      def create_initializer
        template "initializer.rb.tt", "config/initializers/opengraphplus.rb"
      end

      private

      def detect_env_file
        ENV_FILES.find { |f| File.exist?(f) }
      end

      def write_to_env_file(env_file, create: false)
        env_line = "#{ENV_VAR_NAME}=#{api_key}"

        unless File.exist?(env_file)
          if create
            create_file env_file, "#{env_line}\n"
          end
          return
        end

        if File.read(env_file).include?(ENV_VAR_NAME)
          say_status :skip, "#{env_file} (#{ENV_VAR_NAME} already defined)", :yellow
        else
          content = File.read(env_file)
          prefix = content.end_with?("\n") || content.empty? ? "" : "\n"
          append_to_file env_file, "#{prefix}#{env_line}\n"
        end
      end
    end
  end
end
