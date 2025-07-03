# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-07

### Major Release - Enhanced Fork

This is the first major release of the enhanced `followupboss_client` gem, a comprehensive fork and expansion of the original `fub_client` gem with significant improvements and new features.

### Added

#### 🚀 Rails 8 Compatibility
- Automatic compatibility patches for Rails 8
- ActiveSupport::BasicObject compatibility fixes
- Her gem middleware compatibility patches
- JSON parsing compatibility improvements

#### 🔐 Secure Cookie Authentication
- New `CookieClient` class for advanced authentication
- Support for GIST-based encrypted cookie storage
- Integration with sync-my-cookie browser extension
- Kevast encryption/decryption support for secure cookie handling
- SharedInbox functionality requiring cookie authentication

#### 📧 Advanced Inbox Management
- `SharedInbox` resource with full CRUD operations
- `TeamInbox` resource for team-specific inbox management
- Inbox message and conversation management
- Inbox settings configuration

#### 📱 Comprehensive API Coverage
- **Core Resources**: Person, Deal, Property with enhanced methods
- **Communications**: Message, TextMessage, Call with advanced features
- **Tasks & Events**: Task, Event, Appointment with completion tracking
- **Templates & Automation**: EmailTemplate, TextMessageTemplate, ActionPlan
- **Teams & Users**: User, Team, Group with member management
- **Pipelines & Stages**: Pipeline, Stage with reordering and statistics
- **Attachments**: PersonAttachment, DealAttachment with upload/download
- **Custom Fields**: CustomField, DealCustomField management
- **Integration**: Webhook, SmartList support

#### 🛡️ Security Enhancements
- Secure credential management
- Environment variable configuration
- Encrypted cookie storage
- Proper authentication handling

#### 🔧 Enhanced Features
- Pagination support with `by_page` method
- Safe operations with error handling
- Method chaining for complex queries
- Batch processing capabilities
- Debug mode support
- Comprehensive error handling

#### 📚 Documentation & Examples
- Extensive README with usage examples
- Security best practices documentation
- Troubleshooting guide
- Example scripts for common operations
- Migration guide from original gem

### Changed

#### 🏗️ Architecture Improvements
- Enhanced middleware system
- Improved authentication mechanisms
- Better error handling and reporting
- Optimized API request handling

#### 📦 Gem Structure
- Renamed from `fub_client` to `followupboss_client`
- Maintained backward compatibility with `FubClient` module
- Updated repository location to `connorgallopo/followupboss_client`
- Professional gem packaging and metadata

#### 🔄 Dependencies
- Updated to support Rails 7.1+ through Rails 8.x
- Enhanced Faraday compatibility (1.10.3 - 3.0)
- Improved Her gem integration
- Updated development dependencies

### Technical Details

#### New Classes and Modules
- `FubClient::CookieClient` - Secure cookie authentication
- `FubClient::SharedInbox` - Shared inbox management
- `FubClient::TeamInbox` - Team inbox functionality
- `FubClient::Rails8Patch` - Rails 8 compatibility patches
- `FubClient::HerPatch` - Her gem compatibility fixes

#### Enhanced Resources
All existing resources have been enhanced with:
- Better error handling
- Improved pagination
- Enhanced relationship management
- Additional query methods
- Comprehensive documentation

#### Security Features
- Credential encryption and secure storage
- Environment-based configuration
- Secure cookie handling
- HTTPS enforcement recommendations

### Migration from Original Gem

#### Installation Change
```ruby
# Old
gem 'fub_client', git: 'https://github.com/original/fub_client.git'

# New
gem 'followupboss_client'
```

#### Require Statement Change
```ruby
# Old
require 'fub_client'

# New
require 'followupboss_client'
```

#### API Usage (Unchanged)
All existing API usage remains the same:
```ruby
FubClient.configure do |config|
  config.api_key = 'your_api_key'
end

people = FubClient::Person.all
deals = FubClient::Deal.active
```

### Acknowledgments

This release builds upon the original work by Kyoto Kopz and represents a significant enhancement and modernization of the Follow Up Boss Ruby client library. Special thanks to the Ruby and Rails communities for their continued support and contributions.

---

**For detailed usage examples and documentation, see the [README.md](README.md)**

**For security considerations and best practices, see the Security section in the README**
