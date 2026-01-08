# frozen_string_literal: true

RSpec.describe OpenGraphPlus::Parser do
  describe "#initialize" do
    it "parses HTML and extracts meta tags" do
      html = <<~HTML
        <html>
          <head>
            <meta property="og:title" content="My Title">
            <meta property="og:type" content="website">
          </head>
        </html>
      HTML

      parser = described_class.new(html)
      expect(parser["og:title"]).to eq("My Title")
      expect(parser["og:type"]).to eq("website")
    end

    it "handles nil input" do
      parser = described_class.new(nil)
      expect(parser.all_tags).to be_empty
    end
  end

  describe "#og_tags" do
    it "returns only og: prefixed tags" do
      html = <<~HTML
        <meta property="og:title" content="Title">
        <meta name="twitter:card" content="summary">
      HTML

      parser = described_class.new(html)
      expect(parser.og_tags).to eq({ "og:title" => "Title" })
    end
  end

  describe "#twitter_tags" do
    it "returns only twitter: prefixed tags" do
      html = <<~HTML
        <meta property="og:title" content="Title">
        <meta name="twitter:card" content="summary">
        <meta name="twitter:site" content="@example">
      HTML

      parser = described_class.new(html)
      expect(parser.twitter_tags).to eq({
        "twitter:card" => "summary",
        "twitter:site" => "@example"
      })
    end
  end

  describe "#[]" do
    it "returns content for a given property" do
      html = '<meta property="og:title" content="Hello">'
      parser = described_class.new(html)
      expect(parser["og:title"]).to eq("Hello")
    end

    it "returns nil for missing property" do
      parser = described_class.new("")
      expect(parser["og:missing"]).to be_nil
    end
  end

  describe "#valid?" do
    it "returns true when all required tags are present" do
      html = <<~HTML
        <meta property="og:title" content="Title">
        <meta property="og:type" content="website">
        <meta property="og:image" content="https://example.com/image.png">
        <meta property="og:url" content="https://example.com">
      HTML

      parser = described_class.new(html)
      expect(parser).to be_valid
    end

    it "returns false when required tags are missing" do
      html = '<meta property="og:title" content="Title">'
      parser = described_class.new(html)
      expect(parser).not_to be_valid
    end
  end

  describe "#errors" do
    it "returns list of missing required tags" do
      html = '<meta property="og:title" content="Title">'
      parser = described_class.new(html)
      expect(parser.errors).to contain_exactly("og:type", "og:image", "og:url")
    end

    it "returns empty array when all required tags present" do
      html = <<~HTML
        <meta property="og:title" content="Title">
        <meta property="og:type" content="website">
        <meta property="og:image" content="https://example.com/image.png">
        <meta property="og:url" content="https://example.com">
      HTML

      parser = described_class.new(html)
      expect(parser.errors).to be_empty
    end
  end

  describe "#warnings" do
    it "returns list of missing recommended tags" do
      html = <<~HTML
        <meta property="og:title" content="Title">
        <meta property="og:type" content="website">
        <meta property="og:image" content="https://example.com/image.png">
        <meta property="og:url" content="https://example.com">
      HTML

      parser = described_class.new(html)
      expect(parser.warnings).to include("og:description", "twitter:card")
    end

    it "excludes tags that are present" do
      html = <<~HTML
        <meta property="og:description" content="A description">
        <meta name="twitter:card" content="summary_large_image">
      HTML

      parser = described_class.new(html)
      expect(parser.warnings).not_to include("og:description", "twitter:card")
    end
  end

  describe "HTML parsing edge cases" do
    it "handles reversed attribute order" do
      html = '<meta content="My Title" property="og:title">'
      parser = described_class.new(html)
      expect(parser["og:title"]).to eq("My Title")
    end

    it "handles single quotes" do
      html = "<meta property='og:title' content='My Title'>"
      parser = described_class.new(html)
      expect(parser["og:title"]).to eq("My Title")
    end

    it "handles twitter name attribute" do
      html = '<meta name="twitter:card" content="summary">'
      parser = described_class.new(html)
      expect(parser["twitter:card"]).to eq("summary")
    end

    it "decodes HTML entities" do
      html = '<meta property="og:title" content="Tom &amp; Jerry">'
      parser = described_class.new(html)
      expect(parser["og:title"]).to eq("Tom & Jerry")
    end

    it "decodes quote entities" do
      html = '<meta property="og:title" content="He said &quot;Hello&quot;">'
      parser = described_class.new(html)
      expect(parser["og:title"]).to eq('He said "Hello"')
    end

    it "ignores non-OG/Twitter meta tags" do
      html = <<~HTML
        <meta name="viewport" content="width=device-width">
        <meta name="description" content="Page description">
        <meta property="og:title" content="Title">
      HTML

      parser = described_class.new(html)
      expect(parser.all_tags.keys).to eq(["og:title"])
    end

    it "handles multiline meta tags" do
      html = <<~HTML
        <meta
          property="og:title"
          content="My Title">
      HTML

      parser = described_class.new(html)
      expect(parser["og:title"]).to eq("My Title")
    end

    it "handles extra whitespace in attributes" do
      html = '<meta property = "og:title" content  =  "My Title">'
      parser = described_class.new(html)
      expect(parser["og:title"]).to eq("My Title")
    end
  end
end
