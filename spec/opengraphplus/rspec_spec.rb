# frozen_string_literal: true

require "opengraphplus/rspec"

RSpec.describe OpenGraphPlus::RSpec do
  let(:valid_html) do
    <<~HTML
      <html>
        <head>
          <meta property="og:title" content="My Title">
          <meta property="og:type" content="website">
          <meta property="og:image" content="https://example.com/image.png">
          <meta property="og:url" content="https://example.com">
        </head>
      </html>
    HTML
  end

  let(:invalid_html) do
    <<~HTML
      <html>
        <head>
          <meta property="og:title" content="My Title">
        </head>
      </html>
    HTML
  end

  describe "have_open_graph_tags matcher" do
    it "passes when all required tags are present" do
      expect(valid_html).to have_open_graph_tags
    end

    it "fails when required tags are missing" do
      expect {
        expect(invalid_html).to have_open_graph_tags
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /missing: og:type, og:image, og:url/)
    end

    it "supports negation" do
      expect(invalid_html).not_to have_open_graph_tags
    end
  end

  describe "have_og_tag matcher" do
    it "passes when tag is present" do
      expect(valid_html).to have_og_tag("og:title")
    end

    it "fails when tag is missing" do
      expect {
        expect(valid_html).to have_og_tag("og:missing")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /og:missing tag, but it was not found/)
    end

    it "supports negation" do
      expect(valid_html).not_to have_og_tag("og:missing")
    end

    describe "with_content chain" do
      it "passes when content matches" do
        expect(valid_html).to have_og_tag("og:title").with_content("My Title")
      end

      it "fails when content does not match" do
        expect {
          expect(valid_html).to have_og_tag("og:title").with_content("Wrong Title")
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected og:title to have content "Wrong Title", but got "My Title"/)
      end

      it "fails when tag is missing" do
        expect {
          expect(valid_html).to have_og_tag("og:missing").with_content("Something")
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /og:missing tag, but it was not found/)
      end

      it "supports negation for content" do
        expect(valid_html).not_to have_og_tag("og:title").with_content("Wrong Title")
      end
    end
  end
end
