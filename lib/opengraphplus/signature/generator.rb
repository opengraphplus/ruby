# frozen_string_literal: true

require "openssl"
require "base64"

module OpenGraphPlus
  module Signature
    class Generator
      attr_reader :api_key

      def initialize(api_key)
        @api_key = api_key
      end

      def generate(path_and_query)
        path_and_query
          .then { |data| OpenSSL::HMAC.digest(DIGEST_ALGORITHM, api_key.secret_key, data) }
          .then { |hmac| hmac.byteslice(0, HMAC_BYTES) }
          .then { |truncated| "#{api_key.public_key}:#{truncated}" }
          .then { |payload| Base64.urlsafe_encode64(payload, padding: false) }
      end
    end
  end
end
