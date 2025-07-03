# FubClient

This gem is a Ruby Client for [Follow Up Boss API](https://api.followupboss.com/api-documentation/)
For more information about Follow Up Boss go to [www.followupboss.com](www.followupboss.com)

## Installation

**Note: This is a forked version with additional features and Rails 8 compatibility. Install from GitHub until published to RubyGems.**

Add this line to your application's Gemfile:

```ruby
gem 'fub_client', git: 'https://github.com/gallopo-solutions/fub_client.git'
```

And then execute:

    $ bundle

Or install directly from GitHub:

    $ gem install specific_install
    $ gem specific_install https://github.com/gallopo-solutions/fub_client.git

## Usage

After installing the gem, you can start consuming FUB resources as Rails like 
models with shorthand methods based on [Her](https://github.com/remiprev/her) 
models:

```ruby
# Get one event 
event = FubClient::Event.find 12

# Paginate (offset calculated)
persons = FubClient::Person.by_page 2, 10
# => Her::Model::Relation<Person>

# Total (from all records)
total = FubClient::EmailTemplate.total
# => 323
```

## Authentication

FubClient supports two authentication methods:

### 1. API Key Authentication (Recommended for most use cases)

Put your API key in an environment variable named FUB_API_KEY:
```bash
$ export FUB_API_KEY=your_key
```

Or set it up via the client instance:

```ruby
FubClient::Client.instance.api_key = 'your_key'
```

### 2. Cookie Authentication (For SharedInbox and advanced features)

For accessing SharedInbox functionality and other features that require cookie authentication, you can use the CookieClient:

```ruby
# Using environment variables
cookie_client = FubClient::CookieClient.new(
  subdomain: ENV['FUB_SUBDOMAIN'],
  gist_url: ENV['FUB_GIST_URL'],
  encryption_key: ENV['FUB_ENCRYPTION_KEY']
)

# Configure the global client with cookies
client = FubClient::Client.instance
client.cookies = cookie_client.cookies
client.subdomain = ENV['FUB_SUBDOMAIN']
```

## Configuration

You can configure FubClient globally using the configuration block:

```ruby
FubClient.configure do |config|
  config.api_key = 'your_api_key'
  config.subdomain = 'your_subdomain'
  config.gist_url = 'https://gist.githubusercontent.com/...'
  config.encryption_key = 'your_encryption_key'
end
```

Or using environment variables in your `.env` file:

```bash
FUB_API_KEY=your_api_key
FUB_SUBDOMAIN=your_subdomain
FUB_GIST_URL=https://gist.githubusercontent.com/...
FUB_ENCRYPTION_KEY=your_encryption_key
```

## SharedInbox Support

FubClient includes support for SharedInbox functionality with cookie authentication:

```ruby
# Get all shared inboxes
inboxes = FubClient::SharedInbox.all_inboxes

# Get a specific inbox
inbox = FubClient::SharedInbox.get_inbox(123)

# Get inbox messages
messages = inbox.messages(limit: 10, offset: 0)

# Get inbox conversations
conversations = inbox.conversations(limit: 10, offset: 0)

# Get inbox settings
settings = inbox.settings

# Update inbox settings
inbox.update_settings({ setting_key: 'value' })
```

## Rails 8 Compatibility

FubClient includes compatibility patches for Rails 8, ensuring smooth operation with the latest Rails version. The gem automatically detects and applies necessary patches for:

- ActiveSupport::BasicObject compatibility
- Her gem middleware compatibility
- JSON parsing compatibility

## Examples

Check out the example scripts in the `scripts/` directory:

- `scripts/test_api.rb` - Example using API key authentication
- `scripts/test_shared_inbox.rb` - Example using cookie authentication with SharedInbox

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/gallopo-solutions/fub_client. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
