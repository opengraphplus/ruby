# frozen_string_literal: true

RSpec.describe OpenGraphPlus::Configuration do
  let(:bundled_api_key) do
    OpenGraphPlus::APIKey.new(public_key: "test_pk", secret_key: "test_sk").to_s
  end

  describe "#api_key" do
    it "defaults to nil" do
      config = described_class.new
      expect(config.api_key).to be_nil
    end

    it "can be set with a bundled key string" do
      config = described_class.new
      config.api_key = bundled_api_key
      expect(config.api_key).to be_a(OpenGraphPlus::APIKey)
      expect(config.api_key.public_key).to eq("test_pk")
      expect(config.api_key.secret_key).to eq("test_sk")
    end

    it "can be set with an APIKey object" do
      config = described_class.new
      api_key = OpenGraphPlus::APIKey.new(public_key: "pk", secret_key: "sk")
      config.api_key = api_key
      expect(config.api_key).to eq(api_key)
    end
  end

  describe "#base_url" do
    it "defaults to nil" do
      config = described_class.new
      expect(config.base_url).to be_nil
    end

    it "can be set to a URL string" do
      config = described_class.new
      config.base_url = "https://mysite.com"
      expect(config.base_url).to eq("https://mysite.com")
    end
  end

  describe "#resolve_url" do
    let(:config) { described_class.new }

    context "when base_url is set" do
      before { config.base_url = "https://mysite.com" }

      it "joins base_url with request path" do
        request = double("request", path: "/about")
        expect(config.resolve_url(request)).to eq("https://mysite.com/about")
      end

      it "handles trailing slash on base_url" do
        config.base_url = "https://mysite.com/"
        request = double("request", path: "/about")
        expect(config.resolve_url(request)).to eq("https://mysite.com/about")
      end
    end

    context "when base_url is nil and request has a valid host" do
      it "returns request.url" do
        request = double("request", host: "example.com", url: "https://example.com/test")
        expect(config.resolve_url(request)).to eq("https://example.com/test")
      end
    end

    context "when base_url is nil and request has no valid host" do
      it "warns and returns nil" do
        request = double("request", host: "", url: "http://:/")
        expect(config).to receive(:warn).with(/Cannot determine site URL/)
        expect(config.resolve_url(request)).to be_nil
      end
    end

    context "when base_url is nil and request does not respond to host" do
      it "warns and returns nil" do
        request = double("request", url: "http://:/")
        expect(config).to receive(:warn).with(/Cannot determine site URL/)
        expect(config.resolve_url(request)).to be_nil
      end
    end
  end

  describe "#api_url" do
    it "defaults to https://opengraphplus.com" do
      config = described_class.new
      expect(config.api_url).to eq("https://opengraphplus.com")
    end

    it "can be set to a custom URL" do
      config = described_class.new
      config.api_url = "https://custom.example.com"
      expect(config.api_url).to eq("https://custom.example.com")
    end
  end
end

RSpec.describe OpenGraphPlus do
  let(:bundled_api_key) do
    OpenGraphPlus::APIKey.new(public_key: "test_pk", secret_key: "test_sk").to_s
  end

  after do
    described_class.reset_configuration!
  end

  describe ".configure" do
    it "yields the configuration" do
      described_class.configure do |config|
        config.api_key = bundled_api_key
      end

      expect(described_class.configuration.api_key).to be_a(OpenGraphPlus::APIKey)
      expect(described_class.configuration.api_key.public_key).to eq("test_pk")
    end
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(described_class.configuration).to be_a(OpenGraphPlus::Configuration)
    end

    it "returns the same instance on multiple calls" do
      expect(described_class.configuration).to eq(described_class.configuration)
    end
  end

  describe ".reset_configuration!" do
    it "resets the configuration" do
      described_class.configure { |c| c.api_key = "test" }
      described_class.reset_configuration!
      expect(described_class.configuration.api_key).to be_nil
    end
  end
end
