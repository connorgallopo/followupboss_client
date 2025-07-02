# Rails 8 compatibility patch for Her gem
# This ensures both ProxyObject and BasicObject are available for the Her gem
# Her gem uses: (ActiveSupport.const_defined?('ProxyObject') ? ActiveSupport::ProxyObject : ActiveSupport::BasicObject)

# First, ensure ProxyObject exists and is accessible
unless defined?(ActiveSupport::ProxyObject)
  # If ProxyObject doesn't exist, try to use BasicObject as fallback
  begin
    if defined?(ActiveSupport::BasicObject)
      ActiveSupport.const_set('ProxyObject', ActiveSupport::BasicObject)
      puts "[FubClient] Created ActiveSupport::ProxyObject from BasicObject"
    else
      # Neither exists, create a minimal proxy class
      ActiveSupport.const_set('ProxyObject', BasicObject)
      puts "[FubClient] Created ActiveSupport::ProxyObject from Ruby's BasicObject"
    end
  rescue NameError
    # Create a minimal proxy class as last resort
    ActiveSupport.const_set('ProxyObject', BasicObject)
    puts "[FubClient] Created ActiveSupport::ProxyObject from Ruby's BasicObject (fallback)"
  end
end

# Second, ensure BasicObject exists and is accessible
begin
  ActiveSupport::BasicObject
rescue NameError
  # BasicObject doesn't exist, create it as an alias to ProxyObject
  if defined?(ActiveSupport::ProxyObject)
    ActiveSupport.const_set('BasicObject', ActiveSupport::ProxyObject)
    puts "[FubClient] Created ActiveSupport::BasicObject from ProxyObject"
  end
end

# Third, fix Faraday compatibility for Her gem
# Faraday 2.x removed Faraday::Response::Middleware, but Her gem still references it
if defined?(Faraday) && !defined?(Faraday::Response::Middleware)
  # Create the missing Middleware class that Her gem expects
  module Faraday
    module Response
      class Middleware < Faraday::Middleware
        def initialize(app, options = {})
          super(app)
          @options = options
        end
      end
    end
  end
  puts "[FubClient] Created Faraday::Response::Middleware for Her gem compatibility"
end
