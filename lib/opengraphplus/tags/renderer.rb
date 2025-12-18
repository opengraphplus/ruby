# frozen_string_literal: true

module OpenGraphPlus
  module Tags
    class Renderer
      attr_reader :root

      def initialize(root)
        @root = root
      end

      def tags
        [*og_tags, *plus_tags, *twitter_tags].compact
      end

      private

      def og
        root.og
      end

      def twitter
        root.twitter
      end

      def tag(property, content)
        return nil if content.nil?

        Tag.new(property, content)
      end

      def og_tags
        [
          tag("og:title", og.title),
          tag("og:description", og.description),
          tag("og:url", og.url),
          tag("og:type", og.type),
          tag("og:site_name", og.site_name),
          tag("og:locale", og.locale),
          tag("og:determiner", og.determiner),
          tag("og:audio", og.audio),
          tag("og:video", og.video),
          *og_image_tags
        ]
      end

      def og_image_tags
        return [] unless og.image

        image = og.image
        [
          tag("og:image", image.url),
          tag("og:image:secure_url", image.secure_url),
          tag("og:image:type", image.type),
          tag("og:image:width", image.width),
          tag("og:image:height", image.height),
          tag("og:image:alt", image.alt)
        ]
      end

      def plus_tags
        return [] unless og.plus

        plus = og.plus
        [
          tag("og:plus:selector", plus.selector),
          tag("og:plus:style", plus.style)
        ]
      end

      def twitter_tags
        [
          tag("twitter:card", twitter.card),
          tag("twitter:site", twitter.site),
          tag("twitter:creator", twitter.creator),
          tag("twitter:title", twitter.title || og.title),
          tag("twitter:description", twitter.description || og.description),
          tag("twitter:image", twitter_image_url),
          tag("twitter:image:alt", twitter.image_alt || og.image&.alt)
        ]
      end

      def twitter_image_url
        twitter.image || og.image&.url
      end
    end
  end
end
