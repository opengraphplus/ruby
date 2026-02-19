# frozen_string_literal: true

module OpenGraphPlus
  class Configuration
    DEFAULT_URL = "https://opengraphplus.com"

    attr_accessor :api_url, :public_key, :secret_key

    def initialize
      @api_url = DEFAULT_URL
      @public_key = nil
      @secret_key = nil
    end

    def api_key
      return unless @public_key && @secret_key
      APIKey.new(public_key: @public_key, secret_key: @secret_key)
    end

    def api_key=(value)
      parsed = value.is_a?(APIKey) ? value : APIKey.parse(value)
      @public_key = parsed&.public_key
      @secret_key = parsed&.secret_key
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
