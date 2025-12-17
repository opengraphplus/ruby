# frozen_string_literal: true

module OpenGraphPlus
  module Signature
    DIGEST_ALGORITHM = "SHA256"
    HMAC_BYTES = 16  # Truncated HMAC length for shorter URLs
  end
end

require_relative "signature/generator"
require_relative "signature/verifier"
require_relative "signature/url"
