# frozen_string_literal: true

require "uri"

module OpenGraphPlus
  class Configuration
    DEFAULT_URL = "https://opengraphplus.com"

    attr_accessor :api_url, :base_url

    def initialize
      @api_key = nil
      @api_url = DEFAULT_URL
      @base_url = nil
    end

    def resolve_url(request)
      if @base_url
        URI.join(@base_url, request.path).to_s
      elsif request.respond_to?(:host) && request.host.present?
        request.url
      else
        warn "[OpenGraphPlus] Cannot determine site URL. Set OpenGraphPlus.configuration.base_url for static site generation."
        nil
      end
    end

    def api_key
      @api_key or warn "[OpenGraphPlus] API key not configured. Set OpenGraphPlus.configuration.api_key to enable automatic Open Graph image generation."
    end

    def api_key=(value)
      @api_key = value.is_a?(APIKey) ? value : APIKey.parse(value)
    end
  end

  class << self
    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield(configuration)
    end

    def reset_configuration!
      @configuration = Configuration.new
    end
  end
end
