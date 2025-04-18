module ActiveSupport
  # Define BasicObject if it doesn't exist for Her gem compatibility
  unless const_defined?(:BasicObject)
    if const_defined?(:ProxyObject)
      BasicObject = ProxyObject
    else
      # Fallback to Ruby's BasicObject if neither is available
      BasicObject = ::BasicObject
    end
  end
end
