# frozen_string_literal: true

RSpec.describe OpenGraphPlus::Namespace::Base do
  describe "#tag_for" do
    let(:tags) { OpenGraphPlus::Tags::Root.new }

    before do
      tags.title = "My Title"
      tags.description = "My Description"
    end

    it "finds a tag by property name" do
      tag = tags.tag_for("og:title")

      expect(tag).to be_a(OpenGraphPlus::Tag)
      expect(tag.property).to eq("og:title")
      expect(tag.content).to eq("My Title")
    end

    it "returns nil when tag is not found" do
      tag = tags.tag_for("og:nonexistent")

      expect(tag).to be_nil
    end

    it "finds nested tags" do
      tags.image.url = "https://example.com/image.png"

      tag = tags.tag_for("og:image")

      expect(tag).to be_a(OpenGraphPlus::Tag)
      expect(tag.content).to eq("https://example.com/image.png")
    end

    it "finds twitter tags" do
      tags.twitter.site = "@example"

      tag = tags.tag_for("twitter:site")

      expect(tag).to be_a(OpenGraphPlus::Tag)
      expect(tag.content).to eq("@example")
    end
  end

  describe "#[]" do
    let(:tags) { OpenGraphPlus::Tags::Root.new }

    it "is an alias for tag_for" do
      tags.title = "My Title"

      expect(tags["og:title"]).to eq(tags.tag_for("og:title"))
    end
  end
end
