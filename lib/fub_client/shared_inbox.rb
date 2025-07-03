module FubClient
  # Module containing instance methods for SharedInbox objects
  module SharedInboxMethods
    # Get messages in this shared inbox - direct Faraday implementation
    def messages(limit = 20, offset = 0)
      # Support both Hash objects and model objects
      inbox_id = self.is_a?(Hash) ? self[:id] : self.id
      return [] unless inbox_id
      
      begin
        conn = FubClient::SharedInbox.create_faraday_connection
        return [] unless conn
        
        # Build query parameters
        query = "?limit=#{limit}&offset=#{offset}"
        
        # Make the direct request
        response = conn.get("/api/v1/sharedInboxes/#{inbox_id}/messages#{query}")
        
        if ENV['DEBUG']
          puts "Fetching messages for inbox #{inbox_id}"
          puts "Response status: #{response.status}"
        end
        
        if response.status == 200
          data = JSON.parse(response.body, symbolize_names: true)
          messages = data[:messages] || []
          puts "Found #{messages.count} messages" if ENV['DEBUG']
          return messages
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          return []
        end
      rescue => e
        puts "Error fetching messages: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        return []
      end
    end
    
    # Get settings for this shared inbox - direct Faraday implementation
    def settings
      # Support both Hash objects and model objects
      inbox_id = self.is_a?(Hash) ? self[:id] : self.id
      return {} unless inbox_id
      
      begin
        conn = FubClient::SharedInbox.create_faraday_connection
        return {} unless conn
        
        # Make the direct request
        response = conn.get("/api/v1/sharedInboxes/#{inbox_id}/settings")
        
        if ENV['DEBUG']
          puts "Fetching settings for inbox #{inbox_id}"
          puts "Response status: #{response.status}"
        end
        
        if response.status == 200
          data = JSON.parse(response.body, symbolize_names: true)
          settings = data[:settings] || {}
          puts "Settings retrieved successfully" if ENV['DEBUG']
          return settings
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          return {}
        end
      rescue => e
        puts "Error fetching settings: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        return {}
      end
    end
    
    # Get conversations in this shared inbox - direct Faraday implementation
    def conversations(limit = 20, offset = 0, filter = nil)
      # Support both Hash objects and model objects
      inbox_id = self.is_a?(Hash) ? self[:id] : self.id
      return [] unless inbox_id
      
      begin
        conn = FubClient::SharedInbox.create_faraday_connection
        return [] unless conn
        
        # Build query parameters
        query = "?limit=#{limit}&offset=#{offset}"
        query += "&filter=#{URI.encode_www_form_component(filter)}" if filter
        
        # Make the direct request
        response = conn.get("/api/v1/sharedInboxes/#{inbox_id}/conversations#{query}")
        
        if ENV['DEBUG']
          puts "Fetching conversations for inbox #{inbox_id}"
          puts "Response status: #{response.status}"
        end
        
        if response.status == 200
          data = JSON.parse(response.body, symbolize_names: true)
          conversations = data[:conversations] || []
          puts "Found #{conversations.count} conversations" if ENV['DEBUG']
          return conversations
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          return []
        end
      rescue => e
        puts "Error fetching conversations: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        return []
      end
    end
  end

  class SharedInbox < Resource
    collection_path "sharedInboxes"
    root_element :shared_inbox
    include_root_in_json true
    
    # Get all shared inboxes - using direct Faraday approach for reliable cookie auth
    def self.all_inboxes
      begin
        # Add debug output
        puts "Calling SharedInbox.all_inboxes using direct cookie authentication" if ENV['DEBUG']
        
        # Get client info
        client = FubClient::Client.instance
        cookies = client.cookies
        subdomain = client.subdomain
        
        if !cookies || cookies.empty?
          puts "Error: No cookies available for authentication" if ENV['DEBUG']
          return []
        end
        
        if !subdomain || subdomain.empty?
          puts "Error: No subdomain set for authentication" if ENV['DEBUG']
          return []
        end
        
        # Create direct Faraday connection with cookie
        conn = Faraday.new(url: "https://#{subdomain}.followupboss.com") do |f|
          f.headers['Cookie'] = cookies
          f.headers['Accept'] = 'application/json, text/javascript, */*; q=0.01'
          f.headers['Accept-Language'] = 'en-US,en;q=0.9'
          f.headers['X-Requested-With'] = 'XMLHttpRequest'
          f.headers['X-System'] = 'fub-spa'
          f.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36'
          f.adapter :net_http
        end
        
        # Make the direct request
        response = conn.get("/api/v1/sharedInboxes?showAllBypass=true&limit=20&offset=0")
        
        # Debug
        if ENV['DEBUG']
          puts "Request headers:"
          conn.headers.each do |k, v|
            if k.downcase == 'cookie' && v.length > 50
              puts "  #{k}: #{v[0..50]}..."
            else
              puts "  #{k}: #{v}"
            end
          end
          puts "Response status: #{response.status}"
          puts "Response body: #{response.body[0..100]}..." if response.body && response.body.length > 100
        end
        
        # Parse the response
        if response.status == 200
          data = JSON.parse(response.body, symbolize_names: true)
          inboxes = data[:sharedInboxes] || []
          puts "Found #{inboxes.count} shared inboxes via direct request" if ENV['DEBUG']
          inboxes
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          []
        end
      rescue => e
        puts "Error in all_inboxes: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        []
      end
    end
    
    # Get a specific shared inbox by ID - using direct Faraday approach
    def self.get_inbox(id)
      begin
        # Add debug output
        puts "Calling SharedInbox.get_inbox(#{id}) using direct cookie authentication" if ENV['DEBUG']
        
        # Get client info
        client = FubClient::Client.instance
        cookies = client.cookies
        subdomain = client.subdomain
        
        if !cookies || cookies.empty?
          puts "Error: No cookies available for authentication" if ENV['DEBUG']
          return nil
        end
        
        if !subdomain || subdomain.empty?
          puts "Error: No subdomain set for authentication" if ENV['DEBUG']
          return nil
        end
        
        # Create direct Faraday connection with cookie
        conn = Faraday.new(url: "https://#{subdomain}.followupboss.com") do |f|
          f.headers['Cookie'] = cookies
          f.headers['Accept'] = 'application/json, text/javascript, */*; q=0.01'
          f.headers['Accept-Language'] = 'en-US,en;q=0.9'
          f.headers['X-Requested-With'] = 'XMLHttpRequest'
          f.headers['X-System'] = 'fub-spa'
          f.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36'
          f.adapter :net_http
        end
        
        # Make the direct request
        response = conn.get("/api/v1/sharedInboxes/#{id}")
        
        # Debug
        if ENV['DEBUG']
          puts "Response status: #{response.status}"
          puts "Response body: #{response.body[0..100]}..." if response.body && response.body.length > 100
        end
        
        # Parse the response
        if response.status == 200
          # First, log the raw response for debugging
          if ENV['DEBUG']
            puts "Raw response body: #{response.body[0..200]}..." if response.body.length > 200
            puts "Raw response body: #{response.body}" if response.body.length <= 200
          end
          
          # Parse with symbolized names
          data = JSON.parse(response.body, symbolize_names: true)
          
          if ENV['DEBUG']
            puts "Parsed data keys: #{data.keys.inspect}"
            puts "Parsed data type: #{data.class}"
            puts "Has :id key? #{data.key?(:id)}"
            puts "ID value: #{data[:id]}" if data.key?(:id)
          end
          
          # Return data directly - it already contains what we need
          if data.is_a?(Hash) && !data.empty?
            puts "Found inbox with ID #{id} via direct request" if ENV['DEBUG']
            # Extend the hash with SharedInbox instance methods
            data.extend(SharedInboxMethods)
            return data
          else
            puts "Unexpected response structure: #{data.inspect}" if ENV['DEBUG']
            nil
          end
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          nil
        end
      rescue => e
        puts "Error in get_inbox: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        nil
      end
    end
    
    # Helper method to create a Faraday connection with the proper cookie auth
    def self.create_faraday_connection
      client = FubClient::Client.instance
      cookies = client.cookies
      subdomain = client.subdomain
      
      if !cookies || cookies.empty?
        puts "Error: No cookies available for authentication" if ENV['DEBUG']
        return nil
      end
      
      if !subdomain || subdomain.empty?
        puts "Error: No subdomain set for authentication" if ENV['DEBUG']
        return nil
      end
      
      # Create Faraday connection with cookie
      Faraday.new(url: "https://#{subdomain}.followupboss.com") do |f|
        f.headers['Cookie'] = cookies
        f.headers['Accept'] = 'application/json, text/javascript, */*; q=0.01'
        f.headers['Accept-Language'] = 'en-US,en;q=0.9'
        f.headers['X-Requested-With'] = 'XMLHttpRequest'
        f.headers['X-System'] = 'fub-spa'
        f.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36'
        f.adapter :net_http
      end
    end
    
    # Instance methods for hash-like objects returned from direct API requests
    
    # Get messages in this shared inbox - direct Faraday implementation
    def messages(limit = 20, offset = 0)
      # Support both Hash objects and model objects
      inbox_id = self.is_a?(Hash) ? self[:id] : self.id
      return [] unless inbox_id
      
      begin
        conn = self.class.create_faraday_connection
        return [] unless conn
        
        # Build query parameters
        query = "?limit=#{limit}&offset=#{offset}"
        
        # Make the direct request
        response = conn.get("/api/v1/sharedInboxes/#{inbox_id}/messages#{query}")
        
        if ENV['DEBUG']
          puts "Fetching messages for inbox #{inbox_id}"
          puts "Response status: #{response.status}"
        end
        
        if response.status == 200
          data = JSON.parse(response.body, symbolize_names: true)
          messages = data[:messages] || []
          puts "Found #{messages.count} messages" if ENV['DEBUG']
          return messages
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          return []
        end
      rescue => e
        puts "Error fetching messages: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        return []
      end
    end
    
    # Get settings for this shared inbox - direct Faraday implementation
    def settings
      # Support both Hash objects and model objects
      inbox_id = self.is_a?(Hash) ? self[:id] : self.id
      return {} unless inbox_id
      
      begin
        conn = self.class.create_faraday_connection
        return {} unless conn
        
        # Make the direct request
        response = conn.get("/api/v1/sharedInboxes/#{inbox_id}/settings")
        
        if ENV['DEBUG']
          puts "Fetching settings for inbox #{inbox_id}"
          puts "Response status: #{response.status}"
        end
        
        if response.status == 200
          data = JSON.parse(response.body, symbolize_names: true)
          settings = data[:settings] || {}
          puts "Settings retrieved successfully" if ENV['DEBUG']
          return settings
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          return {}
        end
      rescue => e
        puts "Error fetching settings: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        return {}
      end
    end
    
    # Update settings for this shared inbox - direct Faraday implementation
    def update_settings(settings_hash)
      # Support both Hash objects and model objects
      inbox_id = self.is_a?(Hash) ? self[:id] : self.id
      return false unless inbox_id && settings_hash.is_a?(Hash)
      
      begin
        conn = self.class.create_faraday_connection
        return false unless conn
        
        # Make the direct request
        response = conn.put do |req|
          req.url "/api/v1/sharedInboxes/#{inbox_id}/settings"
          req.headers['Content-Type'] = 'application/json'
          req.body = JSON.generate({ settings: settings_hash })
        end
        
        if ENV['DEBUG']
          puts "Updating settings for inbox #{inbox_id}"
          puts "Response status: #{response.status}"
        end
        
        if response.status == 200 || response.status == 204
          puts "Settings updated successfully" if ENV['DEBUG']
          return true
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          return false
        end
      rescue => e
        puts "Error updating settings: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        return false
      end
    end
    
    # Get conversations in this shared inbox - direct Faraday implementation
    def conversations(limit = 20, offset = 0, filter = nil)
      # Support both Hash objects and model objects
      inbox_id = self.is_a?(Hash) ? self[:id] : self.id
      return [] unless inbox_id
      
      begin
        conn = self.class.create_faraday_connection
        return [] unless conn
        
        # Build query parameters
        query = "?limit=#{limit}&offset=#{offset}"
        query += "&filter=#{URI.encode_www_form_component(filter)}" if filter
        
        # Make the direct request
        response = conn.get("/api/v1/sharedInboxes/#{inbox_id}/conversations#{query}")
        
        if ENV['DEBUG']
          puts "Fetching conversations for inbox #{inbox_id}"
          puts "Response status: #{response.status}"
        end
        
        if response.status == 200
          data = JSON.parse(response.body, symbolize_names: true)
          conversations = data[:conversations] || []
          puts "Found #{conversations.count} conversations" if ENV['DEBUG']
          return conversations
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          return []
        end
      rescue => e
        puts "Error fetching conversations: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        return []
      end
    end
  end
end
