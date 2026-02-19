# frozen_string_literal: true

RSpec.describe OpenGraphPlus::DomainImageURL do
  let(:public_key) { "test_public_key" }

  subject { described_class.new(public_key, base_url: "https://opengraphplus.com") }

  describe "#url" do
    it "builds a domain image URL for a page path" do
      url = subject.url("/blog/my-post")
      expect(url).to eq("https://opengraphplus.com/api/websites/v1/domain/test_public_key/image/blog/my-post")
    end

    it "handles root path" do
      url = subject.url("/")
      expect(url).to eq("https://opengraphplus.com/api/websites/v1/domain/test_public_key/image/")
    end

    it "strips leading slash from path" do
      url_with = subject.url("/page")
      url_without = subject.url("page")
      expect(url_with).to eq(url_without)
    end

    it "uses the configured base URL" do
      custom = described_class.new(public_key, base_url: "https://custom.example.com")
      url = custom.url("/page")
      expect(url).to start_with("https://custom.example.com/")
    end
  end
end
