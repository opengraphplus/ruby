# frozen_string_literal: true

RSpec.describe OpenGraphPlus::Tags::Image do
  describe "#initialize" do
    it "accepts all properties as keyword arguments" do
      image = described_class.new(
        url: "https://example.com/image.png",
        width: 1200,
        height: 630,
        type: "image/png",
        alt: "Alt text",
        secure_url: "https://example.com/image.png"
      )

      expect(image.url).to eq("https://example.com/image.png")
      expect(image.width).to eq(1200)
      expect(image.height).to eq(630)
      expect(image.type).to eq("image/png")
      expect(image.alt).to eq("Alt text")
      expect(image.secure_url).to eq("https://example.com/image.png")
    end

    it "defaults all properties to nil" do
      image = described_class.new
      expect(image.url).to be_nil
      expect(image.width).to be_nil
    end
  end
end

RSpec.describe OpenGraphPlus::Tags::Root do
  after do
    OpenGraphPlus.reset_configuration!
  end

  describe "#initialize" do
    it "accepts all properties as keyword arguments" do
      root = described_class.new(
        title: "My Title",
        description: "My Description",
        url: "https://example.com",
        type: "article",
        site_name: "Example Site",
        locale: "en_US"
      )

      expect(root.title).to eq("My Title")
      expect(root.description).to eq("My Description")
      expect(root.url).to eq("https://example.com")
      expect(root.type).to eq("article")
      expect(root.site_name).to eq("Example Site")
      expect(root.locale).to eq("en_US")
    end

    it "defaults type to website" do
      root = described_class.new
      expect(root.type).to eq("website")
    end

    it "accepts image_url shorthand" do
      root = described_class.new(title: "Test", image_url: "https://example.com/image.png")

      expect(root.image).to be_a(OpenGraphPlus::Tags::Image)
      expect(root.image.url).to eq("https://example.com/image.png")
      expect(root.image.alt).to eq("Test")
      expect(root.image.secure_url).to eq("https://example.com/image.png")
    end

    it "accepts image as a Hash" do
      root = described_class.new(image: { url: "https://example.com/image.png", width: 1200 })

      expect(root.image).to be_a(OpenGraphPlus::Tags::Image)
      expect(root.image.url).to eq("https://example.com/image.png")
      expect(root.image.width).to eq(1200)
    end

    it "accepts image as an Image object" do
      image = OpenGraphPlus::Tags::Image.new(url: "https://example.com/image.png")
      root = described_class.new(image: image)

      expect(root.image).to eq(image)
    end
  end

  describe "#generate_image!" do
    it "does nothing if image is already set" do
      root = described_class.new(image_url: "https://example.com/existing.png")
      root.generate_image!("https://example.com/page")

      expect(root.image.url).to eq("https://example.com/existing.png")
    end

    it "does nothing if api_key is not configured" do
      root = described_class.new
      root.generate_image!("https://example.com/page")

      expect(root.image).to be_nil
    end

    it "sets generated image when api_key is configured" do
      OpenGraphPlus.configure { |c| c.api_key = "test_key" }

      root = described_class.new(title: "Test")
      root.generate_image!("https://example.com/page")

      expect(root.image.url).to eq("https://opengraphplus.com/api/v1/generate?url=https%3A%2F%2Fexample.com%2Fpage")
    end
  end
end
