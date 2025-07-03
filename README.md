# FollowUpBoss Client

[![Ruby](https://img.shields.io/badge/ruby-%3E%3D%202.7-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/rails-%3E%3D%207.1-red.svg)](https://rubyonrails.org/)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE.txt)
[![Gem Version](https://badge.fury.io/rb/followupboss_client.svg)](https://badge.fury.io/rb/followupboss_client)

A comprehensive Ruby client for the [Follow Up Boss API](https://api.followupboss.com/api-documentation/). This gem provides Rails-like models and methods for seamless integration with Follow Up Boss CRM.

**Enhanced Features:**
- 🚀 Rails 8 compatibility with automatic patches
- 🔐 Secure cookie authentication for SharedInbox
- 📧 Advanced inbox management
- 🛡️ Security-first architecture
- 📱 Comprehensive API coverage (25+ resources)

## Table of Contents

- [Installation](#installation)
- [Quick Start](#quick-start)
- [Authentication](#authentication)
- [Configuration](#configuration)
- [API Reference](#api-reference)
  - [Core Resources](#core-resources)
  - [Communications](#communications)
  - [Tasks & Events](#tasks--events)
  - [Templates & Automation](#templates--automation)
  - [Teams & Users](#teams--users)
  - [Pipelines & Stages](#pipelines--stages)
  - [Attachments & Files](#attachments--files)
  - [Custom Fields](#custom-fields)
  - [Inboxes](#inboxes)
  - [Integration & Webhooks](#integration--webhooks)
- [Advanced Features](#advanced-features)
- [Error Handling](#error-handling)
- [Security Considerations](#security-considerations)
- [Troubleshooting](#troubleshooting)
- [Development](#development)
- [Contributing](#contributing)
- [License](#license)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'followupboss_client'
```

And then execute:

```bash
$ bundle install
```

Or install it directly:

```bash
$ gem install followupboss_client
```

## Quick Start

```ruby
require 'followupboss_client'

# Configure with API key
FubClient.configure do |config|
  config.api_key = 'your_api_key'
end

# Start using the API
people = FubClient::Person.all
deals = FubClient::Deal.active
events = FubClient::Event.find(123)
```

## Authentication

FubClient supports two authentication methods:

### 1. API Key Authentication (Recommended)

The primary authentication method for most API operations.

**Environment Variable:**
```bash
export FUB_API_KEY=your_api_key
```

**Configuration Block:**
```ruby
FubClient.configure do |config|
  config.api_key = 'your_api_key'
end
```

**Direct Assignment:**
```ruby
FubClient::Client.instance.api_key = 'your_api_key'
```

### 2. Cookie Authentication (For Advanced Features)

Required for SharedInbox functionality and other advanced features.

```ruby
# Using CookieClient with GIST encryption
cookie_client = FubClient::CookieClient.new(
  subdomain: 'your_subdomain',
  gist_url: 'https://gist.githubusercontent.com/...',
  encryption_key: 'your_encryption_key'
)

# Or with direct cookie
cookie_client = FubClient::CookieClient.new(
  subdomain: 'your_subdomain',
  cookie: 'your_cookie_string'
)
```

#### Using sync-my-cookie Browser Extension for Cookie Encryption

For secure cookie storage, you can use the [sync-my-cookie browser extension](https://github.com/Andiedie/sync-my-cookie) which uses kevast encryption in the backend:

**Step 1: Install the sync-my-cookie browser extension**
- Install from the Chrome Web Store or Firefox Add-ons
- Or install from source: https://github.com/Andiedie/sync-my-cookie

**Step 2: Configure and sync your cookies**
1. Navigate to your FollowUpBoss subdomain and log in
2. Open the sync-my-cookie browser extension
3. Set up your encryption password/key
4. Configure the extension to sync cookies to a GitHub GIST
5. The extension will automatically encrypt and upload your cookies

**Step 3: Get your GIST URL**
The sync-my-cookie extension will create a GitHub GIST with encrypted cookie data in this format:
```json
{
  "followupboss.com": "encrypted_hex_string_from_kevast"
}
```

**Step 4: Use with FubClient**
```ruby
cookie_client = FubClient::CookieClient.new(
  subdomain: 'your_subdomain',
  gist_url: 'https://gist.githubusercontent.com/username/gist_id/raw/filename.json',
  encryption_key: 'your_encryption_key'  # Same key used in sync-my-cookie
)
```

The FubClient will automatically:
- Fetch the encrypted data from the GIST
- Decrypt it using the same kevast algorithm as sync-my-cookie (AES-128-CBC)
- Process the cookie data for authentication

This approach provides secure, encrypted storage of sensitive cookie data while keeping it accessible for your applications. The sync-my-cookie extension handles the complex cookie extraction, encryption, and GIST synchronization process automatically.

## Configuration

### Global Configuration

```ruby
FubClient.configure do |config|
  # API Key Authentication
  config.api_key = 'your_api_key'
  
  # Cookie Authentication (for SharedInbox)
  config.subdomain = 'your_subdomain'
  config.gist_url = 'https://gist.githubusercontent.com/...'
  config.encryption_key = 'your_encryption_key'
  config.cookie = 'direct_cookie_string'  # Alternative to GIST
end
```

### Environment Variables

Create a `.env` file:

```bash
# API Key Authentication
FUB_API_KEY=your_api_key

# Cookie Authentication
FUB_SUBDOMAIN=your_subdomain
FUB_GIST_URL=https://gist.githubusercontent.com/...
FUB_ENCRYPTION_KEY=your_encryption_key
FUB_COOKIE=direct_cookie_string
```

## API Reference

### Core Resources

#### Person
Manage contacts and leads.

```ruby
# Basic operations
people = FubClient::Person.all
person = FubClient::Person.find(123)
person = FubClient::Person.create(name: 'John Doe', email: 'john@example.com')

# Pagination
people = FubClient::Person.by_page(2, 10)  # page 2, 10 per page

# Total count
total = FubClient::Person.total
```

#### Deal
Manage deals and opportunities.

```ruby
# Deal status filtering
active_deals = FubClient::Deal.active
won_deals = FubClient::Deal.won
lost_deals = FubClient::Deal.lost

# Relationships
deal = FubClient::Deal.find(123)
people = deal.people
property = deal.property
```

#### Property
Manage property listings.

```ruby
properties = FubClient::Property.all
property = FubClient::Property.find(123)
property = FubClient::Property.create(
  address: '123 Main St',
  city: 'Anytown',
  state: 'CA',
  zip: '12345'
)
```

### Communications

#### Message
Handle email communications.

```ruby
# Get messages
messages = FubClient::Message.all
unread = FubClient::Message.unread
with_attachments = FubClient::Message.with_attachments

# Mark as read
message = FubClient::Message.find(123)
message.mark_as_read

# Relationships
person = message.person
user = message.user
```

#### TextMessage
Manage SMS communications.

```ruby
# Get text messages
texts = FubClient::TextMessage.all
unread = FubClient::TextMessage.unread

# Send a text message
FubClient::TextMessage.send_message(
  person_id: 123,
  message: 'Hello from Follow Up Boss!',
  user_id: 456
)

# Mark as read
text = FubClient::TextMessage.find(123)
text.mark_as_read
```

#### Call
Track phone calls.

```ruby
calls = FubClient::Call.all
call = FubClient::Call.find(123)
call = FubClient::Call.create(
  person_id: 123,
  user_id: 456,
  duration: 300,
  notes: 'Great conversation about their home search'
)
```

### Tasks & Events

#### Task
Manage tasks and to-dos.

```ruby
# Get tasks
tasks = FubClient::Task.all
overdue = FubClient::Task.overdue

# Create a task
task = FubClient::Task.create(
  person_id: 123,
  user_id: 456,
  subject: 'Follow up on property showing',
  due_date: Date.tomorrow
)
```

#### Event
Track events and activities.

```ruby
events = FubClient::Event.all
event = FubClient::Event.find(123)

# Get total events
total = FubClient::Event.total
```

#### Appointment
Manage appointments and showings.

```ruby
# Get appointments
upcoming = FubClient::Appointment.upcoming
past = FubClient::Appointment.past

# Create appointment
appointment = FubClient::Appointment.create(
  person_id: 123,
  user_id: 456,
  start_time: Time.now + 1.day,
  end_time: Time.now + 1.day + 1.hour,
  subject: 'Property showing'
)

# Complete appointment
appointment.complete(outcome_id: 1, notes: 'Successful showing')

# Relationships
person = appointment.person
user = appointment.user
```

### Templates & Automation

#### EmailTemplate
Manage email templates.

```ruby
templates = FubClient::EmailTemplate.all
template = FubClient::EmailTemplate.find(123)

# Get total templates
total = FubClient::EmailTemplate.total
```

#### TextMessageTemplate
Manage SMS templates.

```ruby
# Get templates
active = FubClient::TextMessageTemplate.active
inactive = FubClient::TextMessageTemplate.inactive

# Use template
template = FubClient::TextMessageTemplate.find(123)
merged = template.merge(person_id: 456)  # Merge with person data
template.send_to(person_id: 456, user_id: 789)  # Send directly
```

#### ActionPlan
Manage automated action plans.

```ruby
plans = FubClient::ActionPlan.all
plan = FubClient::ActionPlan.find(123)
```

### Teams & Users

#### User
Manage users and agents.

```ruby
users = FubClient::User.all
user = FubClient::User.find(123)
```

#### Team
Manage teams and groups.

```ruby
# Get teams
teams = FubClient::Team.all
active_teams = FubClient::Team.active

# Team management
team = FubClient::Team.find(123)
members = team.members
stats = team.stats

# Add/remove members
team.add_user(user_id: 456, team_leader: true)
team.remove_user(user_id: 456)
```

#### Group
Manage user groups.

```ruby
# Get groups
groups = FubClient::Group.all
active = FubClient::Group.active
round_robin = FubClient::Group.round_robin

# Group management
group = FubClient::Group.find(123)
members = group.members
group.add_user(456)
group.remove_user(456)
```

#### Identity
Get current user information.

```ruby
current = FubClient::Identity.current
user = current.user
teams = current.teams

# Check permissions
has_permission = current.has_permission?('manage_deals')
```

### Pipelines & Stages

#### Pipeline
Manage deal pipelines.

```ruby
# Get pipelines
pipelines = FubClient::Pipeline.all
active = FubClient::Pipeline.active
inactive = FubClient::Pipeline.inactive

# Pipeline details
pipeline = FubClient::Pipeline.find(123)
stages = pipeline.stages
deals = pipeline.deals
stats = pipeline.stats

# Reorder pipeline
pipeline.move_to_position(2)

# Update stages
pipeline.update_stages([
  { id: 1, name: 'Lead', position: 1 },
  { id: 2, name: 'Qualified', position: 2 }
])
```

#### Stage
Manage pipeline stages.

```ruby
# Get stages
stages = FubClient::Stage.all
active = FubClient::Stage.active
inactive = FubClient::Stage.inactive

# Stage details
stage = FubClient::Stage.find(123)
deals = stage.deals
count = stage.deal_count

# Reorder stage
stage.move_to_position(3)
```

### Attachments & Files

#### PersonAttachment
Manage person attachments.

```ruby
# Upload attachment
attachment = FubClient::PersonAttachment.upload(
  person_id: 123,
  file_path: '/path/to/file.pdf',
  name: 'Contract',
  type: 'application/pdf',
  description: 'Signed contract'
)

# Download attachment
attachment = FubClient::PersonAttachment.find(123)
file_data = attachment.download

# Get person
person = attachment.person

# Delete attachment
attachment.delete
```

#### DealAttachment
Manage deal attachments.

```ruby
# Upload attachment
attachment = FubClient::DealAttachment.upload(
  deal_id: 123,
  file_path: '/path/to/document.pdf',
  name: 'Purchase Agreement',
  type: 'application/pdf'
)

# Download and delete
file_data = attachment.download
attachment.delete

# Get associated deal
deal = attachment.deal
```

### Custom Fields

#### CustomField
Manage custom field definitions.

```ruby
fields = FubClient::CustomField.all
field = FubClient::CustomField.find(123)
```

#### DealCustomField
Manage deal-specific custom fields.

```ruby
# Get custom fields
active = FubClient::DealCustomField.active
inactive = FubClient::DealCustomField.inactive

# Update custom field
field = FubClient::DealCustomField.find(123)
field.update(name: 'Updated Field Name', required: true)

# Delete custom field
field.delete
```

### Inboxes

#### SharedInbox
Manage shared team inboxes (requires cookie authentication).

```ruby
# Setup cookie authentication first
cookie_client = FubClient::CookieClient.new(
  subdomain: 'your_subdomain',
  gist_url: 'your_gist_url',
  encryption_key: 'your_key'
)

# Get all shared inboxes
inboxes = FubClient::SharedInbox.all_inboxes

# Get specific inbox
inbox = FubClient::SharedInbox.get_inbox(123)

# Inbox operations
messages = inbox.messages(limit: 10, offset: 0)
conversations = inbox.conversations(limit: 10, offset: 0)
settings = inbox.settings

# Update settings
inbox.update_settings({
  auto_assign: true,
  notification_email: 'team@example.com'
})
```

#### TeamInbox
Manage team-specific inboxes.

```ruby
# Get all team inboxes
inboxes = FubClient::TeamInbox.all_inboxes

# Inbox operations
inbox = FubClient::TeamInbox.find(123)
team = inbox.team
messages = inbox.messages(limit: 10)

# Conversation management
participants = inbox.participants(conversation_id: 456)
inbox.add_message(
  conversation_id: 456,
  content: 'Thanks for your inquiry!',
  user_id: 789
)
```

### Integration & Webhooks

#### Webhook
Manage webhooks for real-time notifications.

```ruby
# Get webhooks
webhooks = FubClient::Webhook.all
active = FubClient::Webhook.active
inactive = FubClient::Webhook.inactive

# Webhook management
webhook = FubClient::Webhook.find(123)
events = webhook.events(limit: 10)

# Control webhook status
webhook.activate
webhook.deactivate
webhook.test  # Send test event
```

### Smart Lists

#### SmartList
Manage dynamic contact lists.

```ruby
lists = FubClient::SmartList.all
list = FubClient::SmartList.find(123)
```

## Advanced Features

### Rails 8 Compatibility

FubClient includes automatic compatibility patches for Rails 8:

- ActiveSupport::BasicObject compatibility
- Her gem middleware compatibility  
- JSON parsing compatibility

No additional configuration required - patches are applied automatically.

### Pagination and Bulk Operations

```ruby
# Pagination with Her::Model::Relation
people = FubClient::Person.by_page(1, 50)
people.each { |person| puts person.name }

# Safe operations (with error handling)
people = FubClient::Person.safe_all
total = FubClient::Person.total

# Method chaining
active_deals = FubClient::Deal.active.where(stage: 'qualified')
```

### Batch Processing

```ruby
# Process large datasets efficiently
FubClient::Person.by_page(1, 100).each do |person|
  # Process each person
  puts "Processing #{person.name}"
end
```

## Error Handling

```ruby
begin
  person = FubClient::Person.find(123)
rescue Her::Errors::ResourceNotFound
  puts "Person not found"
rescue Her::Errors::TimeoutError
  puts "Request timed out"
rescue StandardError => e
  puts "Error: #{e.message}"
end

# Safe operations
people = FubClient::Person.safe_all
if people.nil?
  puts "Failed to fetch people"
else
  puts "Found #{people.count} people"
end
```

## Security Considerations

### API Key Security

- **Never commit API keys to version control**
- Use environment variables or secure credential storage
- Rotate API keys regularly
- Limit API key permissions to minimum required

### Cookie Authentication Security

- Cookie authentication is required for SharedInbox features
- Cookies are encrypted and stored securely
- Use HTTPS in production environments
- Implement proper session management

### Best Practices

```ruby
# ✅ Good - Use environment variables
FubClient.configure do |config|
  config.api_key = ENV['FUB_API_KEY']
  config.subdomain = ENV['FUB_SUBDOMAIN']
end

# ❌ Bad - Hard-coded credentials
FubClient.configure do |config|
  config.api_key = 'hardcoded_key'  # Never do this!
end
```

## Troubleshooting

### Common Issues

#### Authentication Errors
```ruby
# Check configuration
config = FubClient.configuration
puts config.auth_summary

# Verify API key
puts "API Key configured: #{config.has_api_key_auth?}"
puts "Cookie Auth configured: #{config.has_cookie_auth?}"
```

#### Connection Issues
```ruby
# Test basic connectivity
begin
  FubClient::User.all
  puts "Connection successful"
rescue => e
  puts "Connection failed: #{e.message}"
end
```

#### SharedInbox Issues
```ruby
# Verify cookie authentication
cookie_client = FubClient::CookieClient.new(
  subdomain: ENV['FUB_SUBDOMAIN'],
  gist_url: ENV['FUB_GIST_URL'],
  encryption_key: ENV['FUB_ENCRYPTION_KEY']
)

if cookie_client.cookies
  puts "Cookie authentication successful"
else
  puts "Cookie authentication failed"
end
```

### Debug Mode

Enable debug output:

```ruby
ENV['DEBUG'] = 'true'
# Now all requests will show detailed debug information
```

### Rate Limiting

Follow Up Boss API has rate limits. Implement proper retry logic:

```ruby
def with_retry(max_retries: 3)
  retries = 0
  begin
    yield
  rescue Her::Errors::TooManyRequests => e
    retries += 1
    if retries <= max_retries
      sleep(2 ** retries)  # Exponential backoff
      retry
    else
      raise e
    end
  end
end

# Usage
with_retry do
  people = FubClient::Person.all
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests.

```bash
# Setup development environment
git clone https://github.com/connorgallopo/followupboss_client.git
cd followupboss_client
bin/setup

# Run tests
rake spec

# Interactive console
bin/console

# Install locally
bundle exec rake install
```

### Running Examples

Check out the example scripts:

```bash
# API key authentication example
ruby scripts/test_api.rb

# SharedInbox with cookie authentication
ruby scripts/test_shared_inbox.rb
```

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass (`rake spec`)
6. Commit your changes (`git commit -am 'Add amazing feature'`)
7. Push to the branch (`git push origin feature/amazing-feature`)
8. Open a Pull Request

### Code Style

- Follow Ruby community style guidelines
- Add documentation for new methods
- Include examples in documentation
- Maintain backward compatibility when possible

### Security

- Never commit sensitive credentials
- Follow secure coding practices
- Report security issues privately to maintainers

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

---

## Links

- [Follow Up Boss API Documentation](https://api.followupboss.com/api-documentation/)
- [Follow Up Boss Website](https://www.followupboss.com)
- [GitHub Repository](https://github.com/connorgallopo/followupboss_client)
- [Issue Tracker](https://github.com/connorgallopo/followupboss_client/issues)

---

**Made with ❤️ for the real estate community**
