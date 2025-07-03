# Her gem compatibility patch for Faraday 2.x

if defined?(Faraday) && !defined?(Faraday::Response::Middleware)
  middleware_class = Class.new(Faraday::Middleware) do
    def initialize(app, options = {})
      super(app)
      @options = options
    end
  end

  Faraday::Response.const_set('Middleware', middleware_class)
  puts '[FubClient] Created Faraday::Response::Middleware using const_set'
end

original_require = method(:require)

define_method(:require) do |name|
  case name
  when 'her/middleware/parse_json'
    module Her
      module Middleware
        class ParseJSON < Faraday::Middleware
          def initialize(app, options = {})
            super(app)
            @options = options
          end

          def on_complete(env)
            return unless process_response_type?(env[:response_headers]['content-type'])

            env[:body] = parse(env[:body])
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
            content_type && content_type.match(%r{application/json})
          end
        end
      end
    end
    puts '[FubClient] Intercepted and replaced her/middleware/parse_json'
    true
  when 'her/middleware/first_level_parse_json'
    module Her
      module Middleware
        class FirstLevelParseJSON < Faraday::Middleware
          def initialize(app, options = {})
            super(app)
            @options = options
          end

          def on_complete(env)
            return unless process_response_type?(env[:response_headers]['content-type'])

            env[:body] = parse(env[:body])
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
            content_type && content_type.match(%r{application/json})
          end
        end
      end
    end
    puts '[FubClient] Intercepted and replaced her/middleware/first_level_parse_json'
    true
  when %r{^her/middleware/}
    begin
      original_require.call(name)
    rescue NameError => e
      raise e unless e.message.include?('Faraday::Response::Middleware')

      puts "[FubClient] Skipped loading #{name} due to Faraday::Response::Middleware error"
      true
    end
  else
    original_require.call(name)
  end
end

puts '[FubClient] Applied Her gem require interception patches'
