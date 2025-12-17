# frozen_string_literal: true

RSpec.describe OpenGraphPlus::ImageGenerator do
  let(:request) { double("request", original_url: "https://example.com/page") }

  after { OpenGraphPlus.reset_configuration! }

  describe "#url" do
    it "returns nil if api_key is not configured" do
      generator = described_class.new(request)
      expect(generator.url).to be_nil
    end

    it "returns generated URL when api_key is configured" do
      OpenGraphPlus.configure { |c| c.api_key = "test_key" }

      generator = described_class.new(request)

      expect(generator.url).to eq("https://opengraphplus.com/api/v1/generate?url=https%3A%2F%2Fexample.com%2Fpage")
    end
  end
end
