# frozen_string_literal: true

require "base64"
require "json"
require "securerandom"

module OpenGraphPlus
  class APIKey
    NAMESPACE = "ogplus"
    PUBLIC_KEY_PREFIX = "ogplus_pk_"
    SECRET_KEY_PREFIX = "ogplus_sk_"
    PUBLIC_KEY_BYTES = 16  # 22 characters when base64 encoded
    SECRET_KEY_BYTES = 32  # 43 characters when base64 encoded

    attr_reader :public_key, :secret_key, :environment

    def initialize(public_key:, secret_key:, environment: :live)
      @public_key = public_key
      @secret_key = secret_key
      @environment = environment.to_sym
    end

    def to_s
      { pk: public_key, sk: secret_key }
        .to_json
        .then { |json| Base64.urlsafe_encode64(json, padding: false) }
        .then { |payload| [NAMESPACE, environment, payload].join("_") }
    end

    def live?
      environment == :live
    end

    def test?
      environment == :test
    end

    def ==(other)
      other.is_a?(APIKey) &&
        public_key == other.public_key &&
        secret_key == other.secret_key &&
        environment == other.environment
    end

    class << self
      def generate(environment: :live)
        new(
          public_key: "#{PUBLIC_KEY_PREFIX}#{SecureRandom.urlsafe_base64(PUBLIC_KEY_BYTES)}",
          secret_key: "#{SECRET_KEY_PREFIX}#{SecureRandom.urlsafe_base64(SECRET_KEY_BYTES)}",
          environment:
        )
      end

      def parse(encoded_key)
        return nil unless encoded_key.is_a?(String)

        case encoded_key.split("_", 3)
        in [NAMESPACE, env, payload]
          payload
            .then { |p| Base64.urlsafe_decode64(p) }
            .then { |json| JSON.parse(json) }
            .then { |data| new(public_key: data["pk"], secret_key: data["sk"], environment: env) }
        else
          nil
        end
      rescue ArgumentError, JSON::ParserError
        nil
      end
    end
  end
end
