# frozen_string_literal: true

require "uri"

module OpenGraphPlus
  module Signature
    class URL
      DEFAULT_BASE_URL = "https://opengraphplus.com"
      DEFAULT_PATH_PREFIX = "/v2/:signature"

      attr_reader :base_uri, :path_prefix

      def initialize(api_key: nil, generator: nil, base_url: nil, path_prefix: DEFAULT_PATH_PREFIX)
        @api_key = api_key
        @generator = generator
        @base_uri = URI.parse(base_url || ENV.fetch("OPENGRAPHPLUS_URL", DEFAULT_BASE_URL))
        @path_prefix = path_prefix
      end

      def build(path, **params)
        return nil unless generator

        path_and_query = build_path_and_query(path, params)
        signature = generator.generate(path_and_query)

        base_uri.dup.tap do |uri|
          uri.path = signed_path(signature, path)
          uri.query = URI.encode_www_form(params) unless params.empty?
        end.to_s
      end

      def generator
        @generator ||= begin
          api_key = @api_key || OpenGraphPlus.configuration.api_key
          if api_key
            Generator.new(api_key)
          else
            warn_missing_api_key
            nil
          end
        end
      end

      private

      def build_path_and_query(path, params)
        normalized_path = File.join("/", path)
        params.empty? ? normalized_path : "#{normalized_path}?#{URI.encode_www_form(params)}"
      end

      def signed_path(signature, path)
        File.join(path_prefix.gsub(":signature", signature), path)
      end

      def warn_missing_api_key
        return if @warned

        warn "[OpenGraphPlus] API key not configured. Set OpenGraphPlus.configuration.api_key to enable automatic Open Graph image generation."
        @warned = true
      end
    end
  end
end
