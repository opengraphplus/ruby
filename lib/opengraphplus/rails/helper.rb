# frozen_string_literal: true

module OpenGraphPlus
  module Rails
    module Helper
      def open_graph(**)
        @open_graph_root ||= default_open_graph
        @open_graph_root.update(**)
        yield @open_graph_root if block_given?
        @open_graph_root
      end

      def open_graph_tags
        open_graph.to_a
      end

      def open_graph_meta_tags
        yield open_graph if block_given?
        open_graph.render_in(self)
      end

      protected

      def default_open_graph
        Namespace::Root.new.tap do |root|
          root.type = "website"
          root.url = request.url if request
        end
      end
    end
  end
end
