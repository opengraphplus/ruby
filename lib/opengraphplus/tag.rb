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
      escaped_content = CGI.escapeHTML(@content.to_s)
      %(<meta property="#{@property}" content="#{escaped_content}">)
    end

    def render_in(view_context = nil)
      result = meta
      if view_context.respond_to?(:raw)
        view_context.raw(result)
      elsif result.respond_to?(:html_safe)
        result.html_safe
      else
        result
      end
    end

    def to_s
      meta
    end
  end
end
