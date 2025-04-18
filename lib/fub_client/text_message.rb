module FubClient
  class TextMessage < Resource
    collection_path "textMessages"
    root_element :text_message
    include_root_in_json true
    
    # Convenience method to find text messages by person
    scope :for_person, -> (person_id) { where(personId: person_id) }
    
    # Convenience method to find text messages by date range
    scope :sent_between, -> (start_date, end_date) { 
      where(startDate: start_date, endDate: end_date) 
    }
    
    # Convenience method to find text messages by direction
    scope :inbound, -> { where(direction: 'inbound') }
    scope :outbound, -> { where(direction: 'outbound') }
    
    # Convenience method to find text messages by user
    scope :by_user, -> (user_id) { where(userId: user_id) }
    
    # Convenience method to search message text
    scope :search, -> (query) { where(q: query) }
    
    # Convenience method to get unread messages
    def self.unread
      where(read: false)
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
    
    # Helper method to send a text message
    def self.send_message(person_id, message, user_id = nil)
      params = {
        personId: person_id,
        message: message
      }
      params[:userId] = user_id if user_id
      
      post("", params)
    end
    
    # Helper method to mark a text message as read
    def mark_as_read
      self.class.put("#{id}/read", {})
    end
  end
end
