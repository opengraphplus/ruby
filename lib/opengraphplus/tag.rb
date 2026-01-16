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

    def render_in(_view_context = nil)
      meta.html_safe
    end

    def to_s
      meta
    end

    def ==(other)
      other.is_a?(Tag) && property == other.property && content == other.content
    end

    private

    def escape(content)
      CGI.escapeHTML(content.to_s)
    end
  end
end
