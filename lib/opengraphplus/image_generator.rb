# frozen_string_literal: true

module OpenGraphPlus
  class ImageGenerator
    attr_reader :request

    def initialize(request)
      @request = request
    end

    def url
      return nil unless api_key

      Signature::URL.new
        .signed_path("/api/websites/v1", api_key)
        .build("image", url: request.original_url)
    end

    private

    def api_key
      @api_key ||= OpenGraphPlus.configuration.api_key
    end
  end
end
