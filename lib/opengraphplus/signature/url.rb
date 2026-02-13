# frozen_string_literal: true

require "uri"

module OpenGraphPlus
  module Signature
    class URL
      attr_reader :base
      alias :base_url :base

      def initialize(url: OpenGraphPlus.configuration.url)
        @base = URI.parse(url)
      end

      def signed_path(prefix, api_key)
        SignedPath.new(prefix:, api_key:, base_url:)
      end
    end

    class SignedPath
      attr_reader :prefix, :api_key, :base_url

      def initialize(prefix:, api_key:, base_url:)
        @prefix = prefix
        @api_key = api_key
        @base_url = base_url
      end

      def generator
        @generator ||= Generator.new(api_key)
      end

      def build(*segments, **params)
        signed_path = File.join("/", *segments.map(&:to_s))
        path_and_query = params.empty? ? signed_path : "#{signed_path}?#{URI.encode_www_form(params)}"
        signature = generator.generate(path_and_query)

        base_url.dup.tap do |uri|
          uri.path = File.join(prefix, signature, *segments.map(&:to_s))
          uri.query = URI.encode_www_form(params) unless params.empty?
        end.to_s
      end
    end
  end
end
