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
rails g opengraphplus:env ogp_live_████████████████████
```

This will:
- Append `OPENGRAPHPLUS__API_KEY=ogp_live_████████████████████` to your `.env` file (or the first env file found)
- Create `config/initializers/opengraphplus.rb`

To specify a different env file:

```bash
rails g opengraphplus:env ogp_live_████████████████████ -e .envrc
```

#### Using Rails credentials

```bash
rails g opengraphplus:credentials ogp_live_████████████████████
```

This will:
- Add `opengraphplus.api_key` to your encrypted `credentials.yml.enc`
- Create `config/initializers/opengraphplus.rb`

#### Manual configuration

Run the basic install generator for a commented template:

```bash
rails g opengraphplus:install
```

Then configure manually in `config/initializers/opengraphplus.rb`:

```ruby
OpenGraphPlus.configure do |config|
  config.api_key = ENV["OPENGRAPHPLUS__API_KEY"]
  # or
  config.api_key = Rails.application.credentials.opengraphplus.api_key
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/opengraphplus/ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/opengraphplus/ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OpenGraphPlus project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/opengraphplus/ruby/blob/main/CODE_OF_CONDUCT.md).
