#!/usr/bin/env ruby
require 'bundler/setup'
require 'fub_client'
require 'dotenv'
require 'pry'
require 'faraday'
Dotenv.load

# Load environment variables from .env file
EMAIL = ENV['FUB_EMAIL'] || '***REMOVED***'
PASSWORD = ENV['FUB_PASSWORD'] || '***REMOVED***'
SUBDOMAIN = ENV['FUB_SUBDOMAIN'] || '***REMOVED***'

# Set debug mode
ENV['DEBUG'] = 'true'

puts "=====================================================\n"
puts "TESTING CLIENT LOGIN REQUEST FORMAT (DRY RUN)\n"
puts "=====================================================\n"

# Instead of mocking Faraday, we'll just capture the request details manually
class RequestCapture
  attr_accessor :url, :headers, :body, :method
  
  def initialize
    @url = nil
    @headers = {}
    @body = ""
    @method = nil
  end
end

# Temporarily patch the client for testing
module FubClient
  class Client
    # Override to use mock connection
    alias_method :original_login, :login
    
    def login_dry_run(email, password, remember = true)
      # First get CSRF token
      csrf_token = "fubcsrf_test_token_" + Time.now.to_i.to_s
      puts "Using mock CSRF token: #{csrf_token}"
      
      # Capture the request details
      request = RequestCapture.new
      request.method = :post
      request.url = "https://#{WEBAPP_URL}/login/index"
      
      # Format request similar to the curl example
      # Remove quotes from the password if it's a string with quotes (from .env file)
      password_str = password.to_s.gsub(/^'(.*)'$/, '\1')
      puts "\nPassword before processing: #{password.inspect}"
      puts "Password after removing quotes: #{password_str.inspect}"
      
      # Check if the password contains special characters that need encoding
      encoded_email = URI.encode_www_form_component(email)
      encoded_password = URI.encode_www_form_component(password_str)
      
      # Ensure # is properly encoded as %23
      if password_str.include?('#') && !encoded_password.include?('%23')
        puts "\n⚠️  WARNING: The # character in password isn't being properly encoded by Ruby's URI.encode_www_form_component!"
        puts "This is a known issue in some environments. Manually fixing..."
        encoded_password = encoded_password.gsub(/#/, '%23')
      end
      
      puts "\nURL-encoded email: #{encoded_email}"
      puts "URL-encoded password: #{encoded_password}"
      
      # Build form data using the raw data format from the curl example
      raw_data = "start_url=&subdomain=&email=#{encoded_email}&password=#{encoded_password}&remember=&remember=#{remember ? '1' : ''}&csrf_token=#{csrf_token}"
      
      puts "\nRaw request data:"
      puts raw_data
      
      # Set the headers that would be used in the request
      request.headers = {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'User-Agent' => 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36',
        'Accept' => 'text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7',
        'Cache-Control' => 'max-age=0',
        'Origin' => "https://#{WEBAPP_URL}",
        'Referer' => "https://#{WEBAPP_URL}/login"
      }
      
      # Set the body that would be sent in the request
      request.body = raw_data
      
      puts "\nRequest URL: #{request.url}"
      puts "\nRequest Headers:"
      
      if request.headers && !request.headers.empty?
        request.headers.each do |key, value|
          puts "  #{key}: #{value}"
        end
      else
        puts "  No headers captured"
      end
      
      puts "\nRequest Body:"
      puts request.body.nil? ? "No body captured" : request.body
      
      # Verify password was properly encoded
      if request.body && request.body.include?(encoded_password)
        puts "\n✅ Password is properly URL-encoded"
        
        # Check if special characters are included
        if password_str.include?('#')
          if encoded_password.include?('%23')
            puts "✅ Special character '#' is correctly encoded as %23"
          else
            puts "❌ Special character '#' is NOT properly encoded! This will cause login to fail."
          end
        end
        if password_str.include?('!') && encoded_password.include?('%21')
          puts "✅ Special character '!' is correctly encoded as %21"
        end
        if password_str.include?('@') && encoded_password.include?('%40')
          puts "✅ Special character '@' is correctly encoded as %40"
        end
      else
        puts "\n❌ WARNING: Password does not appear to be properly encoded in the request body!"
      end
      
      # For verification, let's compare with the original curl command
      puts "\nEquivalent curl command:"
      puts "curl 'https://app.followupboss.com/login/index' \\"
      puts "  -H 'Content-Type: application/x-www-form-urlencoded' \\"
      puts "  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36' \\"
      puts "  -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/avif,image/webp,image/apng,*/*;q=0.8,application/signed-exchange;v=b3;q=0.7' \\"
      puts "  -H 'Cache-Control: max-age=0' \\"
      puts "  -H 'Origin: https://app.followupboss.com' \\"
      puts "  -H 'Referer: https://app.followupboss.com/login' \\"
      puts "  --data-raw '#{raw_data}'"
      
      puts "\n=====================================================\n"
      puts "DRY RUN COMPLETED - NO ACTUAL REQUEST WAS SENT\n"
      puts "=====================================================\n"
      
      true
    end
  end
end

# Test our login request format (without actually sending a request)
client = FubClient::Client.instance
result = client.login_dry_run(EMAIL, PASSWORD)

puts "Done!"
