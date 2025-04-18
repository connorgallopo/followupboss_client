module FubClient
  class Appointment < Resource
    collection_path "appointments"
    root_element :appointment
    include_root_in_json true
    
    # Convenience scope to find appointments by date range
    scope :between, -> (start_date, end_date) { 
      where(startDate: start_date, endDate: end_date) 
    }
    
    # Convenience scope to find appointments by person
    scope :for_person, -> (person_id) { where(personId: person_id) }
    
    # Convenience scope to find appointments by user
    scope :by_user, -> (user_id) { where(userId: user_id) }
    
    # Convenience scope to find appointments by type
    scope :by_type, -> (type_id) { where(typeId: type_id) }
    
    # Convenience scope to find appointments by outcome
    scope :by_outcome, -> (outcome_id) { where(outcomeId: outcome_id) }
    
    # Find upcoming appointments
    def self.upcoming
      where(startDate: Time.now.iso8601)
    end
    
    # Find past appointments
    def self.past
      where(endDate: Time.now.iso8601, order: 'desc')
    end
    
    # Helper method to get the person associated with this appointment
    def person
      return nil unless respond_to?(:person_id) && person_id
      
      FubClient::Person.find(person_id)
    end
    
    # Helper method to get the user associated with this appointment
    def user
      return nil unless respond_to?(:user_id) && user_id
      
      FubClient::User.find(user_id)
    end
    
    # Mark appointment as completed with an outcome
    def complete(outcome_id, notes = nil)
      params = { outcomeId: outcome_id }
      params[:notes] = notes if notes
      
      self.class.put("#{id}/complete", params)
    end
  end
end
