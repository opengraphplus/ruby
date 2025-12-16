# frozen_string_literal: true

module OpenGraphPlus
  module Tags
    class Image
      attr_accessor :url, :width, :height, :type, :alt, :secure_url

      def initialize(url: nil, width: nil, height: nil, type: nil, alt: nil, secure_url: nil)
        @url = url
        @width = width
        @height = height
        @type = type
        @alt = alt
        @secure_url = secure_url
      end
    end

    class Root
      attr_accessor :title, :description, :url, :type, :image, :site_name, :locale, :determiner, :audio, :video

      def initialize(
        title: nil,
        description: nil,
        url: nil,
        type: "website",
        image: nil,
        site_name: nil,
        locale: nil,
        determiner: nil,
        audio: nil,
        video: nil,
        image_url: nil
      )
        @title = title
        @description = description
        @url = url
        @type = type
        @site_name = site_name
        @locale = locale
        @determiner = determiner
        @audio = audio
        @video = video

        @image = case { image_url: image_url, image: image }
        in { image_url: String => url }
          Image.new(url: url, alt: title, secure_url: url)
        in { image: Hash => kwargs }
          Image.new(**kwargs)
        in { image: }
          image
        else
          nil
        end
      end

      def image_url=(url)
        @image = Image.new(url: url, alt: title, secure_url: url)
      end

      def update(**kwargs)
        kwargs.each do |key, value|
          public_send(:"#{key}=", value)
        end
        self
      end

      def generate_image!(request_url)
        return if image

        api_key = OpenGraphPlus.configuration.api_key
        return unless api_key

        encoded_url = CGI.escape(request_url)
        @image = Image.new(url: "https://opengraphplus.com/api/v1/generate?url=#{encoded_url}")
      end
    end
  end
end
