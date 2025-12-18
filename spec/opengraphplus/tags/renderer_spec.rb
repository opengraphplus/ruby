# frozen_string_literal: true

RSpec.describe OpenGraphPlus::Tags::Renderer do
  describe "#tags" do
    it "returns an array of Tag objects" do
      root = OpenGraphPlus::Tags::Root.new
      root.title = "Test"

      expect(described_class.new(root).tags).to all(be_a(OpenGraphPlus::Tag))
    end

    it "generates tags for set properties" do
      root = OpenGraphPlus::Tags::Root.new
      root.title = "My Title"
      root.description = "My Description"

      rendered = described_class.new(root).tags.map(&:to_s).join("\n")

      expect(rendered).to include('<meta property="og:title" content="My Title">')
      expect(rendered).to include('<meta property="og:description" content="My Description">')
    end

    it "includes default type" do
      root = OpenGraphPlus::Tags::Root.new

      rendered = described_class.new(root).tags.map(&:to_s).join("\n")

      expect(rendered).to include('<meta property="og:type" content="website">')
    end

    it "skips nil properties" do
      root = OpenGraphPlus::Tags::Root.new
      root.title = "Test"

      tags = described_class.new(root).tags

      expect(tags.map(&:property)).not_to include("og:description")
    end

    context "with image" do
      it "generates image tags" do
        root = OpenGraphPlus::Tags::Root.new
        root.image.update(
          url: "https://example.com/image.png",
          width: 1200,
          height: 630,
          type: "image/png",
          alt: "Alt text"
        )

        rendered = described_class.new(root).tags.map(&:to_s).join("\n")

        expect(rendered).to include('<meta property="og:image" content="https://example.com/image.png">')
        expect(rendered).to include('<meta property="og:image:width" content="1200">')
        expect(rendered).to include('<meta property="og:image:height" content="630">')
        expect(rendered).to include('<meta property="og:image:type" content="image/png">')
        expect(rendered).to include('<meta property="og:image:alt" content="Alt text">')
      end

      it "skips nil image properties" do
        root = OpenGraphPlus::Tags::Root.new
        root.image.url = "https://example.com/image.png"

        tags = described_class.new(root).tags

        expect(tags.map(&:property)).to include("og:image")
        expect(tags.map(&:property)).not_to include("og:image:width")
      end
    end

    context "plus tags" do
      it "generates plus selector tag" do
        root = OpenGraphPlus::Tags::Root.new
        root.plus.selector = "article#main"

        rendered = described_class.new(root).tags.map(&:to_s).join("\n")

        expect(rendered).to include('<meta property="og:plus:selector" content="article#main">')
      end

      it "generates plus style tag" do
        root = OpenGraphPlus::Tags::Root.new
        root.plus.style = "padding: 20px; background: white;"

        rendered = described_class.new(root).tags.map(&:to_s).join("\n")

        expect(rendered).to include('<meta property="og:plus:style" content="padding: 20px; background: white;">')
      end

      it "generates plus style tag from hash" do
        root = OpenGraphPlus::Tags::Root.new
        root.plus.style = { padding: "20px", background_color: "white" }

        rendered = described_class.new(root).tags.map(&:to_s).join("\n")

        expect(rendered).to include('<meta property="og:plus:style" content="padding: 20px; background-color: white">')
      end

      it "skips nil plus properties" do
        root = OpenGraphPlus::Tags::Root.new

        tags = described_class.new(root).tags

        expect(tags.map(&:property)).not_to include("og:plus:selector")
        expect(tags.map(&:property)).not_to include("og:plus:style")
      end
    end

    context "twitter tags" do
      it "includes twitter:card with default value" do
        root = OpenGraphPlus::Tags::Root.new

        rendered = described_class.new(root).tags.map(&:to_s).join("\n")

        expect(rendered).to include('<meta property="twitter:card" content="summary_large_image">')
      end

      it "syncs twitter:title from og:title" do
        root = OpenGraphPlus::Tags::Root.new
        root.title = "My Title"

        rendered = described_class.new(root).tags.map(&:to_s).join("\n")

        expect(rendered).to include('<meta property="twitter:title" content="My Title">')
      end

      it "syncs twitter:description from og:description" do
        root = OpenGraphPlus::Tags::Root.new
        root.description = "My Description"

        rendered = described_class.new(root).tags.map(&:to_s).join("\n")

        expect(rendered).to include('<meta property="twitter:description" content="My Description">')
      end

      it "syncs twitter:image from og:image" do
        root = OpenGraphPlus::Tags::Root.new
        root.image_url = "https://example.com/image.png"

        rendered = described_class.new(root).tags.map(&:to_s).join("\n")

        expect(rendered).to include('<meta property="twitter:image" content="https://example.com/image.png">')
      end

      it "allows overriding twitter values" do
        root = OpenGraphPlus::Tags::Root.new
        root.title = "OG Title"
        root.twitter.update(title: "Twitter Title", site: "@example")

        rendered = described_class.new(root).tags.map(&:to_s).join("\n")

        expect(rendered).to include('<meta property="og:title" content="OG Title">')
        expect(rendered).to include('<meta property="twitter:title" content="Twitter Title">')
        expect(rendered).to include('<meta property="twitter:site" content="@example">')
      end
    end
  end
end
