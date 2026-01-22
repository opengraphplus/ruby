# frozen_string_literal: true

module OpenGraphPlus
  class ImageGenerator
    def initialize(api_key)
      @api_key = api_key
    end

    def url(source_url, **params)
      return nil unless @api_key

      Signature::URL.new
        .signed_path("/api/websites/v1", @api_key)
        .build("image", url: source_url, **params)
    end
  end
end
