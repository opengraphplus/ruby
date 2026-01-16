# frozen_string_literal: true

require "uri"

module OpenGraphPlus
  module Signature
    class URL
      DEFAULT_BASE_URL = "https://opengraphplus.com"

      attr_reader :base_uri

      def initialize(base_url: nil)
        @base_uri = URI.parse(base_url || ENV.fetch("OGPLUS_URL", DEFAULT_BASE_URL))
      end

      def signed_path(prefix, api_key)
        SignedPath.new(prefix:, api_key:, base_uri:)
      end
    end

    class SignedPath
      attr_reader :prefix, :api_key, :base_uri

      def initialize(prefix:, api_key:, base_uri:)
        @prefix = prefix
        @api_key = api_key
        @base_uri = base_uri
      end

      def generator
        @generator ||= Generator.new(api_key)
      end

      def build(*segments, **params)
        signed_path = File.join("/", *segments.map(&:to_s))
        path_and_query = params.empty? ? signed_path : "#{signed_path}?#{URI.encode_www_form(params)}"
        signature = generator.generate(path_and_query)

        base_uri.dup.tap do |uri|
          uri.path = File.join(prefix, signature, *segments.map(&:to_s))
          uri.query = URI.encode_www_form(params) unless params.empty?
        end.to_s
      end
    end
  end
end
