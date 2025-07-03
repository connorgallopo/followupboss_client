module FubClient
  # CookieClient is a standalone class that provides a convenient way to use
  # cookies for authentication with the FollowUpBoss API, particularly for
  # endpoints like SharedInbox that require cookie authentication.
  class CookieClient
    # Default gist URL containing the cookie data (always fetches latest version)
    COOKIE_GIST_URL = "***REMOVED***"
    
    # Encryption key for the sync-my-cookie Chrome extension format (if applicable)
    ENCRYPTION_KEY = "***REMOVED***"
    
    # Current working cookie string (updated with fresh data)
    WORKING_COOKIE = "***REMOVED***; ***REMOVED***|68fd4e278b8921bb84f6f614d2e72528; _fbp=fb.1.1745264289069.185198969320878588; cf_1859_id=e9ad6eb8-8497-463a-acaa-db07bf0b2d38; WidgetTrackerCookie=6daa7fbf-8ac3-47da-8c54-a2645912be4b; hubspotutk=b5e239d5b44765f81af204da4ccb5e05; intercom-device-id-mfhsavoz=3a9938f4-f196-41d3-a5f0-80b2a5d770e4; NPS_b227f015_last_seen=1745264294530; __stripe_mid=b0049c62-c99a-47f5-a039-db0a06214cc079858d; richdesk=50842838a37791773f524e739bbf05df; __hssrc=1; _vwo_uuid=D4B42442498CE389B4BE976B6ACD4914A; _vis_opt_s=1%7C; _vis_opt_test_cookie=1; _vis_opt_exp_39_combi=1; _gcl_gs=2.1.k1$i1747247209$u220191118; _gac_UA-26653653-1=1.1747247211.CjwKCAjw_pDBBhBMEiwAmY02Nrgd38kLMv2Scy2TRxc4LlOuyyfHtUcrWtP8tsjLoJsM-De1dL-IWBoC2EIQAvD_BwE; _gcl_aw=GCL.1747247212.CjwKCAjw_pDBBhBMEiwAmY02Nrgd38kLMv2Scy2TRxc4LlOuyyfHtUcrWtP8tsjLoJsM-De1dL-IWBoC2EIQAvD_BwE; rdpl_subdomain=***REMOVED***; _ga_J70LJ0E97T=GS2.1.s1747419681$o7$g0$t1747419681$j0$l0$h0; rdtb=8560fd300e26fbab865242a22f43a8901d307ddbb5a1330b3a04a76928997b83; __hstc=134341614.b5e239d5b44765f81af204da4ccb5e05.1745264290477.1750107716082.1750181413562.22; cf_1859_person_time=1750349032677; cf_1859_person_last_update=1750349032679; _ga_CTHYBY0K29=GS2.1.s1750349032$o32$g0$t1750349034$j58$l0$h532941476; rdack2=1257470f6a295bb6c093fd5e5a72333c8575417fba7ebf30da973e94ef768514; rdpl2=22a0eab75afa162d24c6182e9ac7e6984f2958d3f042b178be1e08904d573c0b; _ga=GA1.2.172799480.1745264289; _clck=nemvia%7C2%7Cfx8%7C0%7C1937; _uetvid=276d41c01ee811f0b689830248da280b; NPS_b227f015_throttle=1751506280040; fs_uid=#W8E#bab9a478-6732-4840-a0a7-12014936d91e:ac2e9cd8-7e72-4d7a-beca-eeb8f2d5d5db:1751484972982::3#a677ec8f#/1781384831; __stripe_sid=ad0704d5-8e40-42fe-886a-3086a4d3dd05e673c9; fs_lua=1.1751487838854; intercom-session-mfhsavoz=aDhlWWZlVUtDVGFUR3VpUkt5OC8vblhyZVVCWlFNM1lNUFhNejBGb2FLdVNzekZybmlibHdRd3I1cGg3dUtMbndTWVB4ZjhxaGNWQUxGSkl1citzb3UzUkZ4d2UyUE1vaFMrbjZIZXpZWlk9LS1yTHdDWTJPUzNzQU5kdmNpVm9Pd053PT0=--678f90019686761606db67248029308961ef9768; ***REMOVED***"
    
    attr_accessor :gist_url, :subdomain
    attr_reader :cookies
    
    # Initialize the client with optional parameters
    # @param gist_url [String] URL to fetch the cookie from (optional)
    # @param use_direct_cookie [Boolean] Whether to use the direct cookie from WORKING_COOKIE instead of fetching from gist
    def initialize(gist_url = nil, use_direct_cookie = true)
      @gist_url = gist_url || COOKIE_GIST_URL
      
      if use_direct_cookie
        # Use the known working cookie directly
        self.cookies = WORKING_COOKIE
        puts "Using known working cookie (#{WORKING_COOKIE.length} chars)" if ENV['DEBUG']
      else
        # Try to fetch cookie from gist
        fetch_cookie_from_gist
      end
    end
    
    # Set subdomain and apply it to the client
    # @param value [String] The subdomain to use
    def subdomain=(value)
      @subdomain = value
      client.subdomain = value
      client.reset_her_api
    end
    
    # Set cookies on both this object and the client instance
    # @param value [String] The cookie string
    def cookies=(value)
      @cookies = value
      client.cookies = value
    end
    
    # Get access to the singleton client instance
    # @return [FubClient::Client] The client instance
    def client
      @client ||= FubClient::Client.instance
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
      # Only use the kevast-encrypt compatible method (the correct one)
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
        derived_key_iv = openssl_derive_bytes(ENCRYPTION_KEY, nil, key_size + iv_size)
        
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
    
    # Legacy AES-256-ECB decryption (kept for fallback)
    def try_aes_ecb_decrypt(encrypted_hex)
      begin
        encrypted_data = [encrypted_hex].pack('H*')
        
        cipher = OpenSSL::Cipher.new('AES-256-ECB')
        cipher.decrypt
        
        key = OpenSSL::Digest::SHA256.digest(ENCRYPTION_KEY)
        cipher.key = key
        
        decrypted = cipher.update(encrypted_data) + cipher.final
        decrypted.force_encoding('UTF-8')
        
        puts "AES-ECB decryption successful" if ENV['DEBUG']
        return decrypted
        
      rescue => e
        puts "AES-ECB decryption failed: #{e.message}" if ENV['DEBUG']
        return nil
      end
    end
    
    # Legacy PBKDF2 key derivation (kept for fallback)
    def try_pbkdf2_decrypt(encrypted_hex)
      begin
        encrypted_data = [encrypted_hex].pack('H*')
        
        # Try with PBKDF2 key derivation (common in browser extensions)
        salt = "sync-my-cookie" # Common salt for browser extensions
        key = OpenSSL::PKCS5.pbkdf2_hmac(ENCRYPTION_KEY, salt, 10000, 32, OpenSSL::Digest::SHA256.new)
        
        cipher = OpenSSL::Cipher.new('AES-256-CBC')
        cipher.decrypt
        cipher.key = key
        
        iv = encrypted_data[0, 16]
        encrypted_content = encrypted_data[16..-1]
        cipher.iv = iv
        
        decrypted = cipher.update(encrypted_content) + cipher.final
        decrypted.force_encoding('UTF-8')
        
        puts "PBKDF2 decryption successful" if ENV['DEBUG']
        return decrypted
        
      rescue => e
        puts "PBKDF2 decryption failed: #{e.message}" if ENV['DEBUG']
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
