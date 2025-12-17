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
