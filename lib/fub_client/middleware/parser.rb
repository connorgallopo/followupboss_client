module FubClient
  module Middleware
    class Parser < Faraday::Middleware
      def initialize(app = nil)
        super(app)
      end
      
      def on_complete(env)
        begin
          original_json = MultiJson.load(env[:body])
          
          # First check if there's an error response
          if original_json.is_a?(Hash) && original_json['errorMessage']
            env[:body] = {
              errors: { message: original_json['errorMessage'] },
              data: nil,
              metadata: nil
            }
            return
          end
          
          json = original_json.deep_transform_keys{ |k| k.to_s.snakecase.to_sym }
          
          # Check if this is an error response in the new format
          if json.is_a?(Hash) && json[:error_message]
            env[:body] = {
              errors: { message: json[:error_message] },
              data: nil,
              metadata: nil
            }
            return
          end
          
          metadata = json[:_metadata]
          if metadata.nil?
            result = json
          else
            # Make sure the collection key exists and is a string before using it
            if metadata[:collection].is_a?(String)
              collection_key = metadata[:collection].snakecase.to_sym
              result = json[collection_key] || []
            else
              result = []
            end
          end
          
          env[:body] = {
            data: result,
            errors: json[:errors],
            metadata: metadata
          }
        rescue => e
          # Provide a clean error response if JSON parsing fails
          env[:body] = {
            errors: { message: "Parser error: #{e.message}" },
            data: nil,
            metadata: nil
          }
        end
      end
    end
  end
end
