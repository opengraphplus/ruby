# frozen_string_literal: true

require_relative "opengraphplus/version"
require_relative "opengraphplus/api_key"
require_relative "opengraphplus/configuration"
require_relative "opengraphplus/signature"
require_relative "opengraphplus/tag"
require_relative "opengraphplus/tags"
require_relative "opengraphplus/tags/renderer"
require_relative "opengraphplus/image_generator"

module OpenGraphPlus
  class Error < StandardError; end
end

require_relative "opengraphplus/rails" if defined?(::Rails::Railtie)
