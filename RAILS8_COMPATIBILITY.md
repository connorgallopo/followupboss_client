# Rails 8 Compatibility Guide

## Overview

As of version 0.5.0, `fub_client` is fully compatible with Rails 8.0+. This document outlines the changes made to support Rails 8 and provides guidance for upgrading.

## What Changed

### Dependency Updates

The following dependencies were updated to support Rails 8:

- `activesupport`: Changed from `~> 7.1.0` to `>= 7.1.0, < 9.0`
- `activemodel`: Changed from `~> 7.1.0` to `>= 7.1.0, < 9.0`
- `faraday`: Changed from `~> 1.10.3` to `>= 1.10.3, < 3.0`

### Backward Compatibility

The gem maintains backward compatibility with:
- Rails 7.1.x
- Rails 7.2.x
- Rails 8.0.x
- Rails 8.1.x (future)

## Upgrading to Rails 8

### For Existing Applications

If you're upgrading an existing Rails application to Rails 8:

1. Update your `Gemfile`:
   ```ruby
   gem 'fub_client', '~> 0.5.0'
   ```

2. Run bundle update:
   ```bash
   bundle update fub_client
   ```

3. No code changes are required - the API remains the same.

### For New Rails 8 Applications

For new Rails 8 applications, simply add to your `Gemfile`:

```ruby
gem 'fub_client', '~> 0.5.0'
```

## Compatibility Testing

The gem has been tested with:
- ✅ ActiveSupport 7.1.x
- ✅ ActiveSupport 8.0.x
- ✅ ActiveModel 7.1.x
- ✅ ActiveModel 8.0.x
- ✅ Her gem 1.1.x
- ✅ Faraday 1.10.x and 2.x

## Dependencies Analysis

### Her Gem Compatibility

The `her` gem (v1.1.1) used by `fub_client` is compatible with Rails 8:
- Uses `activemodel >= 4.2.1` (broad compatibility)
- No Rails 8 breaking changes affect Her's functionality
- Last updated in 2019 but remains stable

### Faraday Compatibility

Updated Faraday version constraints to support both 1.x and 2.x:
- Rails 8 applications may prefer Faraday 2.x
- Maintains compatibility with existing Faraday 1.x installations

## Breaking Changes

**None.** This is a backward-compatible update that only expands Rails version support.

## Troubleshooting

### Dependency Resolution Issues

If you encounter dependency resolution issues:

1. Check your Rails version:
   ```bash
   rails --version
   ```

2. Update bundler:
   ```bash
   gem update bundler
   ```

3. Clear bundle cache:
   ```bash
   bundle clean --force
   bundle install
   ```

### Version Conflicts

If you see version conflicts with other gems:

1. Check which gems are constraining ActiveSupport/ActiveModel:
   ```bash
   bundle exec gem dependency activesupport --reverse-dependencies
   ```

2. Update conflicting gems to their latest versions
3. Consider using `bundle update` instead of `bundle install`

## Testing Your Application

After upgrading, run your test suite to ensure compatibility:

```bash
# Run your application's tests
bundle exec rspec  # or your test framework

# Test fub_client functionality specifically
bundle exec ruby -e "require 'fub_client'; puts 'FubClient loaded successfully'"
```

## Support

If you encounter any Rails 8 compatibility issues:

1. Check this compatibility guide
2. Review the [CHANGELOG](CHANGELOG.md)
3. Open an issue on GitHub with:
   - Rails version
   - Ruby version
   - Complete error message
   - Gemfile.lock contents

## Future Compatibility

This gem is designed to support future Rails versions through the version constraint `< 9.0`. When Rails 9 is released, we will evaluate compatibility and update accordingly.
