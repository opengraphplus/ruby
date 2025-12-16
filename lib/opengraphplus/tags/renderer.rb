# frozen_string_literal: true

module OpenGraphPlus
  module Tags
    class Renderer
      attr_reader :root

      def initialize(root)
        @root = root
      end

      def tags
        [
          tag("og:title", root.title),
          tag("og:description", root.description),
          tag("og:url", root.url),
          tag("og:type", root.type),
          tag("og:site_name", root.site_name),
          tag("og:locale", root.locale),
          tag("og:determiner", root.determiner),
          tag("og:audio", root.audio),
          tag("og:video", root.video),
          *image_tags
        ].compact
      end

      private

      def tag(property, content)
        return nil if content.nil?

        Tag.new(property, content)
      end

      def image_tags
        return [] unless root.image

        image = root.image
        [
          tag("og:image", image.url),
          tag("og:image:secure_url", image.secure_url),
          tag("og:image:type", image.type),
          tag("og:image:width", image.width),
          tag("og:image:height", image.height),
          tag("og:image:alt", image.alt)
        ]
      end
    end
  end
end
