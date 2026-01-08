# frozen_string_literal: true

require "net/http"
require "uri"

module OpenGraphPlus
  class Verifier
    class FetchError < Error; end

    MAX_REDIRECTS = 5

    attr_reader :url

    def initialize(url)
      @url = url
    end

    def verify
      html = fetch_html
      Parser.new(html)
    end

    private

    def fetch_html(redirect_count = 0)
      raise FetchError, "Too many redirects" if redirect_count > MAX_REDIRECTS

      uri = URI.parse(@url)
      response = Net::HTTP.get_response(uri)

      case response
      when Net::HTTPSuccess
        response.body
      when Net::HTTPRedirection
        @url = response["location"]
        fetch_html(redirect_count + 1)
      else
        raise FetchError, "HTTP #{response.code}: #{response.message}"
      end
    rescue URI::InvalidURIError => e
      raise FetchError, "Invalid URL: #{e.message}"
    rescue SocketError, Errno::ECONNREFUSED, Errno::ETIMEDOUT => e
      raise FetchError, "Connection failed: #{e.message}"
    end
  end
end
