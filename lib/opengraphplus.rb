# frozen_string_literal: true

require_relative "opengraphplus/version"

module OpenGraphPlus
  class Error < StandardError; end
end

require_relative "opengraphplus/api_key"
require_relative "opengraphplus/configuration"
require_relative "opengraphplus/signature"
require_relative "opengraphplus/tag"
require_relative "opengraphplus/namespace"
require_relative "opengraphplus/image_generator"
require_relative "opengraphplus/parser"
require_relative "opengraphplus/verifier"

require_relative "opengraphplus/rails" if defined?(::Rails::Railtie)
