# frozen_string_literal: true

module OpenGraphPlus
  module Rails
    module Helper
      def open_graph(**)
        @open_graph_root ||= Namespace::Root.new
        @open_graph_root.update(**)
        yield @open_graph_root if block_given?
        @open_graph_root
      end

      def open_graph_tags
        open_graph.to_a
      end

      def open_graph_meta_tags
        open_graph.render_in(self)
      end
    end
  end
end
