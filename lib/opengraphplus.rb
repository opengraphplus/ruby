# frozen_string_literal: true

require_relative "opengraphplus/version"
require_relative "opengraphplus/configuration"
require_relative "opengraphplus/tag"
require_relative "opengraphplus/tags"
require_relative "opengraphplus/tags/renderer"

module OpenGraphPlus
  class Error < StandardError; end
end

require_relative "opengraphplus/rails" if defined?(::Rails::Railtie)