# frozen_string_literal: true

require "action_view"

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

    it "escapes HTML in property to prevent attribute breakout" do
      tag = described_class.new("og:title\" onclick=\"alert('xss')", "Test")
      # The quote should be escaped, preventing attribute breakout
      expect(tag.meta).to include("og:title&quot; onclick=&quot;")
      expect(tag.meta).not_to match(/property="[^"]*" onclick="/)
    end

    it "escapes quotes in content to prevent attribute breakout" do
      tag = described_class.new("og:title", "Test\" onclick=\"alert('xss')")
      # The quote should be escaped, preventing attribute breakout
      expect(tag.meta).to include("Test&quot; onclick=&quot;")
      expect(tag.meta).not_to match(/content="[^"]*" onclick="/)
    end
  end

  describe "#render_in" do
    let(:view_context) do
      Class.new do
        include ActionView::Helpers::OutputSafetyHelper
      end.new
    end

    it "returns an html_safe string" do
      tag = described_class.new("og:title", "Test")
      result = tag.render_in(view_context)

      expect(result).to be_html_safe
    end

    it "returns the meta tag content" do
      tag = described_class.new("og:title", "My Title")
      result = tag.render_in(view_context)

      expect(result).to eq('<meta property="og:title" content="My Title">')
    end
  end

  describe "#to_s" do
    it "delegates to meta" do
      tag = described_class.new("og:description", "A description")
      expect(tag.to_s).to eq(tag.meta)
    end
  end
end
