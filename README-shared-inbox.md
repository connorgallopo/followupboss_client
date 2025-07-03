# FubClient SharedInbox Extension

This extension adds support for accessing the FollowUpBoss SharedInbox API using cookie-based authentication.

## Features

- Cookie-based authentication for FollowUpBoss
- Support for subdomain-specific endpoints 
- SharedInbox resource for interacting with the shared inbox API
- Backward compatibility with existing API key authentication

## Usage

### Setup and Authentication

#### Option 1: Use Cookie Authentication (Recommended)

```ruby
require 'fub_client'
require 'dotenv'
Dotenv.load

# Initialize the cookie client
# By default it will use a working cookie directly
client = FubClient::CookieClient.new()

# Set the subdomain for the account
client.subdomain = 'your_subdomain'

# That's it! The cookie client is configured and ready to use
```

The CookieClient comes pre-configured with a working cookie that can access shared inboxes without requiring login. It references a gist URL for possible future updates:

```
https://gist.githubusercontent.com/***REMOVED***/***REMOVED***/raw/fd866d47dbe218790b81884f12ad7e17bc9fe144/kevast-gist-default.json
```

You can also specify your own cookie directly if needed:

```ruby
# If you have your own cookie string
client = FubClient::CookieClient.new()
client.cookies = "your_cookie_string_here"
client.subdomain = 'your_subdomain'
```

#### Option 2: Login with Credentials

```ruby
require 'fub_client'
require 'dotenv'
Dotenv.load

# Initialize the client (singleton)
client = FubClient::Client.instance

# Login with credentials to obtain cookies
login_success = client.login('your_email@example.com', 'your_password')

# Set the subdomain for the account
client.subdomain = 'your_subdomain'
```

#### Option 2: Use Cookie from Gist

You can use a cookie stored in a JSON file in a GitHub Gist, which allows for easier cookie management and sharing:

```ruby
require 'fub_client'
require 'dotenv'
Dotenv.load

# Initialize the cookie client with options
# Parameters:
# - gist_url: URL to the gist containing the cookie (optional, default provided)
# - cookie_format: How to format the cookie value ('raw', 'fbs3e-token', or custom format)
client = FubClient::CookieClient.new(
  ENV['COOKIE_GIST_URL'],  # Optional: defaults to pre-defined URL if nil
  ENV['COOKIE_FORMAT']     # Optional: defaults to 'fbs3e-token' if nil
)

# Set the subdomain for the account
client.subdomain = 'your_subdomain'

# The cookie client automatically configures the singleton Client.instance
# No need to manually set the client instance
```

The default gist URL is:
```
https://gist.githubusercontent.com/***REMOVED***/***REMOVED***/raw/fd866d47dbe218790b81884f12ad7e17bc9fe144/kevast-gist-default.json
```

The JSON format for the cookie in the gist should be:
```json
{
  "followupboss.com": "cookie-value-here",
  "__DOMAIN_LIST__": "some-domain-hash"
}
```

**Cookie Format Options**:

The CookieClient supports different formats for the cookie value:

1. `'fbs3e-token'` (default): The cookie value from the gist will be formatted as `fbs3e-token=VALUE`
2. `'raw'`: Use the cookie value exactly as it appears in the gist without any modifications
3. A custom format with `%s`: Replace `%s` with the cookie value, e.g., `mycookie=%s`
4. Any other string: Will be treated as a cookie name, e.g., passing `'mycookie'` will format as `mycookie=VALUE`

**Handling Encrypted Cookies**:

The CookieClient can handle both encrypted and unencrypted cookie values:

1. It first tries to use the cookie value directly from the gist
2. If that doesn't work, it attempts to decrypt the value using AES-128-CBC with the key "***REMOVED***"
3. For encrypted data from the [sync-my-cookie](https://github.com/Andiedie/sync-my-cookie) Chrome extension:
   - The decryption process extracts an array of cookie objects
   - Each object contains name, value, and other cookie properties
   - These are automatically converted to a cookie string in the format "name1=value1; name2=value2; ..."

This implementation works seamlessly with cookies exported and encrypted by the sync-my-cookie Chrome extension, which stores domain cookies as an encrypted JSON array.

### Working with Shared Inboxes

```ruby
# Get all shared inboxes
inboxes = FubClient::SharedInbox.all_inboxes

# Get a specific shared inbox
inbox = FubClient::SharedInbox.get_inbox(1)

# Get settings for a specific inbox
settings = inbox.settings

# Get messages for a specific inbox
messages = inbox.messages

# Get conversations for a specific inbox
conversations = inbox.conversations
```

## How It Works

The extension introduces a dual authentication system:

1. **API Key Authentication**: Continues to work for all existing endpoints
2. **Cookie Authentication**: Used for the shared inbox endpoints that require web session cookies

The system automatically selects the appropriate authentication method based on whether cookies are available. When cookies are present and a subdomain is set, requests are routed to the subdomain-specific endpoint using cookie-based authentication.

## Testing

A test script is included to validate the functionality:

```bash
ruby scripts/test_shared_inbox.rb
```

This script will:
1. Login to obtain cookies
2. Set the subdomain
3. Fetch and display shared inboxes
4. Fetch details for a specific inbox

## Implementation Details

- `FubClient::Middleware::CookieAuthentication`: Middleware for adding cookies to requests
- `FubClient::SharedInbox`: Resource class for interacting with the shared inbox API
- `FubClient::Client`: Enhanced to support both authentication methods and subdomain-specific endpoints
