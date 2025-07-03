module FubClient
  # CookieClient is a standalone class that provides a convenient way to use
  # cookies for authentication with the FollowUpBoss API, particularly for
  # endpoints like SharedInbox that require cookie authentication.
  #
  # This class requires explicit configuration and does not contain any
  # hard-coded credentials or URLs for security reasons.
  class CookieClient
    attr_accessor :gist_url, :encryption_key, :subdomain
    attr_reader :cookies
    
    # Initialize the client with explicit parameters or global configuration
    # @param subdomain [String] The subdomain to use (required for cookie auth)
    # @param gist_url [String] URL to fetch the encrypted cookie from (optional)
    # @param encryption_key [String] Key to decrypt the cookie data (required if using gist_url)
    # @param cookie [String] Direct cookie string (alternative to gist_url + encryption_key)
    def initialize(subdomain: nil, gist_url: nil, encryption_key: nil, cookie: nil)
      # Use provided parameters or fall back to global configuration
      config = FubClient.configuration
      
      @subdomain = subdomain || config.subdomain
      @gist_url = gist_url || config.gist_url
      @encryption_key = encryption_key || config.encryption_key
      
      # Validate required parameters
      raise ArgumentError, "Subdomain is required for cookie authentication" unless @subdomain
      
      if cookie
        # Use direct cookie if provided
        self.cookies = cookie
        puts "Using provided cookie (#{cookie.length} chars)" if ENV['DEBUG']
      elsif @gist_url && @encryption_key
        # Try to fetch and decrypt cookie from gist
        unless fetch_cookie_from_gist
          raise ArgumentError, "Failed to fetch or decrypt cookie from GIST URL"
        end
      else
        raise ArgumentError, "Either 'cookie' or both 'gist_url' and 'encryption_key' must be provided"
      end
      
      # Configure the client with our settings
      configure_client
    end
    
    # Set cookies on both this object and the client instance
    # @param value [String] The cookie string
    def cookies=(value)
      @cookies = value
      client.cookies = value if @cookies
    end
    
    # Get access to the singleton client instance
    # @return [FubClient::Client] The client instance
    def client
      @client ||= FubClient::Client.instance
    end
    
    # Configure the client with our subdomain and cookies
    def configure_client
      client.subdomain = @subdomain
      client.cookies = @cookies
      client.reset_her_api
    end
    
    # Reset the client's API configuration
    def reset_her_api
      client.reset_her_api
    end
    
    # Fetch cookie from the specified gist URL
    # @return [Boolean] True if cookie was successfully fetched, false otherwise
    def fetch_cookie_from_gist
      begin
        require 'net/http'
        require 'uri'
        require 'json'
        require 'openssl'
        
        puts "Fetching cookie from gist URL: #{@gist_url}" if ENV['DEBUG']
        
        uri = URI.parse(@gist_url)
        response = Net::HTTP.get_response(uri)
        
        if response.code == "200"
          json_data = JSON.parse(response.body)
          
          if json_data && json_data["followupboss.com"]
            cookie_value = json_data["followupboss.com"]
            puts "Found cookie data (#{cookie_value.length} chars)" if ENV['DEBUG']
            
            # Check if the data looks like a plain cookie string or encrypted hex
            if cookie_value.length > 1000 && cookie_value.match?(/^[0-9a-fA-F]+$/)
              puts "Data appears to be encrypted hex, attempting decryption..." if ENV['DEBUG']
              # Try to decrypt the cookie value using AES decryption
              decrypted_cookie = decrypt_cookie(cookie_value)
              
              if decrypted_cookie && !decrypted_cookie.empty?
                # Check if decrypted data is JSON (Chrome cookie format)
                processed_cookie = process_decrypted_data(decrypted_cookie)
                self.cookies = processed_cookie
                puts "Successfully decrypted and processed cookie from gist (#{processed_cookie.length} chars)" if ENV['DEBUG']
                return true
              else
                puts "Failed to decrypt cookie from GIST" if ENV['DEBUG']
                return false
              end
            else
              puts "Data appears to be unencrypted cookie string, using directly" if ENV['DEBUG']
              # Use the cookie data directly (unencrypted)
              self.cookies = cookie_value
              puts "Successfully loaded unencrypted cookie from gist (#{cookie_value.length} chars)" if ENV['DEBUG']
              return true
            end
          else
            puts "Invalid cookie data format in gist" if ENV['DEBUG']
          end
        else
          puts "Failed to fetch gist data: HTTP #{response.code}" if ENV['DEBUG']
        end
      rescue => e
        puts "Error fetching from gist: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        return false
      end
      
      # No fallback - if GIST fails, we fail
      puts "Failed to fetch or decrypt cookie from GIST" if ENV['DEBUG']
      return false
    end
    
    private
    
    # Decrypt the encrypted cookie value from the gist
    # @param encrypted_hex [String] The hex-encoded encrypted cookie data
    # @return [String, nil] The decrypted cookie string or nil if decryption fails
    def decrypt_cookie(encrypted_hex)
      # Use the kevast-encrypt compatible method
      result = try_aes_cbc_decrypt(encrypted_hex)
      
      if result
        puts "Successfully decrypted using kevast-encrypt method" if ENV['DEBUG']
        return result
      else
        puts "Kevast-encrypt decryption failed" if ENV['DEBUG']
        return nil
      end
    end
    
    # Try kevast-encrypt compatible decryption (AES-128-CBC with opensslDeriveBytes)
    def try_aes_cbc_decrypt(encrypted_hex)
      begin
        encrypted_data = [encrypted_hex].pack('H*')
        
        # Use AES-128-CBC as per kevast-encrypt implementation
        cipher = OpenSSL::Cipher.new('AES-128-CBC')
        cipher.decrypt
        
        # Replicate node-forge's opensslDeriveBytes function
        # This uses EVP_BytesToKey algorithm with MD5
        key_size = 16  # AES-128 key size
        iv_size = 16   # CBC IV size
        
        # opensslDeriveBytes equivalent using EVP_BytesToKey with MD5
        derived_key_iv = openssl_derive_bytes(@encryption_key, nil, key_size + iv_size)
        
        key = derived_key_iv[0, key_size]
        iv = derived_key_iv[key_size, iv_size]
        
        cipher.key = key
        cipher.iv = iv
        
        decrypted = cipher.update(encrypted_data) + cipher.final
        decrypted.force_encoding('UTF-8')
        
        puts "Kevast-encrypt compatible decryption successful" if ENV['DEBUG']
        return decrypted
        
      rescue => e
        puts "Kevast-encrypt compatible decryption failed: #{e.message}" if ENV['DEBUG']
        return nil
      end
    end
    
    # Replicate node-forge's opensslDeriveBytes function
    # This implements the EVP_BytesToKey algorithm used by OpenSSL
    def openssl_derive_bytes(password, salt, key_len)
      # EVP_BytesToKey algorithm using MD5 (as used by node-forge)
      d = d_i = ''
      while d.length < key_len
        d_i = OpenSSL::Digest::MD5.digest(d_i + password + (salt || ''))
        d += d_i
      end
      d[0, key_len]
    end
    
    # Process decrypted data - convert from JSON cookie format to cookie string
    # @param decrypted_data [String] The decrypted JSON data
    # @return [String] A properly formatted cookie string
    def process_decrypted_data(decrypted_data)
      begin
        # Try to parse as JSON (Chrome cookie export format)
        cookies_array = JSON.parse(decrypted_data)
        
        if cookies_array.is_a?(Array)
          puts "Processing #{cookies_array.length} cookie objects from JSON" if ENV['DEBUG']
          
          # Convert cookie objects to cookie string format
          cookie_parts = []
          
          cookies_array.each do |cookie_obj|
            if cookie_obj.is_a?(Hash) && cookie_obj['name'] && cookie_obj['value']
              # Include followupboss.com domain cookies AND cookies with empty domains
              domain = cookie_obj['domain'] || ''
              if domain.include?('followupboss.com') || domain.include?('.followupboss.com') || domain.empty?
                cookie_parts << "#{cookie_obj['name']}=#{cookie_obj['value']}"
                puts "Added cookie: #{cookie_obj['name']} (domain: '#{domain}')" if ENV['DEBUG']
              end
            end
          end
          
          if cookie_parts.any?
            cookie_string = cookie_parts.join('; ')
            puts "Created cookie string with #{cookie_parts.length} cookies (#{cookie_string.length} chars)" if ENV['DEBUG']
            return cookie_string
          else
            puts "No followupboss.com cookies found in JSON data" if ENV['DEBUG']
          end
        end
      rescue JSON::ParserError => e
        puts "Data is not JSON, treating as plain cookie string: #{e.message}" if ENV['DEBUG']
      rescue => e
        puts "Error processing decrypted data: #{e.message}" if ENV['DEBUG']
      end
      
      # If JSON parsing failed or no cookies found, return the data as-is
      # (it might already be a cookie string)
      return decrypted_data
    end
  end
end
