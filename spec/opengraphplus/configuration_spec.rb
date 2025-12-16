# frozen_string_literal: true

RSpec.describe OpenGraphPlus::Configuration do
  describe "#api_key" do
    it "defaults to nil" do
      config = described_class.new
      expect(config.api_key).to be_nil
    end

    it "can be set" do
      config = described_class.new
      config.api_key = "test_key"
      expect(config.api_key).to eq("test_key")
    end
  end
end

RSpec.describe OpenGraphPlus do
  after do
    described_class.reset_configuration!
  end

  describe ".configure" do
    it "yields the configuration" do
      described_class.configure do |config|
        config.api_key = "my_api_key"
      end

      expect(described_class.configuration.api_key).to eq("my_api_key")
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
