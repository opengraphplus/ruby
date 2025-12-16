# frozen_string_literal: true

module OpenGraphPlus
  module Helper
    def open_graph(**kwargs)
      if block_given?
        yield(@open_graph_root ||= Tags::Root.new(**kwargs))
      elsif kwargs.any?
        @open_graph_root = Tags::Root.new(**kwargs)
      else
        @open_graph_root ||= Tags::Root.new
      end
    end

    def open_graph_tags
      root = @open_graph_root || Tags::Root.new

      if defined?(request) && request.respond_to?(:original_url)
        root.generate_image!(request.original_url)
      end

      Tags::Renderer.new(root).tags
    end

    def open_graph_meta_tags
      result = open_graph_tags.map(&:to_s).join("\n")
      result.respond_to?(:html_safe) ? result.html_safe : result
    end
  end
end
