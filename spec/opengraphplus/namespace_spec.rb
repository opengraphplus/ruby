# frozen_string_literal: true

RSpec.describe OpenGraphPlus::Namespace::Base do
  describe "#each" do
    it "iterates over tags" do
      root = OpenGraphPlus::Namespace::Root.new
      root.title = "Test"
      root.description = "A description"

      tags = root.to_a
      expect(tags).to all(be_a(OpenGraphPlus::Tag))
      expect(tags.map(&:property)).to include("og:title", "og:description")
    end

    it "filters out nil content" do
      root = OpenGraphPlus::Namespace::Root.new
      root.title = "Test"

      properties = root.map(&:property)
      expect(properties).to include("og:title")
      expect(properties).not_to include("og:description")
    end
  end

  describe "lazy initialization" do
    it "creates nested objects on first access" do
      root = OpenGraphPlus::Namespace::Root.new
      expect(root.image).to be_a(OpenGraphPlus::Namespace::Image)
    end
  end
end

RSpec.describe OpenGraphPlus::Namespace::Image do
  describe "#update" do
    it "updates attributes and returns self" do
      image = described_class.new
      result = image.update(url: "https://example.com/image.png", width: 1200)

      expect(image.url).to eq("https://example.com/image.png")
      expect(image.width).to eq(1200)
      expect(result).to eq(image)
    end
  end
end

RSpec.describe OpenGraphPlus::Namespace::Twitter do
  describe "#initialize" do
    it "defaults card to summary_large_image" do
      expect(described_class.new.card).to eq("summary_large_image")
    end
  end

  describe "#update" do
    it "updates attributes" do
      twitter = described_class.new
      twitter.update(site: "@example", creator: "@author", card: "summary")

      expect(twitter.site).to eq("@example")
      expect(twitter.creator).to eq("@author")
      expect(twitter.card).to eq("summary")
    end
  end
end

RSpec.describe OpenGraphPlus::Namespace::Viewport do
  describe "#tags" do
    it "generates og:plus:viewport:width tag" do
      viewport = described_class.new
      viewport.width = 800

      tags = viewport.tags
      expect(tags.size).to eq(1)
      expect(tags.first.property).to eq("og:plus:viewport:width")
      expect(tags.first.content).to eq(800)
    end

    it "returns empty array when width is nil" do
      viewport = described_class.new
      expect(viewport.tags).to be_empty
    end
  end
end

RSpec.describe OpenGraphPlus::Namespace::Plus do
  describe "#update" do
    it "updates attributes and returns self" do
      plus = described_class.new
      result = plus.update(selector: "article#main", style: "padding: 20px;")

      expect(plus.selector).to eq("article#main")
      expect(plus.style).to eq("padding: 20px;")
      expect(result).to eq(plus)
    end
  end

  describe "#viewport" do
    it "returns a Viewport instance" do
      plus = described_class.new
      expect(plus.viewport).to be_a(OpenGraphPlus::Namespace::Viewport)
    end

    it "allows setting viewport width" do
      plus = described_class.new
      plus.viewport.width = 800

      expect(plus.viewport.width).to eq(800)
    end

    it "includes viewport tags in plus tags" do
      plus = described_class.new
      plus.viewport.width = 800

      properties = plus.tags.map(&:property)
      expect(properties).to include("og:plus:viewport:width")
    end
  end

  describe "#style=" do
    it "accepts a string" do
      plus = described_class.new
      plus.style = "padding: 20px; background: red;"

      expect(plus.style).to eq("padding: 20px; background: red;")
    end

    it "accepts a hash and converts to CSS" do
      plus = described_class.new
      plus.style = { padding: "20px", background_color: "red" }

      expect(plus.style).to eq("padding: 20px; background-color: red")
    end

    it "converts underscores to hyphens in hash keys" do
      plus = described_class.new
      plus.style = { background_attachment: "fixed", font_size: "16px" }

      expect(plus.style).to eq("background-attachment: fixed; font-size: 16px")
    end

    it "preserves string keys with hyphens" do
      plus = described_class.new
      plus.style = { "background-color" => "blue", padding: "10px" }

      expect(plus.style).to eq("background-color: blue; padding: 10px")
    end
  end
end

RSpec.describe OpenGraphPlus::Namespace::OG do
  after { OpenGraphPlus.reset_configuration! }

  describe "#initialize" do
    it "defaults type to website" do
      expect(described_class.new.type).to eq("website")
    end

    it "creates an empty image" do
      expect(described_class.new.image).to be_a(OpenGraphPlus::Namespace::Image)
    end

    it "creates an empty plus" do
      expect(described_class.new.plus).to be_a(OpenGraphPlus::Namespace::Plus)
    end
  end

  describe "#update" do
    it "updates attributes" do
      og = described_class.new
      og.update(title: "Test", description: "Desc")

      expect(og.title).to eq("Test")
      expect(og.description).to eq("Desc")
    end
  end

  describe "#image_url=" do
    it "sets image url and secure_url" do
      og = described_class.new
      og.image_url = "https://example.com/image.png"

      expect(og.image.url).to eq("https://example.com/image.png")
      expect(og.image.secure_url).to eq("https://example.com/image.png")
    end
  end
end

RSpec.describe OpenGraphPlus::Namespace::Root do
  after { OpenGraphPlus.reset_configuration! }

  describe "#initialize" do
    it "creates og and twitter objects" do
      root = described_class.new
      expect(root.og).to be_a(OpenGraphPlus::Namespace::OG)
      expect(root.twitter).to be_a(OpenGraphPlus::Namespace::Twitter)
    end
  end

  describe "delegation to og" do
    it "delegates getters and setters" do
      root = described_class.new
      root.title = "Test"
      root.description = "Desc"

      expect(root.title).to eq("Test")
      expect(root.og.title).to eq("Test")
      expect(root.description).to eq("Desc")
    end

    it "has default type" do
      expect(described_class.new.type).to eq("website")
    end
  end

  describe "#image" do
    it "returns og.image" do
      root = described_class.new
      expect(root.image).to eq(root.og.image)
    end
  end

  describe "#image_url=" do
    it "sets og image url" do
      root = described_class.new
      root.image_url = "https://example.com/image.png"

      expect(root.image.url).to eq("https://example.com/image.png")
    end
  end

  describe "#plus" do
    it "returns og.plus" do
      root = described_class.new
      expect(root.plus).to eq(root.og.plus)
    end

    it "allows setting plus attributes" do
      root = described_class.new
      root.plus.selector = "article#main"
      root.plus.style = "padding: 20px;"

      expect(root.plus.selector).to eq("article#main")
      expect(root.plus.style).to eq("padding: 20px;")
    end
  end
end
