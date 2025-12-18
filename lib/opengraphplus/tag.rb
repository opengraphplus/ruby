# frozen_string_literal: true

require "cgi"

module OpenGraphPlus
  class Tag
    attr_reader :property, :content

    def initialize(property, content)
      @property = property
      @content = content
    end

    def meta
      %(<meta property="#{escape property}" content="#{escape content}">)
    end

    def render_in(rails_view_context)
      rails_view_context.raw(meta)
    end

    def to_s
      meta
    end

    private

    def escape(content)
      CGI.escapeHTML(content.to_s)
    end
  end
end
