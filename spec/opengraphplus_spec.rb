# frozen_string_literal: true

RSpec.describe OpenGraphPlus do
  it "has a version number" do
    expect(OpenGraphPlus::VERSION).not_to be nil
  end

  describe ".image_url" do
    before do
      OpenGraphPlus.configure do |config|
        config.api_key = OpenGraphPlus::APIKey.new(
          public_key: "test_public_key",
          secret_key: "test_secret_key"
        ).to_s
      end
    end

    it "generates an image URL" do
      url = OpenGraphPlus.image_url("https://example.com/page")
      expect(url).to include("/image?url=")
    end

    it "passes consumer param through to the signed URL" do
      url = OpenGraphPlus.image_url("https://example.com/page", consumer: "twitter")
      expect(url).to include("consumer=twitter")
    end
  end
end
