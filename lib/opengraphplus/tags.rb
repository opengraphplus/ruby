# frozen_string_literal: true

require "forwardable"

module OpenGraphPlus
  module Tags
    class Base
      def update(**kwargs)
        kwargs.each { |key, value| public_send(:"#{key}=", value) }
        self
      end
    end

    class Image < Base
      attr_accessor :url, :width, :height, :type, :alt, :secure_url
    end

    class Twitter < Base
      attr_accessor :card, :site, :creator, :title, :description, :image, :image_alt

      def initialize
        @card = "summary_large_image"
      end
    end

    class OpenGraph < Base
      attr_accessor :title, :description, :url, :type, :site_name, :locale, :determiner, :audio, :video
      attr_reader :image, :plus

      def initialize
        @type = "website"
        @image = Image.new
        @plus = Plus.new
      end

      def image_url=(url)
        @image.url = url
        @image.secure_url = url
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

      private

      def hash_to_css(hash)
        hash.map { |k, v| "#{k.to_s.tr("_", "-")}: #{v}" }.join("; ")
      end
    end

    class Root < Base
      extend Forwardable

      attr_reader :og, :twitter

      def_delegators :@og,
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

      def initialize
        @og = OpenGraph.new
        @twitter = Twitter.new
      end
    end
  end
end
