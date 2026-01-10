# frozen_string_literal: true

RSpec.describe OpenGraphPlus::ImageGenerator do
  let(:bundled_api_key) do
    OpenGraphPlus::APIKey.new(public_key: "test_public_key", secret_key: "test_secret_key").to_s
  end

  describe "#url" do
    it "returns nil if api_key is nil" do
      generator = described_class.new(nil)
      expect(generator.url("https://example.com/page")).to be_nil
    end

    it "returns generated URL when api_key is provided" do
      generator = described_class.new(bundled_api_key)
      url = generator.url("https://example.com/page")

      expect(url).to start_with("https://opengraphplus.com/api/websites/v1/")
      expect(url).to include("/image?url=https%3A%2F%2Fexample.com%2Fpage")
    end

    it "generates consistent URLs for the same input" do
      generator = described_class.new(bundled_api_key)
      source_url = "https://example.com/page"

      expect(generator.url(source_url)).to eq(generator.url(source_url))
    end

    it "generates verifiable signatures" do
      generator = described_class.new(bundled_api_key)
      url = URI.parse(generator.url("https://example.com/page"))

      # Extract signature from path (path is /api/websites/v1/:signature/image)
      signature = url.path.split("/")[4]
      path_and_query = "/image?#{url.query}"

      verifier = OpenGraphPlus::Signature::Verifier.new(
        signature: signature,
        path_and_query: path_and_query
      )

      expect(verifier.public_key).to eq("test_public_key")
      expect(verifier.valid?("test_secret_key")).to be true
      expect(verifier.valid?("wrong_key")).to be false
    end
  end
end
