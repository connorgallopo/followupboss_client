# Her gem compatibility patch for Faraday 2.x
# This file must be loaded before the Her gem to prevent NameError

# Create the missing Faraday::Response::Middleware class that Her expects
if defined?(Faraday) && !defined?(Faraday::Response::Middleware)
  Faraday::Response.class_eval do
    class Middleware < Faraday::Middleware
      def initialize(app, options = {})
        super(app)
        @options = options
      end
    end
  end
  puts "[FubClient] Created Faraday::Response::Middleware for Her gem compatibility (her_patch)"
end

# Also monkey patch the specific Her middleware classes to avoid the inheritance issue
module Her
  module Middleware
    # Redefine ParseJSON to inherit from Faraday::Middleware directly
    class ParseJSON < Faraday::Middleware
      def initialize(app, options = {})
        super(app)
        @options = options
      end

      def on_complete(env)
        if process_response_type?(env[:response_headers]['content-type'])
          env[:body] = parse(env[:body])
        end
      end

      private

      def parse(body)
        MultiJson.load(body, symbolize_keys: true)
      rescue MultiJson::ParseError => e
        {
          error: "JSON parsing error: #{e.message}",
          body: body
        }
      end

      def process_response_type?(content_type)
        content_type && content_type.match(/application\/json/)
      end
    end

    # Redefine FirstLevelParseJSON to inherit from Faraday::Middleware directly
    class FirstLevelParseJSON < Faraday::Middleware
      def initialize(app, options = {})
        super(app)
        @options = options
      end

      def on_complete(env)
        if process_response_type?(env[:response_headers]['content-type'])
          env[:body] = parse(env[:body])
        end
      end

      private

      def parse(body)
        MultiJson.load(body)
      rescue MultiJson::ParseError => e
        {
          error: "JSON parsing error: #{e.message}",
          body: body
        }
      end

      def process_response_type?(content_type)
        content_type && content_type.match(/application\/json/)
      end
    end
  end
end

puts "[FubClient] Applied Her gem compatibility patches"
