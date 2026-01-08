# frozen_string_literal: true

require "net/http"

RSpec.describe OpenGraphPlus::Verifier do
  describe "#initialize" do
    it "stores the URL" do
      verifier = described_class.new("http://example.com")
      expect(verifier.url).to eq("http://example.com")
    end
  end

  describe "#verify" do
    let(:html) do
      <<~HTML
        <html>
          <head>
            <meta property="og:title" content="Example">
            <meta property="og:type" content="website">
            <meta property="og:image" content="https://example.com/image.png">
            <meta property="og:url" content="https://example.com">
          </head>
        </html>
      HTML
    end

    it "fetches URL and returns a Parser" do
      success_response = Net::HTTPSuccess.allocate
      allow(success_response).to receive(:body).and_return(html)
      allow(Net::HTTP).to receive(:get_response).and_return(success_response)

      verifier = described_class.new("http://example.com")
      parser = verifier.verify

      expect(parser).to be_a(OpenGraphPlus::Parser)
      expect(parser["og:title"]).to eq("Example")
    end

    it "follows redirects" do
      redirect_response = Net::HTTPRedirection.allocate
      allow(redirect_response).to receive(:[]).with("location").and_return("http://example.com/new")

      success_response = Net::HTTPSuccess.allocate
      allow(success_response).to receive(:body).and_return(html)

      call_count = 0
      allow(Net::HTTP).to receive(:get_response) do
        call_count += 1
        call_count == 1 ? redirect_response : success_response
      end

      verifier = described_class.new("http://example.com")
      parser = verifier.verify

      expect(parser).to be_a(OpenGraphPlus::Parser)
      expect(verifier.url).to eq("http://example.com/new")
    end

    it "raises FetchError on too many redirects" do
      redirect_response = Net::HTTPRedirection.allocate
      allow(redirect_response).to receive(:[]).with("location").and_return("http://example.com/loop")
      allow(Net::HTTP).to receive(:get_response).and_return(redirect_response)

      verifier = described_class.new("http://example.com")

      expect { verifier.verify }.to raise_error(OpenGraphPlus::Verifier::FetchError, /Too many redirects/)
    end

    it "raises FetchError on HTTP errors" do
      error_response = Net::HTTPNotFound.allocate
      allow(error_response).to receive(:code).and_return("404")
      allow(error_response).to receive(:message).and_return("Not Found")
      allow(Net::HTTP).to receive(:get_response).and_return(error_response)

      verifier = described_class.new("http://example.com")

      expect { verifier.verify }.to raise_error(OpenGraphPlus::Verifier::FetchError, /HTTP 404/)
    end

    it "raises FetchError on invalid URL" do
      verifier = described_class.new("://invalid")

      expect { verifier.verify }.to raise_error(OpenGraphPlus::Verifier::FetchError, /Invalid URL/)
    end

    it "raises FetchError on connection errors" do
      allow(Net::HTTP).to receive(:get_response).and_raise(SocketError.new("getaddrinfo: nodename nor servname provided"))

      verifier = described_class.new("http://nonexistent.example.com")

      expect { verifier.verify }.to raise_error(OpenGraphPlus::Verifier::FetchError, /Connection failed/)
    end
  end
end
