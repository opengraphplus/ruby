# frozen_string_literal: true

module OpenGraphPlus
  module Rails
    module Signature
      class Scope
        # Rails route constraint that sets up signature verification
        # for controller to handle. Always matches so controller can
        # decide how to handle errors (e.g., show fallback image).
        #
        # Usage in routes.rb:
        #   scope "signed/:signature", constraints: OpenGraphPlus::Rails::Signature::Scope.new do
        #     get "opengraph", to: "screenshots#show"
        #   end
        #
        # Then in controller:
        #   verifier = request.env["opengraphplus.verifier"]
        #   if verifier&.public_key
        #     api_key = ApiKey.find_by(public_key: verifier.public_key)
        #     if api_key && verifier.valid?(api_key.secret_key)
        #       # success
        #     else
        #       # invalid signature
        #     end
        #   else
        #     # malformed signature
        #   end

        def initialize(param: :signature)
          @param = param
        end

        def matches?(request)
          signature = request.params[@param]
          return true unless signature

          path_and_query = build_path_and_query(request, signature)
          verifier = OpenGraphPlus::Signature::Verifier.new(signature: signature, path_and_query: path_and_query)

          request.env[ENV_KEY] = verifier

          true
        end

        private

        def build_path_and_query(request, signature)
          # Find signature in path and take everything after it
          request.path
            .split(signature, 2)
            .last
            .then { |path| path.empty? ? "/" : path }
            .then { |path| request.query_string.empty? ? path : "#{path}?#{request.query_string}" }
        end
      end
    end
  end
end
