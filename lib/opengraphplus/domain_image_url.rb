# frozen_string_literal: true

module OpenGraphPlus
  class DomainImageURL
    def initialize(public_key, base_url: OpenGraphPlus.configuration.api_url)
      @public_key = public_key
      @base_url = URI.parse(base_url)
    end

    def url(page_path)
      @base_url.dup.tap do |uri|
        uri.path = File.join("/api/websites/v1/domain", @public_key, "image", page_path.to_s)
      end.to_s
    end
  end
end
