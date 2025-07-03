module FubClient
  class Client
    API_URL = 'api.followupboss.com'
    WEBAPP_URL = 'app.followupboss.com'
    API_VERSION = 'v1'
    
    include Singleton
    
    # Allow explicitly setting the instance (for testing)
    def self.instance=(obj)
      @instance = obj
    end
    
    attr_writer :api_key, :cookies, :subdomain
    attr_reader :her_api
    
    def initialize
      init_her_api
    end
    
    def api_key
      @api_key ||= ENV['FUB_API_KEY']
    end
    
    def cookies
      @cookies
    end
    
    def subdomain
      @subdomain
    end
    
    def api_uri
      return @api_uri if @api_uri
      
      if subdomain
        # Use subdomain-specific URL for cookie-based auth
        @api_uri = URI::HTTPS.build(host: "#{subdomain}.followupboss.com", path: "/api/#{API_VERSION}")
      else
        # Use default API URL for API key auth
        @api_uri = URI::HTTPS.build(host: API_URL, path: "/#{API_VERSION}")
      end
    end
    
    # Login to obtain cookies
    def login(email, password, remember = true)
      # First get CSRF token
      csrf_token = get_csrf_token
      
      if ENV['DEBUG']
        puts "CSRF Token: #{csrf_token}"
      end
      
      if csrf_token.nil?
        puts "Failed to obtain CSRF token, cannot proceed with login" if ENV['DEBUG']
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
      
      if ENV['DEBUG']
        puts "Login raw data: #{raw_data}"
      end
      
      response = conn.post do |req|
        req.url '/login/index'
        
        # Add ALL headers exactly as in the curl example
        req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
        req.headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7'
        req.headers['Accept-Language'] = 'en-US,en;q=0.9'
        req.headers['Cache-Control'] = 'max-age=0'
        req.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36'
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
        puts "Login failed: Invalid credentials" if ENV['DEBUG']
        return false
      end
      
      if response.status == 302 || response.status == 200
        # Extract cookies from response
        cookies = response.headers['set-cookie']
        if cookies
          if ENV['DEBUG']
            puts "Extracted cookies: #{cookies}"
          end
          @cookies = cookies
          
          # Verify we don't have error messages in the response
          if !response.body.include?('<div class="message error">')
            return true
          else
            puts "Login failed: Error message detected in response" if ENV['DEBUG']
            return false
          end
        else
          puts "No cookies in response headers" if ENV['DEBUG']
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
      if response.body =~ /csrf_token\\\" value=\\\"([^\\]+)/
        return $1
      elsif response.body =~ /name=\\"csrf_token\\" value=\\"([^"]+)/
        return $1
      elsif response.body =~ /csrf_token=([^"&]+)/
        return $1
      end
      
      # For debugging
      if ENV['DEBUG']
        puts "Could not find CSRF token in the response. Sample of response body:"
        puts response.body[0..500]
      end
      
      nil
    end
    
    # Use cookie authentication?
    def use_cookies?
      !@cookies.nil? && !@cookies.empty?
    end
    
    # Reset the HER API connection with current settings
    def reset_her_api
      @api_uri = nil  # Clear cached URI to rebuild with current settings
      init_her_api
    end
    
    private
    
    def init_her_api
      @her_api = Her::API.new
      @her_api.setup url: self.api_uri.to_s do |c|
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
