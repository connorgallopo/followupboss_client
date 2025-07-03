module FubClient
  module Middleware
    class Authentication < Faraday::Middleware
      def call(env)
        # Check if cookies are being used - if so, don't add API key
        if FubClient::Client.instance.use_cookies?
          puts 'Skipping API key auth since cookies are being used' if ENV['DEBUG']
        else
          # Get the API key from the client
          api_key = FubClient::Client.instance.api_key

          # Format the authorization header - API key as username with blank password
          # This follows the exact format seen working in the curl command
          auth_encoded = Base64.strict_encode64("#{api_key}:")
          env[:request_headers]['Authorization'] = "Basic #{auth_encoded}"

          # Debug - remove in production
          puts "Debug Authentication Header: #{env[:request_headers]['Authorization']}" if ENV['DEBUG']
        end

        # Call the next middleware in the chain
        @app.call(env)
      end
    end
  end
end
