module FubClient
  class Deal < Resource
    collection_path "deals"
    root_element :deal
    include_root_in_json true
    
    # Convenience methods for finding deals by stage
    scope :by_stage, -> (stage_id) { where(stageId: stage_id) }
    
    # Convenience methods for finding deals by person
    scope :for_person, -> (person_id) { where(personId: person_id) }
    
    # Convenience methods for finding deals by date range
    scope :closing_between, -> (start_date, end_date) { 
      where(closeDateStart: start_date, closeDateEnd: end_date) 
    }
    
    # Convenience method for finding deals by price range
    scope :by_price_range, -> (min, max) { where(minPrice: min, maxPrice: max) }
    
    # Convenience method for finding deals by agent/user
    scope :assigned_to, -> (user_id) { where(assignedTo: user_id) }
    
    # Get open/active deals
    def self.active
      where(status: 'active')
    end
    
    # Get closed/won deals
    def self.won
      where(status: 'won')
    end
    
    # Get lost deals
    def self.lost
      where(status: 'lost')
    end
    
    # Convenience method to get the people associated with a deal
    def people
      return [] unless respond_to?(:person_ids) && person_ids.is_a?(Array)
      
      person_ids.map do |id|
        FubClient::Person.find(id)
      end.compact
    end
    
    # Convenience method to get the property associated with a deal
    def property
      return nil unless respond_to?(:property_id) && property_id
      
      FubClient::Property.find(property_id)
    end
  end
end
