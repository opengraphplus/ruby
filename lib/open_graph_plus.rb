# frozen_string_literal: true

require_relative "open_graph_plus/version"
require_relative "open_graph_plus/configuration"
require_relative "open_graph_plus/tag"
require_relative "open_graph_plus/tags"
require_relative "open_graph_plus/tags/renderer"
require_relative "open_graph_plus/helper"

module OpenGraphPlus
  class Error < StandardError; end
end

require_relative "open_graph_plus/railtie" if defined?(Rails::Railtie)
