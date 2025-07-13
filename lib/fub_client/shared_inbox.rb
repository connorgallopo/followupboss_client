module FubClient
  module SharedInboxMethods
    def messages(limit = 20, offset = 0)
      inbox_id = is_a?(Hash) ? self[:id] : id
      return [] unless inbox_id

      begin
        conn = FubClient::SharedInbox.create_faraday_connection
        return [] unless conn

        query = "?limit=#{limit}&offset=#{offset}"
        response = conn.get("/api/v1/sharedInboxes/#{inbox_id}/messages#{query}")

        if ENV['DEBUG']
          puts "Fetching messages for inbox #{inbox_id}"
          puts "Response status: #{response.status}"
        end

        if response.status == 200
          data = JSON.parse(response.body, symbolize_names: true)
          messages = data[:messages] || []
          puts "Found #{messages.count} messages" if ENV['DEBUG']
          messages
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          []
        end
      rescue StandardError => e
        puts "Error fetching messages: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        []
      end
    end

    def settings
      inbox_id = is_a?(Hash) ? self[:id] : id
      return {} unless inbox_id

      begin
        conn = FubClient::SharedInbox.create_faraday_connection
        return {} unless conn

        response = conn.get("/api/v1/sharedInboxes/#{inbox_id}/settings")

        if ENV['DEBUG']
          puts "Fetching settings for inbox #{inbox_id}"
          puts "Response status: #{response.status}"
        end

        if response.status == 200
          data = JSON.parse(response.body, symbolize_names: true)
          settings = data[:settings] || {}
          puts 'Settings retrieved successfully' if ENV['DEBUG']
          settings
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          {}
        end
      rescue StandardError => e
        puts "Error fetching settings: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        {}
      end
    end

    def conversations(limit = 20, offset = 0, filter = nil)
      inbox_id = is_a?(Hash) ? self[:id] : id
      return [] unless inbox_id

      begin
        conn = FubClient::SharedInbox.create_faraday_connection
        return [] unless conn

        query = "?limit=#{limit}&offset=#{offset}"
        query += "&filter=#{URI.encode_www_form_component(filter)}" if filter

        response = conn.get("/api/v1/sharedInboxes/#{inbox_id}/conversations#{query}")

        if ENV['DEBUG']
          puts "Fetching conversations for inbox #{inbox_id}"
          puts "Response status: #{response.status}"
        end

        if response.status == 200
          data = JSON.parse(response.body, symbolize_names: true)
          conversations = data[:conversations] || []
          puts "Found #{conversations.count} conversations" if ENV['DEBUG']
          conversations
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          []
        end
      rescue StandardError => e
        puts "Error fetching conversations: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        []
      end
    end
  end

  class SharedInbox < Resource
    collection_path 'sharedInboxes'
    root_element :shared_inbox
    include_root_in_json true

    def self.all_inboxes(cookie_client: nil)
      puts 'Calling SharedInbox.all_inboxes using cookie authentication' if ENV['DEBUG']

      client = resolve_cookie_client(cookie_client)
      return [] unless client

      conn = create_faraday_connection_from_client(client)
      return [] unless conn

      response = conn.get('/api/v1/sharedInboxes?showAllBypass=true&limit=200&offset=0')

      if ENV['DEBUG']
        puts "Response status: #{response.status}"
        puts "Response body: #{response.body[0..100]}..." if response.body && response.body.length > 100
      end

      if response.status == 200
        data = JSON.parse(response.body, symbolize_names: true)
        inboxes = data[:sharedInboxes] || []
        puts "Found #{inboxes.count} shared inboxes via cookie client" if ENV['DEBUG']
        inboxes
      else
        puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
        []
      end
    rescue StandardError => e
      puts "Error in all_inboxes: #{e.message}" if ENV['DEBUG']
      puts e.backtrace.join("\n") if ENV['DEBUG']
      []
    end

    def self.get_inbox(id, cookie_client: nil)
      puts "Calling SharedInbox.get_inbox(#{id}) using cookie authentication" if ENV['DEBUG']

      client = resolve_cookie_client(cookie_client)
      return nil unless client

      conn = create_faraday_connection_from_client(client)
      return nil unless conn

      response = conn.get("/api/v1/sharedInboxes/#{id}")

      if ENV['DEBUG']
        puts "Response status: #{response.status}"
        puts "Response body: #{response.body[0..100]}..." if response.body && response.body.length > 100
      end

      if response.status == 200
        if ENV['DEBUG']
          puts "Raw response body: #{response.body[0..200]}..." if response.body.length > 200
          puts "Raw response body: #{response.body}" if response.body.length <= 200
        end

        data = JSON.parse(response.body, symbolize_names: true)

        if ENV['DEBUG']
          puts "Parsed data keys: #{data.keys.inspect}"
          puts "Parsed data type: #{data.class}"
          puts "Has :id key? #{data.key?(:id)}"
          puts "ID value: #{data[:id]}" if data.key?(:id)
        end

        if data.is_a?(Hash) && !data.empty?
          puts "Found inbox with ID #{id} via cookie client" if ENV['DEBUG']
          data.extend(SharedInboxMethods)
          data
        else
          puts "Unexpected response structure: #{data.inspect}" if ENV['DEBUG']
          nil
        end
      else
        puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
        nil
      end
    rescue StandardError => e
      puts "Error in get_inbox: #{e.message}" if ENV['DEBUG']
      puts e.backtrace.join("\n") if ENV['DEBUG']
      nil
    end

    def self.update_inbox(id, attributes, cookie_client: nil, merge_with_existing: true)
      puts "Calling SharedInbox.update_inbox(#{id}) using cookie authentication" if ENV['DEBUG']

      client = resolve_cookie_client(cookie_client)
      return nil unless client

      # If merge_with_existing is true, get current inbox data and merge
      if merge_with_existing
        current_inbox = get_inbox(id, cookie_client: client)
        unless current_inbox
          puts 'Error: Could not retrieve current inbox data for merging' if ENV['DEBUG']
          return nil
        end

        # Create full payload by merging existing data with new attributes
        full_payload = {
          name: current_inbox[:name],
          phones: current_inbox[:phones] || [],
          users: current_inbox[:users] || [],
          replyFrom: current_inbox[:replyFrom] || "",
          replyFromPersonalized: current_inbox[:replyFromPersonalized] || false,
          officeHoursBehaviorType: current_inbox[:officeHoursBehaviorType] || "Voicemail",
          officeHoursForwardNumber: current_inbox[:officeHoursForwardNumber] || [],
          incomingForwardTeam: current_inbox[:incomingForwardTeam] || [],
          agentViewAll: current_inbox[:agentViewAll] || 0,
          incomingForwardNumber: current_inbox[:incomingForwardNumber] || [],
          incomingBehaviorType: current_inbox[:incomingBehaviorType] || "Voicemail",
          unansweredForwardNumber: current_inbox[:unansweredForwardNumber] || []
        }.merge(attributes)
        
        puts "Merged payload with existing data" if ENV['DEBUG']
      else
        full_payload = attributes
        puts "Using provided attributes without merging" if ENV['DEBUG']
      end

      conn = create_faraday_connection_from_client(client)
      return nil unless conn

      response = conn.put do |req|
        req.url "/api/v1/sharedInboxes/#{id}"
        req.headers['Content-Type'] = 'application/json; charset=UTF-8'
        req.headers['X-FUB-JS-Version'] = '198593'
        req.body = JSON.generate(full_payload)
      end

      if ENV['DEBUG']
        puts "Update response status: #{response.status}"
        puts "Update response body: #{response.body[0..200]}..." if response.body && response.body.length > 200
      end

      if [200, 204].include?(response.status)
        if response.status == 200 && !response.body.empty?
          data = JSON.parse(response.body, symbolize_names: true)
          puts "Updated inbox with ID #{id} via cookie client" if ENV['DEBUG']
          data.extend(SharedInboxMethods) if data.is_a?(Hash)
          data
        else
          puts "Updated inbox with ID #{id} (no response body)" if ENV['DEBUG']
          true
        end
      else
        puts "Error updating inbox: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
        nil
      end
    rescue StandardError => e
      puts "Error in update_inbox: #{e.message}" if ENV['DEBUG']
      puts e.backtrace.join("\n") if ENV['DEBUG']
      nil
    end

    def self.find_by_phone(phone_number, cookie_client: nil)
      puts "Calling SharedInbox.find_by_phone(#{phone_number}) using cookie authentication" if ENV['DEBUG']

      client = resolve_cookie_client(cookie_client)
      return nil unless client

      # Get all inboxes (now with limit=200, should cover all 142 inboxes)
      inboxes = all_inboxes(cookie_client: client)
      return nil if inboxes.empty?

      # Normalize the phone number for comparison (remove formatting)
      normalized_search = normalize_phone(phone_number)
      
      puts "Searching #{inboxes.length} inboxes for phone: #{phone_number} (normalized: #{normalized_search})" if ENV['DEBUG']

      # Search through all inboxes for matching phone number
      matching_inbox = inboxes.find do |inbox|
        phones = inbox[:phones] || []
        phones.any? do |phone_obj|
          phone = phone_obj[:phone] || phone_obj['phone']
          next false unless phone
          
          normalized_inbox_phone = normalize_phone(phone)
          match = normalized_inbox_phone == normalized_search
          
          if ENV['DEBUG']
            puts "  Checking inbox '#{inbox[:name]}' phone '#{phone}' (normalized: #{normalized_inbox_phone}) - Match: #{match}"
          end
          
          match
        end
      end

      if matching_inbox
        puts "Found matching inbox: '#{matching_inbox[:name]}' (ID: #{matching_inbox[:id]})" if ENV['DEBUG']
        matching_inbox.extend(SharedInboxMethods)
        matching_inbox
      else
        puts "No inbox found with phone number: #{phone_number}" if ENV['DEBUG']
        nil
      end
    rescue StandardError => e
      puts "Error in find_by_phone: #{e.message}" if ENV['DEBUG']
      puts e.backtrace.join("\n") if ENV['DEBUG']
      nil
    end


    private_class_method def self.resolve_cookie_client(cookie_client)
      # Use provided cookie_client or try to create one from configuration
      client = cookie_client || create_cookie_client
      
      unless client
        puts 'Error: No cookie client available for authentication' if ENV['DEBUG']
        return nil
      end
      
      client
    end

    private_class_method def self.normalize_phone(phone_number)
      # Remove all non-digit characters for comparison
      return '' unless phone_number
      phone_number.to_s.gsub(/\D/, '')
    end

    def self.create_cookie_client
      config = FubClient.configuration
      return nil unless config.has_cookie_auth?
      
      begin
        FubClient::CookieClient.new
      rescue => e
        puts "Error creating cookie client: #{e.message}" if ENV['DEBUG']
        nil
      end
    end

    def self.create_faraday_connection_from_client(cookie_client)
      return nil unless cookie_client && cookie_client.cookies && cookie_client.subdomain

      Faraday.new(url: "https://#{cookie_client.subdomain}.followupboss.com") do |f|
        f.headers['Cookie'] = cookie_client.cookies
        f.headers['Accept'] = 'application/json, text/javascript, */*; q=0.01'
        f.headers['Accept-Language'] = 'en-US,en;q=0.9'
        f.headers['X-Requested-With'] = 'XMLHttpRequest'
        f.headers['X-System'] = 'fub-spa'
        f.headers['User-Agent'] =
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36'
        f.adapter :net_http
      end
    end

    def self.create_faraday_connection
      client = FubClient::Client.instance
      cookies = client.cookies
      subdomain = client.subdomain

      if !cookies || cookies.empty?
        puts 'Error: No cookies available for authentication' if ENV['DEBUG']
        return nil
      end

      if !subdomain || subdomain.empty?
        puts 'Error: No subdomain set for authentication' if ENV['DEBUG']
        return nil
      end

      Faraday.new(url: "https://#{subdomain}.followupboss.com") do |f|
        f.headers['Cookie'] = cookies
        f.headers['Accept'] = 'application/json, text/javascript, */*; q=0.01'
        f.headers['Accept-Language'] = 'en-US,en;q=0.9'
        f.headers['X-Requested-With'] = 'XMLHttpRequest'
        f.headers['X-System'] = 'fub-spa'
        f.headers['User-Agent'] =
          'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/135.0.0.0 Safari/537.36'
        f.adapter :net_http
      end
    end

    def messages(limit = 20, offset = 0)
      inbox_id = is_a?(Hash) ? self[:id] : id
      return [] unless inbox_id

      begin
        conn = self.class.create_faraday_connection
        return [] unless conn

        query = "?limit=#{limit}&offset=#{offset}"
        response = conn.get("/api/v1/sharedInboxes/#{inbox_id}/messages#{query}")

        if ENV['DEBUG']
          puts "Fetching messages for inbox #{inbox_id}"
          puts "Response status: #{response.status}"
        end

        if response.status == 200
          data = JSON.parse(response.body, symbolize_names: true)
          messages = data[:messages] || []
          puts "Found #{messages.count} messages" if ENV['DEBUG']
          messages
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          []
        end
      rescue StandardError => e
        puts "Error fetching messages: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        []
      end
    end

    def settings
      inbox_id = is_a?(Hash) ? self[:id] : id
      return {} unless inbox_id

      begin
        conn = self.class.create_faraday_connection
        return {} unless conn

        response = conn.get("/api/v1/sharedInboxes/#{inbox_id}/settings")

        if ENV['DEBUG']
          puts "Fetching settings for inbox #{inbox_id}"
          puts "Response status: #{response.status}"
        end

        if response.status == 200
          data = JSON.parse(response.body, symbolize_names: true)
          settings = data[:settings] || {}
          puts 'Settings retrieved successfully' if ENV['DEBUG']
          settings
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          {}
        end
      rescue StandardError => e
        puts "Error fetching settings: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        {}
      end
    end

    def update_settings(settings_hash)
      inbox_id = is_a?(Hash) ? self[:id] : id
      return false unless inbox_id && settings_hash.is_a?(Hash)

      begin
        conn = self.class.create_faraday_connection
        return false unless conn

        response = conn.put do |req|
          req.url "/api/v1/sharedInboxes/#{inbox_id}/settings"
          req.headers['Content-Type'] = 'application/json'
          req.body = JSON.generate({ settings: settings_hash })
        end

        if ENV['DEBUG']
          puts "Updating settings for inbox #{inbox_id}"
          puts "Response status: #{response.status}"
        end

        if [200, 204].include?(response.status)
          puts 'Settings updated successfully' if ENV['DEBUG']
          true
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          false
        end
      rescue StandardError => e
        puts "Error updating settings: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        false
      end
    end

    def conversations(limit = 20, offset = 0, filter = nil)
      inbox_id = is_a?(Hash) ? self[:id] : id
      return [] unless inbox_id

      begin
        conn = self.class.create_faraday_connection
        return [] unless conn

        query = "?limit=#{limit}&offset=#{offset}"
        query += "&filter=#{URI.encode_www_form_component(filter)}" if filter

        response = conn.get("/api/v1/sharedInboxes/#{inbox_id}/conversations#{query}")

        if ENV['DEBUG']
          puts "Fetching conversations for inbox #{inbox_id}"
          puts "Response status: #{response.status}"
        end

        if response.status == 200
          data = JSON.parse(response.body, symbolize_names: true)
          conversations = data[:conversations] || []
          puts "Found #{conversations.count} conversations" if ENV['DEBUG']
          conversations
        else
          puts "Error: HTTP #{response.status} - #{response.body}" if ENV['DEBUG']
          []
        end
      rescue StandardError => e
        puts "Error fetching conversations: #{e.message}" if ENV['DEBUG']
        puts e.backtrace.join("\n") if ENV['DEBUG']
        []
      end
    end
  end
end
