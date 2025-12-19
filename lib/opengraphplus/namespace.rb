# frozen_string_literal: true

require "forwardable"

module OpenGraphPlus
  module Namespace
    class Base
      include Enumerable

      def each(&) = tags.each(&)

      def tag(property, value)
        Tag.new(property, value) if value
      end

      def render_in(_view_context = nil)
        map { |tag| tag.render_in }.join("\n").html_safe
      end

      def update(**kwargs)
        kwargs.each { |key, value| public_send(:"#{key}=", value) }
        self
      end
    end

    class Image < Base
      attr_accessor :url, :secure_url, :type, :width, :height, :alt

      def tags
        [
          tag("og:image", url),
          tag("og:image:secure_url", secure_url),
          tag("og:image:type", type),
          tag("og:image:width", width),
          tag("og:image:height", height),
          tag("og:image:alt", alt)
        ].compact
      end
    end

    class Plus < Base
      attr_accessor :selector, :style

      def style=(value)
        @style = case value
        when Hash
          hash_to_css(value)
        else
          value
        end
      end

      def tags
        [
          tag("og:plus:selector", selector),
          tag("og:plus:style", style)
        ].compact
      end

      private

      def hash_to_css(hash)
        hash.map { |k, v| "#{k.to_s.tr("_", "-")}: #{v}" }.join("; ")
      end
    end

    class OG < Base
      attr_accessor :title, :description, :url, :type, :site_name, :locale, :determiner, :audio, :video

      def initialize
        @type = "website"
      end

      def image
        @image ||= Image.new
      end

      def plus
        @plus ||= Plus.new
      end

      def image_url=(url)
        image.url = url
        image.secure_url = url
      end

      def tags
        [
          tag("og:title", title),
          tag("og:description", description),
          tag("og:url", url),
          tag("og:type", type),
          tag("og:site_name", site_name),
          tag("og:locale", locale),
          tag("og:determiner", determiner),
          tag("og:audio", audio),
          tag("og:video", video),
          *image.tags,
          *plus.tags
        ].compact
      end
    end

    class Twitter < Base
      class Image < Base
        attr_accessor :url, :alt

        def tags
          [
            tag("twitter:image", url),
            tag("twitter:image:alt", alt)
          ].compact
        end
      end

      attr_accessor :card, :site, :creator, :title, :description

      def initialize
        @card = "summary_large_image"
      end

      def image
        @image ||= Image.new
      end

      def image_url=(url)
        image.url = url
      end

      def tags
        [
          tag("twitter:card", card),
          tag("twitter:site", site),
          tag("twitter:creator", creator),
          tag("twitter:title", title),
          tag("twitter:description", description),
          *image.tags
        ].compact
      end
    end

    class Root < Base
      extend Forwardable

      def og
        @og ||= OG.new
      end

      def twitter
        @twitter ||= Twitter.new
      end

      def tags
        [*og.tags, *twitter.tags]
      end

      def_delegators :og,
        :title, :title=,
        :description, :description=,
        :url, :url=,
        :type, :type=,
        :site_name, :site_name=,
        :locale, :locale=,
        :determiner, :determiner=,
        :audio, :audio=,
        :video, :video=,
        :image, :image_url=,
        :plus
    end
  end

  # Backwards compatibility
  Tags = Namespace
end
