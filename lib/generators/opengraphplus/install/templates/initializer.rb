# frozen_string_literal: true

# Get your API key at https://opengraphplus.com/dashboard
OpenGraphPlus.configure do |config|
  # Use Rails credentials.
  config.api_key = Rails.application.credentials.opengraphplus_api_key

  # Or use ENV:
  # config.api_key = ENV["OPENGRAPHPLUS_API_KEY"]
end
