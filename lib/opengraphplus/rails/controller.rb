# frozen_string_literal: true

module OpenGraphPlus
  module Rails
    module Controller
      extend ActiveSupport::Concern

      included do
        helper_method :open_graph, :open_graph_tags, :open_graph_meta_tags
        append_before_action :set_default_open_graph_image
      end

      class_methods do
        def open_graph(&block)
          before_action { instance_exec(open_graph, &block) }
        end
      end

      def open_graph_image_generator
        ImageGenerator.new(request)
      end

      private

      def set_default_open_graph_image
        return if open_graph.image.url

        generated_url = open_graph_image_generator.url
        open_graph.image.url = generated_url if generated_url
      end

      include Helper
    end
  end
end
