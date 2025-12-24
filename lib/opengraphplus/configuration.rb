# frozen_string_literal: true

module OpenGraphPlus
  class Configuration
    def initialize
      @api_key = nil
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
