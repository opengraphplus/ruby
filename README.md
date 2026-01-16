# OpenGraphPlus

OpenGraph+ generates Open Graph tags & images for Rails applications. 

## Installation

Install the gem and add to the application's Gemfile by executing:

```bash
bundle add opengraphplus
```

If bundler is not being used to manage dependencies, install the gem by executing:

```bash
gem install opengraphplus
```

## Usage

### Get your API key

Sign up at [og.plus](https://og.plus) to get your API key.

### Configuration

#### Using environment variables

```bash
rails g opengraphplus:env ogplus_live_████████████████████
```

This will:
- Append `OGPLUS__API_KEY=ogplus_live_████████████████████` to your `.env` file (or the first env file found)
- Create `config/initializers/opengraphplus.rb`

To specify a different env file:

```bash
rails g opengraphplus:env ogplus_live_████████████████████ -e .envrc
```

#### Using Rails credentials

```bash
rails g opengraphplus:credentials ogplus_live_████████████████████
```

This will:
- Add `ogplus.api_key` to your encrypted `credentials.yml.enc`
- Create `config/initializers/opengraphplus.rb`

#### Manual configuration

Run the basic install generator for a commented template:

```bash
rails g opengraphplus:install
```

Then configure manually in `config/initializers/opengraphplus.rb`:

```ruby
OpenGraphPlus.configure do |config|
  config.api_key = ENV["OGPLUS__API_KEY"]
  # or
  config.api_key = Rails.application.credentials.ogplus.api_key
end
```

## Capturing a Different URL

By default, OpenGraphPlus screenshots the current request URL for the `og:image`. To screenshot a different URL (e.g., a public preview page when the main page requires authentication):

```ruby
class ArticlesController < ApplicationController
  open_graph do |og|
    og.title = "My Article"
    og.image.url = open_graph_plus_image_url(url_for(format: :opengraph))
  end
end
```

The `open_graph_plus_image_url` helper is available in both controllers and views. It generates a signed URL that tells OpenGraphPlus to screenshot the provided URL instead of the current request.

## Verifying OpenGraph Tags

You can verify that your pages have the required OpenGraph tags using the included command:

```bash
rails opengraph:verify http://localhost:3000
```

This will fetch the URL and check for required tags (`og:title`, `og:type`, `og:image`, `og:url`), displaying any missing required or recommended tags:

```
Verifying OpenGraph tags at http://localhost:3000...

Found tags:
  og:title       → "My Awesome Site"
  og:type        → "website"
  og:image       → "https://example.com/image.png"
  og:url         → "http://localhost:3000"

✓ All required OpenGraph tags present
```

The command exits with code 0 on success, or 1 if required tags are missing.

## Testing

OpenGraphPlus provides test helpers for both RSpec and Minitest to verify OpenGraph tags in your test suite.

### RSpec

Add to your `spec/spec_helper.rb` or `spec/rails_helper.rb`:

```ruby
require 'opengraphplus/rspec'
```

Then use the matchers in your specs:

```ruby
RSpec.describe "Home page", type: :request do
  it "has all required OpenGraph tags" do
    get "/"
    expect(response.body).to have_open_graph_tags
  end

  it "has the correct title" do
    get "/"
    expect(response.body).to have_og_tag("og:title").with_content("My Site")
  end

  it "has an og:image tag" do
    get "/"
    expect(response.body).to have_og_tag("og:image")
  end
end
```

Available matchers:
- `have_open_graph_tags` - Passes if all required OG tags are present
- `have_og_tag("og:title")` - Passes if the specified tag exists
- `have_og_tag("og:title").with_content("My Title")` - Passes if the tag has the expected content

### Minitest

Add to your test helper:

```ruby
require 'opengraphplus/minitest'

class ActiveSupport::TestCase
  include OpenGraphPlus::Minitest
end
```

Then use the assertions in your tests:

```ruby
class HomePageTest < ActionDispatch::IntegrationTest
  test "has all required OpenGraph tags" do
    get "/"
    assert_open_graph_tags(response.body)
  end

  test "has the correct title" do
    get "/"
    assert_og_tag(response.body, "og:title", "My Site")
  end

  test "has an og:image tag" do
    get "/"
    assert_og_tag(response.body, "og:image")
  end

  test "does not have private tags" do
    get "/"
    refute_og_tag(response.body, "og:private")
  end
end
```

Available assertions:
- `assert_open_graph_tags(html)` - Passes if all required OG tags are present
- `assert_og_tag(html, "og:title")` - Passes if the specified tag exists
- `assert_og_tag(html, "og:title", "My Title")` - Passes if the tag has the expected content
- `refute_og_tag(html, "og:private")` - Passes if the specified tag does not exist

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/opengraphplus/ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/opengraphplus/ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OpenGraphPlus project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/opengraphplus/ruby/blob/main/CODE_OF_CONDUCT.md).
