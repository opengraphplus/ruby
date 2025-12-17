# frozen_string_literal: true

module OpenGraphPlus
  module Rails
    module Signature
      module Routes
        extend ActiveSupport::Concern

        # Access the signature verifier set up by Signature::Scope
        #
        # Usage:
        #   class ScreenshotsController < ApplicationController
        #     include OpenGraphPlus::Rails::Signature::Routes
        #
        #     def show
        #       if signature_verifier&.public_key
        #         api_key = ApiKey.find_by(public_key: signature_verifier.public_key)
        #         if api_key && signature_verifier.valid?(api_key.secret_key)
        #           # success
        #         else
        #           # invalid signature
        #         end
        #       else
        #         # malformed signature
        #       end
        #     end
        #   end

        def signature_verifier
          request.env[ENV_KEY]
        end
      end
    end
  end
end
