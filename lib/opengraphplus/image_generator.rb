# frozen_string_literal: true

require "cgi"

module OpenGraphPlus
  class ImageGenerator
    attr_reader :request

    def initialize(request)
      @request = request
    end

    def url
      return nil unless api_key

      encoded_url = CGI.escape(request.original_url)
      "https://opengraphplus.com/api/v1/generate?url=#{encoded_url}"
    end

    private

    def api_key
      OpenGraphPlus.configuration.api_key
    end
  end
end
