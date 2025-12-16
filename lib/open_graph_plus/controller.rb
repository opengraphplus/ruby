# frozen_string_literal: true

module OpenGraphPlus
  module Controller
    extend ActiveSupport::Concern

    included do
      helper_method :open_graph, :open_graph_tags, :open_graph_meta_tags
    end

    class_methods do
      def open_graph(&block)
        before_action { instance_exec(open_graph, &block) }
      end
    end

    include Helper
  end
end
