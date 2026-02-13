# frozen_string_literal: true

# Get your API key at https://opengraphplus.com/dashboard
OpenGraphPlus.configure do |config|
  # Use Rails credentials.
  config.api_key = Rails.application.credentials.ogplus_api_key

  # Or use ENV:
  # config.api_key = ENV["OGPLUS__API_KEY"]

  # Set base_url for static site generators (e.g., Sitepress) where
  # request.url is not available at compile time:
  # config.base_url = "https://example.com"
end
