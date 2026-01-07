# frozen_string_literal: true

require "forwardable"

module OpenGraphPlus
  module Tags
    class Base
      include Enumerable

      def each(&block)
        tags.each do |t|
          case t
          when Base
            t.each(&block)
          when Tag
            yield t if t.content
          end
        end
      end

      def tags = []

      def render_in(view_context)
        map { |tag| tag.render_in(view_context) }.join("\n")
      end

      def update(**kwargs)
        kwargs.each { |key, value| public_send(:"#{key}=", value) }
        self
      end
    end

    class Image < Base
      attr_accessor :url, :width, :height, :type, :alt, :secure_url

      def tags
        [
          Tag.new("og:image", url),
          Tag.new("og:image:secure_url", secure_url),
          Tag.new("og:image:type", type),
          Tag.new("og:image:width", width),
          Tag.new("og:image:height", height),
          Tag.new("og:image:alt", alt),
        ]
      end
    end

    class Plus < Base
      attr_accessor :selector
      attr_reader :style

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
          Tag.new("og:plus:selector", selector),
          Tag.new("og:plus:style", style),
        ]
      end

      private

      def hash_to_css(hash)
        hash.map { |k, v| "#{k.to_s.tr("_", "-")}: #{v}" }.join("; ")
      end
    end

    class OpenGraph < Base
      attr_accessor :title, :description, :url, :type, :site_name, :locale, :determiner, :audio, :video

      def image = @image ||= Image.new
      def plus = @plus ||= Plus.new

      def initialize
        @type = "website"
      end

      def image_url=(url)
        image.url = url
        image.secure_url = url
      end

      def tags
        [
          Tag.new("og:title", title),
          Tag.new("og:description", description),
          Tag.new("og:url", url),
          Tag.new("og:type", type),
          Tag.new("og:site_name", site_name),
          Tag.new("og:locale", locale),
          Tag.new("og:determiner", determiner),
          Tag.new("og:audio", audio),
          Tag.new("og:video", video),
          image,
          plus,
        ]
      end
    end

    class Twitter < Base
      attr_accessor :card, :site, :creator, :title, :description, :image, :image_alt

      def initialize
        @card = "summary_large_image"
      end

      def tags
        [
          Tag.new("twitter:card", card),
          Tag.new("twitter:site", site),
          Tag.new("twitter:creator", creator),
          Tag.new("twitter:title", title),
          Tag.new("twitter:description", description),
          Tag.new("twitter:image", image),
          Tag.new("twitter:image:alt", image_alt),
        ]
      end
    end

    class Root < Base
      extend Forwardable

      def og = @og ||= OpenGraph.new
      def twitter = @twitter ||= Twitter.new

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

      def tags
        [og, twitter]
      end
    end
  end
end
