module FubClient
  # Configuration class for FubClient gem
  # Supports both API key authentication (primary) and cookie authentication (for specific endpoints)
  class Configuration
    attr_accessor :api_key, :subdomain, :gist_url, :encryption_key, :cookie

    def initialize
      # API key authentication (primary method)
      @api_key = ENV['FUB_API_KEY']

      # Cookie authentication (for specific endpoints like SharedInbox)
      @subdomain = ENV['FUB_SUBDOMAIN']
      @gist_url = ENV['FUB_GIST_URL']
      @encryption_key = ENV['FUB_ENCRYPTION_KEY']
      @cookie = ENV['FUB_COOKIE']
    end

    # Validate that we have at least one authentication method configured
    def valid?
      has_api_key_auth? || has_cookie_auth?
    end

    # Check if API key authentication is configured
    def has_api_key_auth?
      !@api_key.nil? && !@api_key.empty?
    end

    # Check if cookie authentication is configured
    def has_cookie_auth?
      # Either direct cookie or GIST + encryption key
      (!@cookie.nil? && !@cookie.empty?) ||
      (!@gist_url.nil? && !@gist_url.empty? && !@encryption_key.nil? && !@encryption_key.empty?)
    end

    # Get authentication summary for debugging
    def auth_summary
      summary = []
      summary << "API Key: #{has_api_key_auth? ? 'configured' : 'not configured'}"
      summary << "Cookie Auth: #{has_cookie_auth? ? 'configured' : 'not configured'}"
      if has_cookie_auth?
        if @cookie
          summary << "  - Direct cookie: #{@cookie.length} chars"
        elsif @gist_url && @encryption_key
          summary << "  - GIST URL: #{@gist_url}"
          summary << "  - Encryption key: configured"
        end
        summary << "  - Subdomain: #{@subdomain || 'not set'}"
      end
      summary.join("\n")
    end
  end

  # Global configuration instance
  def self.configuration
    @configuration ||= Configuration.new
  end

  # Configure the gem
  # @yield [Configuration] configuration object
  def self.configure
    yield(configuration) if block_given?
  end

  # Reset configuration (useful for testing)
  def self.reset_configuration!
    @configuration = Configuration.new
  end
end
