module FubClient
  class Appointment < Resource
    collection_path "appointments"
    root_element :appointment
    include_root_in_json true
    
    scope :between, -> (start_date, end_date) { 
      where(startDate: start_date, endDate: end_date) 
    }
    scope :for_person, -> (person_id) { where(personId: person_id) }
    scope :by_user, -> (user_id) { where(userId: user_id) }
    scope :by_type, -> (type_id) { where(typeId: type_id) }
    scope :by_outcome, -> (outcome_id) { where(outcomeId: outcome_id) }
    
    def self.upcoming
      where(startDate: Time.now.iso8601)
    end
    
    def self.past
      where(endDate: Time.now.iso8601, order: 'desc')
    end
    
    def person
      return nil unless respond_to?(:person_id) && person_id
      
      FubClient::Person.find(person_id)
    end
    
    def user
      return nil unless respond_to?(:user_id) && user_id
      
      FubClient::User.find(user_id)
    end
    
    def complete(outcome_id, notes = nil)
      params = { outcomeId: outcome_id }
      params[:notes] = notes if notes
      
      self.class.put("#{id}/complete", params)
    end
  end
end
