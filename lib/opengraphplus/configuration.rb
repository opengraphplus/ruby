# frozen_string_literal: true

module OpenGraphPlus
  class Configuration
    attr_reader :api_key

    def initialize
      @api_key = nil
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
