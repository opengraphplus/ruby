# frozen_string_literal: true

module OpenGraphPlus
  class ImageGenerator
    attr_reader :request

    def initialize(request)
      @request = request
      @signature_url = Signature::URL.new
    end

    def url
      @signature_url.build("/opengraph", url: request.original_url)
    end
  end
end
