module FubClient
  class Configuration
    attr_accessor :api_key, :subdomain, :gist_url, :encryption_key, :cookie

    def initialize
      @api_key = ENV['FUB_API_KEY']
      @subdomain = ENV['FUB_SUBDOMAIN']
      @gist_url = ENV['FUB_GIST_URL']
      @encryption_key = ENV['FUB_ENCRYPTION_KEY']
      @cookie = ENV['FUB_COOKIE']
    end

    def valid?
      has_api_key_auth? || has_cookie_auth?
    end

    def has_api_key_auth?
      !@api_key.nil? && !@api_key.empty?
    end

    def has_cookie_auth?
      (!@cookie.nil? && !@cookie.empty?) ||
        (!@gist_url.nil? && !@gist_url.empty? && !@encryption_key.nil? && !@encryption_key.empty?)
    end

    def auth_summary
      summary = []
      summary << "API Key: #{has_api_key_auth? ? 'configured' : 'not configured'}"
      summary << "Cookie Auth: #{has_cookie_auth? ? 'configured' : 'not configured'}"
      if has_cookie_auth?
        if @cookie
          summary << "  - Direct cookie: #{@cookie.length} chars"
        elsif @gist_url && @encryption_key
          summary << "  - GIST URL: #{@gist_url}"
          summary << '  - Encryption key: configured'
        end
        summary << "  - Subdomain: #{@subdomain || 'not set'}"
      end
      summary.join("\n")
    end
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration) if block_given?
  end

  def self.reset_configuration!
    @configuration = Configuration.new
  end
end
