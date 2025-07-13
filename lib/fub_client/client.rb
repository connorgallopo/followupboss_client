module FubClient
  class Client
    API_URL = 'api.followupboss.com'
    WEBAPP_URL = 'app.followupboss.com'
    API_VERSION = 'v1'

    include Singleton

    # Allow explicitly setting the instance (for testing)
    class << self
      attr_writer :instance
      
      # Convenience method to access configuration
      def config
        FubClient.configuration
      end
      
      # Alias for configuration
      def configuration
        FubClient.configuration
      end
    end

    attr_reader :her_api

    def initialize
      init_her_api
    end

    def api_key
      return @api_key if defined?(@api_key) && @api_key
      FubClient.configuration.api_key || ENV['FUB_API_KEY']
    end

    def api_key=(value)
      @api_key = value
    end

    def subdomain
      return @subdomain if defined?(@subdomain) && @subdomain
      FubClient.configuration.subdomain || ENV['FUB_SUBDOMAIN']
    end

    def subdomain=(value)
      @subdomain = value
    end

    def cookies
      return @cookies if defined?(@cookies) && @cookies
      FubClient.configuration.cookie || ENV['FUB_COOKIE']
    end

    def cookies=(value)
      @cookies = value
    end

    def api_uri
      if use_cookies? && subdomain
        # Use subdomain-specific URL for cookie-based auth
        URI::HTTPS.build(host: "#{subdomain}.followupboss.com", path: "/api/#{API_VERSION}")
      else
        # Use default API URL for API key auth
        URI::HTTPS.build(host: API_URL, path: "/#{API_VERSION}")
      end
    end

    # Login to obtain cookies
    def login(email, password, remember = true)
      # First get CSRF token
      csrf_token = get_csrf_token

      puts "CSRF Token: #{csrf_token}" if ENV['DEBUG']

      if csrf_token.nil?
        puts 'Failed to obtain CSRF token, cannot proceed with login' if ENV['DEBUG']
        return false
      end

      conn = Faraday.new(url: "https://#{WEBAPP_URL}") do |f|
        f.request :url_encoded
        f.adapter :net_http
      end

      # Format request similar to the curl example
      # Remove quotes from the password if it's a string with quotes (from .env file)
      password_str = password.to_s.gsub(/^'(.*)'$/, '\1')

      # Check if the password contains special characters that need encoding
      encoded_password = URI.encode_www_form_component(password_str)

      # Ensure # is properly encoded as %23
      if password_str.include?('#') && !encoded_password.include?('%23')
        puts "WARNING: The # character in password isn't being properly encoded! Manually fixing..." if ENV['DEBUG']
        encoded_password = encoded_password.gsub(/#/, '%23')
      end

      # Explicitly use the exact raw data format from the curl example, ensuring all special characters are preserved
      raw_data = "start_url=&subdomain=&email=#{URI.encode_www_form_component(email)}&password=#{encoded_password}&remember=&remember=#{remember ? '1' : ''}&csrf_token=#{csrf_token}"

      puts "Login raw data: #{raw_data}" if ENV['DEBUG']

      response = conn.post do |req|
        req.url '/login/index'

        # Add ALL headers exactly as in the curl example
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.headers['Accept'] =
          'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'
        req.headers['Accept-Language'] = 'en-US,en;q=0.9'
        req.headers['Cache-Control'] = 'max-age=0'
        req.headers['User-Agent'] =
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36'
        req.headers['Origin'] = "https://#{WEBAPP_URL}"
        req.headers['Referer'] = "https://#{WEBAPP_URL}/login"
        req.headers['DNT'] = '1'
        req.headers['Priority'] = 'u=0, i'
        req.headers['Sec-CH-UA'] = '"Google Chrome";v="135", "Not-A.Brand";v="8", "Chromium";v="135"'
        req.headers['Sec-CH-UA-Mobile'] = '?0'
        req.headers['Sec-CH-UA-Platform'] = '"Windows"'
        req.headers['Sec-Fetch-Dest'] = 'document'
        req.headers['Sec-Fetch-Mode'] = 'navigate'
        req.headers['Sec-Fetch-Site'] = 'same-origin'
        req.headers['Sec-Fetch-User'] = '?1'
        req.headers['Sec-GPC'] = '1'
        req.headers['Upgrade-Insecure-Requests'] = '1'

        # Add any cookies that might help
        default_cookies = '_ga=GA1.1.703376757.1744985902; _ga_J70LJ0E97T=GS1.1.1744990639.2.1.1744990766.0.0.0'
        req.headers['Cookie'] = default_cookies

        req.body = raw_data
      end

      puts "Login response status: #{response.status}"
      puts "Login response headers: #{response.headers.inspect}"
      puts "Login response body: #{response.body}"

      # First check for error messages in the response
      if response.body.include?('Oops! Email address or password is not correct')
        puts 'Login failed: Invalid credentials' if ENV['DEBUG']
        return false
      end

      if [302, 200].include?(response.status)
        # Extract cookies from response
        cookies = response.headers['set-cookie']
        if cookies
          puts "Extracted cookies: #{cookies}" if ENV['DEBUG']
          @cookies = cookies

          # Verify we don't have error messages in the response
          return true unless response.body.include?('<div class="message error">')

          puts 'Login failed: Error message detected in response' if ENV['DEBUG']
          return false

        elsif ENV['DEBUG']
          puts 'No cookies in response headers'
        end
      else
        puts "Login failed with status: #{response.status}" if ENV['DEBUG']
        puts "Response body sample: #{response.body[0..200]}" if ENV['DEBUG']
      end

      false
    end

    # Get CSRF token for login
    def get_csrf_token
      conn = Faraday.new(url: "https://#{WEBAPP_URL}") do |f|
        f.adapter :net_http
      end

      response = conn.get('/login')

      # Extract CSRF token from HTML - using the input field pattern found in the response
      if response.body =~ /csrf_token\\" value=\\"([^\\]+)/
        return ::Regexp.last_match(1)
      elsif response.body =~ /name=\\"csrf_token\\" value=\\"([^"]+)/
        return ::Regexp.last_match(1)
      elsif response.body =~ /csrf_token=([^"&]+)/
        return ::Regexp.last_match(1)
      end

      # For debugging
      if ENV['DEBUG']
        puts 'Could not find CSRF token in the response. Sample of response body:'
        puts response.body[0..500]
      end

      nil
    end

    # Use cookie authentication?
    def use_cookies?
      current_cookies = cookies
      !current_cookies.nil? && !current_cookies.empty?
    end

    # Reset the HER API connection with current settings
    def reset_her_api
      @api_uri = nil # Clear cached URI to rebuild with current settings
      init_her_api
    end

    private

    def init_her_api
      @her_api = Her::API.new
      @her_api.setup url: api_uri.to_s do |c|
        # Request - use appropriate authentication middleware
        if use_cookies?
          # Let the CookieAuthentication middleware handle all headers
          # to ensure they're consistent with the cookie format
          c.use FubClient::Middleware::CookieAuthentication
        else
          c.use FubClient::Middleware::Authentication
        end

        c.request :url_encoded

        # Response
        c.use FubClient::Middleware::Parser

        # Adapter
        c.adapter :net_http
      end
    end
  end
end
