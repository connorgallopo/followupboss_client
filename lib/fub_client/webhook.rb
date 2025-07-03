module FubClient
  class Webhook < Resource
    collection_path 'webhooks'
    root_element :webhook
    include_root_in_json true

    # Convenience method to find webhooks by event type
    scope :by_event_type, ->(event_type) { where(eventType: event_type) }

    # Convenience method to find active webhooks
    def self.active
      where(active: true)
    end

    # Convenience method to find inactive webhooks
    def self.inactive
      where(active: false)
    end

    # Get webhook events
    def events(limit = 10)
      return [] unless id

      begin
        response = self.class.get("#{id}/events", { limit: limit })
        response[:events] || []
      rescue StandardError
        []
      end
    end

    # Activate a webhook
    def activate
      self.class.put("#{id}/activate", {})
    end

    # Deactivate a webhook
    def deactivate
      self.class.put("#{id}/deactivate", {})
    end

    # Test a webhook by sending a test event
    def test
      self.class.post("#{id}/test", {})
    end
  end
end
