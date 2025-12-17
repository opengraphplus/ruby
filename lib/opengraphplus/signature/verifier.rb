# frozen_string_literal: true

require "openssl"
require "base64"

module OpenGraphPlus
  module Signature
    class Verifier
      attr_reader :signature, :path_and_query

      def initialize(signature:, path_and_query:)
        @signature = signature
        @path_and_query = path_and_query
      end

      def public_key
        parsed[:public_key]
      end

      def valid?(secret_key)
        expected_hmac = OpenSSL::HMAC.digest(DIGEST_ALGORITHM, secret_key, path_and_query)
        truncated_expected = expected_hmac.byteslice(0, HMAC_BYTES)
        actual_hmac = parsed[:hmac]

        secure_compare(truncated_expected, actual_hmac)
      end

      private

      def parsed
        @parsed ||= signature
          .then { |sig| Base64.urlsafe_decode64(sig) }
          .then { |decoded| decoded.split(":", 2) }
          .then { |public_key, hmac| { public_key: public_key, hmac: hmac } }
      rescue ArgumentError
        { public_key: nil, hmac: nil }
      end

      def secure_compare(a, b)
        return false if a.nil? || b.nil?
        return false if a.bytesize != b.bytesize

        OpenSSL.fixed_length_secure_compare(a, b)
      end
    end
  end
end
