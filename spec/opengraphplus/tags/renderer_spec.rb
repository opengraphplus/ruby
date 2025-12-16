# frozen_string_literal: true

RSpec.describe OpenGraphPlus::Tags::Renderer do
  describe "#tags" do
    it "returns an array of Tag objects" do
      root = OpenGraphPlus::Tags::Root.new(title: "Test")
      renderer = described_class.new(root)

      tags = renderer.tags

      expect(tags).to all(be_a(OpenGraphPlus::Tag))
    end

    it "generates tags for set properties" do
      root = OpenGraphPlus::Tags::Root.new(
        title: "My Title",
        description: "My Description"
      )
      renderer = described_class.new(root)

      rendered = renderer.tags.map(&:to_s).join("\n")

      expect(rendered).to include('<meta property="og:title" content="My Title">')
      expect(rendered).to include('<meta property="og:description" content="My Description">')
    end

    it "includes default type" do
      root = OpenGraphPlus::Tags::Root.new
      renderer = described_class.new(root)

      rendered = renderer.tags.map(&:to_s).join("\n")

      expect(rendered).to include('<meta property="og:type" content="website">')
    end

    it "skips nil properties" do
      root = OpenGraphPlus::Tags::Root.new(title: "Test")
      renderer = described_class.new(root)

      tags = renderer.tags

      expect(tags.map(&:property)).not_to include("og:description")
    end

    context "with image" do
      it "generates image tags" do
        root = OpenGraphPlus::Tags::Root.new(
          image: {
            url: "https://example.com/image.png",
            width: 1200,
            height: 630,
            type: "image/png",
            alt: "Alt text"
          }
        )
        renderer = described_class.new(root)

        rendered = renderer.tags.map(&:to_s).join("\n")

        expect(rendered).to include('<meta property="og:image" content="https://example.com/image.png">')
        expect(rendered).to include('<meta property="og:image:width" content="1200">')
        expect(rendered).to include('<meta property="og:image:height" content="630">')
        expect(rendered).to include('<meta property="og:image:type" content="image/png">')
        expect(rendered).to include('<meta property="og:image:alt" content="Alt text">')
      end

      it "skips nil image properties" do
        root = OpenGraphPlus::Tags::Root.new(
          image: { url: "https://example.com/image.png" }
        )
        renderer = described_class.new(root)

        tags = renderer.tags

        expect(tags.map(&:property)).to include("og:image")
        expect(tags.map(&:property)).not_to include("og:image:width")
      end
    end
  end
end
