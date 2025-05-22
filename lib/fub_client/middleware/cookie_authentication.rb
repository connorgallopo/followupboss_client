module FubClient
  module Middleware
    class CookieAuthentication < Faraday::Middleware
      def call(env)
        # Get the cookies from the client
        cookies = FubClient::Client.instance.cookies
        
        if cookies && !cookies.empty?
          # CRITICAL: Must set a request header to enable cookie-based auth
          # and prevent falling back to API key auth
          
          # First, remove any Authorization header that might be added elsewhere
          env[:request_headers].delete('Authorization')
          
          # Add cookies as a request header (just like curl -b)
          env[:request_headers]['Cookie'] = cookies
          
          # Add other required headers as seen in the working curl example
          env[:request_headers]['X-Requested-With'] = 'XMLHttpRequest'
          env[:request_headers]['X-System'] = 'fub-spa'
          env[:request_headers]['Accept'] = 'application/json, text/javascript, */*; q=0.01'
          env[:request_headers]['Accept-Language'] = 'en-US,en;q=0.9'
          env[:request_headers]['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36'
          
          if ENV['DEBUG']
            puts "Using cookies for authentication (#{cookies.length} chars)"
            puts "Cookie starts with: #{cookies[0..50]}..." if cookies.length > 50
            puts "Request URL: #{env[:url]}"
            
            # Remove any API key that might have been added 
            # This is to diagnose if we're seeing API key auth being used
            api_key = env[:request_headers]['Authorization']
            if api_key
              puts "WARNING: Authorization header still present: #{api_key}"
              puts "Removing Authorization header before request"
              env[:request_headers].delete('Authorization')
            end
          end
        else
          puts "Warning: No cookies available for authentication" if ENV['DEBUG']
        end
        
        # Debug the request one more time
        if ENV['DEBUG']
          puts "Final request headers:"
          env[:request_headers].each do |k, v|
            if k.downcase == 'cookie' && v.length > 50
              puts "  #{k}: #{v[0..50]}..."
            else
              puts "  #{k}: #{v}"
            end
          end
        end
        
        # Call the next middleware in the chain
        @app.call(env)
      end
    end
  end
end
