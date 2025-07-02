# Her gem compatibility patch for Faraday 2.x
# This file intercepts Her gem loading to prevent Faraday::Response::Middleware errors

# First, try to create the missing Faraday::Response::Middleware class using const_set
if defined?(Faraday) && !defined?(Faraday::Response::Middleware)
  middleware_class = Class.new(Faraday::Middleware) do
    def initialize(app, options = {})
      super(app)
      @options = options
    end
  end
  
  Faraday::Response.const_set('Middleware', middleware_class)
  puts "[FubClient] Created Faraday::Response::Middleware using const_set"
end

# Override require to intercept Her middleware loading
original_require = method(:require)

define_method(:require) do |name|
  case name
  when 'her/middleware/parse_json'
    # Define Her::Middleware::ParseJSON without loading the original file
    module Her
      module Middleware
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
      end
    end
    puts "[FubClient] Intercepted and replaced her/middleware/parse_json"
    true
  when 'her/middleware/first_level_parse_json'
    # Define Her::Middleware::FirstLevelParseJSON without loading the original file
    module Her
      module Middleware
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
    puts "[FubClient] Intercepted and replaced her/middleware/first_level_parse_json"
    true
  when /^her\/middleware\//
    # For any other Her middleware files, try to load them normally but catch errors
    begin
      original_require.call(name)
    rescue NameError => e
      if e.message.include?('Faraday::Response::Middleware')
        puts "[FubClient] Skipped loading #{name} due to Faraday::Response::Middleware error"
        true
      else
        raise e
      end
    end
  else
    # For all other requires, use the original method
    original_require.call(name)
  end
end

puts "[FubClient] Applied Her gem require interception patches"
