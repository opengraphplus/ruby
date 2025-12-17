# frozen_string_literal: true

module OpenGraphPlus
  module Rails
    module Helper
      def open_graph(**kwargs)
        @open_graph_root ||= Tags::Root.new
        @open_graph_root.update(**kwargs) if kwargs.any?
        yield(@open_graph_root) if block_given?
        @open_graph_root
      end

      def open_graph_tags
        root = @open_graph_root || Tags::Root.new
        Tags::Renderer.new(root).tags
      end

      def open_graph_meta_tags
        result = open_graph_tags.map(&:to_s).join("\n")
        result.respond_to?(:html_safe) ? result.html_safe : result
      end
    end
  end
end
