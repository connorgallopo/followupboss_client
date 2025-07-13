module FubClient
  class CookieClient
    attr_accessor :gist_url, :encryption_key, :subdomain
    attr_reader :cookies

    def initialize(subdomain: nil, gist_url: nil, encryption_key: nil, cookie: nil)
      config = FubClient.configuration

      @subdomain = subdomain || config.subdomain || ENV['FUB_SUBDOMAIN']
      @gist_url = gist_url || config.gist_url || ENV['FUB_GIST_URL']
      @encryption_key = encryption_key || config.encryption_key || ENV['FUB_ENCRYPTION_KEY']
      cookie ||= config.cookie || ENV['FUB_COOKIE']

      raise ArgumentError, 'Subdomain is required for cookie authentication' unless @subdomain

      if cookie
        self.cookies = cookie
        puts "Using provided cookie (#{cookie.length} chars)" if ENV['DEBUG']
      elsif @gist_url && @encryption_key
        raise ArgumentError, 'Failed to fetch or decrypt cookie from GIST URL' unless fetch_cookie_from_gist
      else
        raise ArgumentError, "Either 'cookie' or both 'gist_url' and 'encryption_key' must be provided"
      end

      configure_client
    end

    def cookies=(value)
      @cookies = value
      # Don't modify the global client anymore
    end

    def client
      @client ||= FubClient::Client.instance
    end

    def configure_client
      # Don't modify the global client - create our own Her API instance
      @her_api = create_cookie_her_api
    end

    def reset_her_api
      @her_api = create_cookie_her_api
    end

    def her_api
      @her_api ||= create_cookie_her_api
    end

    private

    def create_cookie_her_api
      api_uri = URI::HTTPS.build(host: "#{@subdomain}.followupboss.com", path: "/api/#{FubClient::Client::API_VERSION}")
      
      her_api = Her::API.new
      her_api.setup url: api_uri.to_s do |c|
        # Use cookie authentication middleware with our cookies
        c.use FubClient::Middleware::CookieAuthentication, cookies: @cookies
        c.request :url_encoded
        c.use FubClient::Middleware::Parser
        c.adapter :net_http
      end
      
      her_api
    end

    def fetch_cookie_from_gist
      begin
        require 'net/http'
        require 'uri'
        require 'json'
        require 'openssl'

        puts "Fetching cookie from gist URL: #{@gist_url}" if ENV['DEBUG']

        uri = URI.parse(@gist_url)
        response = Net::HTTP.get_response(uri)

        if response.code == '200'
          json_data = JSON.parse(response.body)

          if json_data && json_data['followupboss.com']
            cookie_value = json_data['followupboss.com']
            puts "Found cookie data (#{cookie_value.length} chars)" if ENV['DEBUG']

            if cookie_value.length > 1000 && cookie_value.match?(/^[0-9a-fA-F]+$/)
              puts 'Data appears to be encrypted hex, attempting decryption...' if ENV['DEBUG']
              decrypted_cookie = decrypt_cookie(cookie_value)

              if decrypted_cookie && !decrypted_cookie.empty?
                processed_cookie = process_decrypted_data(decrypted_cookie)
                self.cookies = processed_cookie
                if ENV['DEBUG']
                  puts "Successfully decrypted and processed cookie from gist (#{processed_cookie.length} chars)"
                end
                return true
              else
                puts 'Failed to decrypt cookie from GIST' if ENV['DEBUG']
                return false
              end
            else
              puts 'Data appears to be unencrypted cookie string, using directly' if ENV['DEBUG']
              self.cookies = cookie_value
              puts "Successfully loaded unencrypted cookie from gist (#{cookie_value.length} chars)" if ENV['DEBUG']
              return true
            end
          elsif ENV['DEBUG']
            puts 'Invalid cookie data format in gist'
          end
        elsif ENV['DEBUG']
          puts "Failed to fetch gist data: HTTP #{response.code}"
        end
      rescue StandardError => e
        puts "Error fetching from gist: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        return false
      end

      puts 'Failed to fetch or decrypt cookie from GIST' if ENV['DEBUG']
      false
    end

    private

    def decrypt_cookie(encrypted_hex)
      result = try_aes_cbc_decrypt(encrypted_hex)

      if result
        puts 'Successfully decrypted using kevast-encrypt method' if ENV['DEBUG']
        result
      else
        puts 'Kevast-encrypt decryption failed' if ENV['DEBUG']
        nil
      end
    end

    def try_aes_cbc_decrypt(encrypted_hex)
      encrypted_data = [encrypted_hex].pack('H*')

      cipher = OpenSSL::Cipher.new('AES-128-CBC')
      cipher.decrypt

      key_size = 16
      iv_size = 16

      derived_key_iv = openssl_derive_bytes(@encryption_key, nil, key_size + iv_size)

      key = derived_key_iv[0, key_size]
      iv = derived_key_iv[key_size, iv_size]

      cipher.key = key
      cipher.iv = iv

      decrypted = cipher.update(encrypted_data) + cipher.final
      decrypted.force_encoding('UTF-8')

      puts 'Kevast-encrypt compatible decryption successful' if ENV['DEBUG']
      decrypted
    rescue StandardError => e
      puts "Kevast-encrypt compatible decryption failed: #{e.message}" if ENV['DEBUG']
      nil
    end

    def openssl_derive_bytes(password, salt, key_len)
      d = d_i = ''
      while d.length < key_len
        d_i = OpenSSL::Digest::MD5.digest(d_i + password + (salt || ''))
        d += d_i
      end
      d[0, key_len]
    end

    def process_decrypted_data(decrypted_data)
      begin
        cookies_array = JSON.parse(decrypted_data)

        if cookies_array.is_a?(Array)
          puts "Processing #{cookies_array.length} cookie objects from JSON" if ENV['DEBUG']

          cookie_parts = []

          cookies_array.each do |cookie_obj|
            next unless cookie_obj.is_a?(Hash) && cookie_obj['name'] && cookie_obj['value']

            domain = cookie_obj['domain'] || ''
            if domain.include?('followupboss.com') || domain.include?('.followupboss.com') || domain.empty?
              cookie_parts << "#{cookie_obj['name']}=#{cookie_obj['value']}"
              puts "Added cookie: #{cookie_obj['name']} (domain: '#{domain}')" if ENV['DEBUG']
            end
          end

          if cookie_parts.any?
            cookie_string = cookie_parts.join('; ')
            if ENV['DEBUG']
              puts "Created cookie string with #{cookie_parts.length} cookies (#{cookie_string.length} chars)"
            end
            return cookie_string
          elsif ENV['DEBUG']
            puts 'No followupboss.com cookies found in JSON data'
          end
        end
      rescue JSON::ParserError => e
        puts "Data is not JSON, treating as plain cookie string: #{e.message}" if ENV['DEBUG']
      rescue StandardError => e
        puts "Error processing decrypted data: #{e.message}" if ENV['DEBUG']
      end

      decrypted_data
    end
  end
end
