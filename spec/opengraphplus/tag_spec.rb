# frozen_string_literal: true

RSpec.describe OpenGraphPlus::Tag do
  describe "#initialize" do
    it "stores property and content" do
      tag = described_class.new("og:title", "My Title")
      expect(tag.property).to eq("og:title")
      expect(tag.content).to eq("My Title")
    end
  end

  describe "#meta" do
    it "renders a meta tag" do
      tag = described_class.new("og:title", "My Title")
      expect(tag.meta).to eq('<meta property="og:title" content="My Title">')
    end

    it "escapes HTML in content" do
      tag = described_class.new("og:title", "<script>alert('xss')</script>")
      expect(tag.meta).to include("&lt;script&gt;")
      expect(tag.meta).not_to include("<script>")
    end
  end

  describe "#render_in" do
    it "returns the meta tag when no view_context" do
      tag = described_class.new("og:title", "My Title")
      expect(tag.render_in).to eq('<meta property="og:title" content="My Title">')
    end

    it "uses view_context.raw when available" do
      tag = described_class.new("og:title", "Test")
      view_context = double("view_context")
      allow(view_context).to receive(:raw).with(tag.meta).and_return("raw_result")

      expect(tag.render_in(view_context)).to eq("raw_result")
    end

    it "uses html_safe when view_context lacks raw but string responds to html_safe" do
      tag = described_class.new("og:title", "Test")
      view_context = double("view_context")

      result = tag.render_in(view_context)
      expect(result).to eq(tag.meta)
    end
  end

  describe "#to_s" do
    it "delegates to meta" do
      tag = described_class.new("og:description", "A description")
      expect(tag.to_s).to eq(tag.meta)
    end
  end
end
