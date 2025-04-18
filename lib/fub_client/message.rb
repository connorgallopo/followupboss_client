module FubClient
  class Message < Resource
    collection_path "messages"
    root_element :message
    include_root_in_json true
    
    # Convenience method to find messages by person
    scope :for_person, -> (person_id) { where(personId: person_id) }
    
    # Convenience method to find messages by type (email or sms)
    scope :by_type, -> (type) { where(type: type) }
    
    # Convenience method to find messages by date range
    scope :sent_between, -> (start_date, end_date) { 
      where(startDate: start_date, endDate: end_date) 
    }
    
    # Convenience method to find messages by direction (inbound or outbound)
    scope :inbound, -> { where(direction: 'inbound') }
    scope :outbound, -> { where(direction: 'outbound') }
    
    # Convenience method to find messages by user who sent/received them
    scope :by_user, -> (user_id) { where(userId: user_id) }
    
    # Convenience method to search message content
    scope :search, -> (query) { where(q: query) }
    
    # Convenience method to get unread messages
    def self.unread
      where(read: false)
    end
    
    # Convenience method to find messages with attachments
    def self.with_attachments
      where(hasAttachments: true)
    end
    
    # Helper method to mark a message as read
    def mark_as_read
      self.class.put("#{id}/read", {})
    end
    
    # Helper method to get the person associated with this message
    def person
      return nil unless respond_to?(:person_id) && person_id
      
      FubClient::Person.find(person_id)
    end
    
    # Helper method to get the user associated with this message
    def user
      return nil unless respond_to?(:user_id) && user_id
      
      FubClient::User.find(user_id)
    end
  end
end
