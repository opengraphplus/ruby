# frozen_string_literal: true

RSpec.describe OpenGraphPlus::ImageGenerator do
  let(:request) { double("request", original_url: "https://example.com/page") }
  let(:bundled_api_key) do
    OpenGraphPlus::APIKey.new(public_key: "test_public_key", secret_key: "test_secret_key").to_s
  end

  after { OpenGraphPlus.reset_configuration! }

  describe "#url" do
    it "returns nil if api_key is not configured" do
      generator = described_class.new(request)
      expect(generator.url).to be_nil
    end

    it "returns generated URL when api_key is configured" do
      OpenGraphPlus.configure { |c| c.api_key = bundled_api_key }

      generator = described_class.new(request)
      url = generator.url

      expect(url).to start_with("https://opengraphplus.com/api/websites/v1/")
      expect(url).to include("/opengraph?url=https%3A%2F%2Fexample.com%2Fpage")
    end

    it "generates consistent URLs for the same input" do
      OpenGraphPlus.configure { |c| c.api_key = bundled_api_key }

      generator = described_class.new(request)

      expect(generator.url).to eq(generator.url)
    end

    it "generates verifiable signatures" do
      OpenGraphPlus.configure { |c| c.api_key = bundled_api_key }

      generator = described_class.new(request)
      url = URI.parse(generator.url)

      # Extract signature from path (path is /api/websites/v1/:signature/opengraph)
      signature = url.path.split("/")[4]
      path_and_query = "/opengraph?#{url.query}"

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
