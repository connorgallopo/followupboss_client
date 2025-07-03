# Rails 8 compatibility patch for Her gem
# Her gem expects: (ActiveSupport.const_defined?('ProxyObject') ? ActiveSupport::ProxyObject : ActiveSupport::BasicObject)

unless defined?(ActiveSupport::ProxyObject)
  begin
    if defined?(ActiveSupport::BasicObject)
      ActiveSupport.const_set('ProxyObject', ActiveSupport::BasicObject)
      puts '[FubClient] Created ActiveSupport::ProxyObject from BasicObject'
    else
      ActiveSupport.const_set('ProxyObject', BasicObject)
      puts "[FubClient] Created ActiveSupport::ProxyObject from Ruby's BasicObject"
    end
  rescue NameError
    ActiveSupport.const_set('ProxyObject', BasicObject)
    puts "[FubClient] Created ActiveSupport::ProxyObject from Ruby's BasicObject (fallback)"
  end
end

begin
  ActiveSupport::BasicObject
rescue NameError
  if defined?(ActiveSupport::ProxyObject)
    ActiveSupport.const_set('BasicObject', ActiveSupport::ProxyObject)
    puts '[FubClient] Created ActiveSupport::BasicObject from ProxyObject'
  end
end

# Faraday 2.x compatibility
if defined?(Faraday) && !defined?(Faraday::Response::Middleware)
  Faraday::Response.class_eval do
    class Middleware < Faraday::Middleware
      def initialize(app, options = {})
        super(app)
        @options = options
      end
    end
  end
  puts '[FubClient] Created Faraday::Response::Middleware for Her gem compatibility'
end
