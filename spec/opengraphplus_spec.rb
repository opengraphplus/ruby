# frozen_string_literal: true

RSpec.describe OpenGraphPlus do
  it "has a version number" do
    expect(OpenGraphPlus::VERSION).not_to be nil
  end

  describe ".image_url" do
    after { described_class.reset_configuration! }

    context "with bundled api_key (both keys)" do
      before do
        OpenGraphPlus.configure do |config|
          config.api_key = OpenGraphPlus::APIKey.new(
            public_key: "test_public_key",
            secret_key: "test_secret_key"
          ).to_s
        end
      end

      it "generates a signed image URL" do
        url = OpenGraphPlus.image_url("https://example.com/page")
        expect(url).to include("/image?url=")
      end

      it "passes consumer param through to the signed URL" do
        url = OpenGraphPlus.image_url("https://example.com/page", consumer: "twitter")
        expect(url).to include("consumer=twitter")
      end
    end

    context "with only public_key" do
      before do
        OpenGraphPlus.configure do |config|
          config.public_key = "test_public_key"
        end
      end

      it "generates a domain image URL" do
        url = OpenGraphPlus.image_url("/blog/my-post")
        expect(url).to eq("https://opengraphplus.com/api/websites/v1/domain/test_public_key/image/blog/my-post")
      end
    end

    context "with no keys configured" do
      it "returns nil and warns" do
        expect { @result = OpenGraphPlus.image_url("/page") }
          .to output(/No API key configured.*opengraphplus\.com/).to_stderr
        expect(@result).to be_nil
      end
    end
  end
end
