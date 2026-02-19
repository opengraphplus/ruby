# frozen_string_literal: true

# Get your public key at https://opengraphplus.com/dashboard
OpenGraphPlus.configure do |config|
<% if public_key.present? -%>
  config.public_key = "<%= public_key %>"
<% else -%>
  # config.public_key = "your_public_key_here"
<% end -%>
end
