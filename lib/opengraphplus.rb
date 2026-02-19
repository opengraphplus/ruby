# frozen_string_literal: true

require_relative "opengraphplus/version"

module OpenGraphPlus
  class Error < StandardError; end

  def self.image_url(source_url, **params)
    config = configuration
    if config.secret_key
      SignedImageURL.new(config.api_key).url(source_url, **params)
    elsif config.public_key
      DomainImageURL.new(config.public_key).url(source_url)
    else
      warn "[OpenGraphPlus] No API key configured. Get one at https://opengraphplus.com"
      nil
    end
  end
end

require_relative "opengraphplus/api_key"
require_relative "opengraphplus/configuration"
require_relative "opengraphplus/signature"
require_relative "opengraphplus/tag"
require_relative "opengraphplus/namespace"
require_relative "opengraphplus/signed_image_url"
require_relative "opengraphplus/domain_image_url"
require_relative "opengraphplus/parser"
require_relative "opengraphplus/verifier"

require_relative "opengraphplus/rails" if defined?(::Rails::Railtie)
