module FubClient
  class DealCustomField < Resource
    collection_path "dealCustomFields"
    root_element :deal_custom_field
    include_root_in_json true
    
    # Convenience method to find custom fields by type
    scope :by_type, -> (type) { where(type: type) }
    
    # Convenience method to find custom fields by name (partial match)
    scope :by_name, -> (name) { where(q: name) }
    
    # Convenience method to find active custom fields
    def self.active
      where(active: true)
    end
    
    # Convenience method to find inactive custom fields
    def self.inactive
      where(active: false)
    end
    
    # Update a custom field
    def update(attributes)
      return false unless id
      
      begin
        self.class.put(id.to_s, attributes)
        true
      rescue
        false
      end
    end
    
    # Delete a custom field
    def delete
      return false unless id
      
      begin
        self.class.delete(id.to_s)
        true
      rescue
        false
      end
    end
  end
end
