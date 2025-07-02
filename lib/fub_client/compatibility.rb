# Compatibility fixes for Rails 8
module FubClient
  module Compatibility
    # Fix for Her gem's ActiveSupport::BasicObject usage in Rails 8+
    # ActiveSupport::BasicObject was removed in Rails 8, but Her gem still references it
    def self.patch_her_gem_rails8_compatibility!
      # Only patch if ActiveSupport::BasicObject is not defined (Rails 8+)
      unless ActiveSupport.const_defined?('BasicObject')
        # Define BasicObject as an alias to ProxyObject for backward compatibility
        ActiveSupport.const_set('BasicObject', ActiveSupport::ProxyObject)
      end
    end
  end
end

# Apply the patch immediately when this file is loaded
# This must happen before Her gem is loaded
FubClient::Compatibility.patch_her_gem_rails8_compatibility!
