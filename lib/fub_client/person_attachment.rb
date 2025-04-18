module FubClient
  class PersonAttachment < Resource
    collection_path "personAttachments"
    root_element :person_attachment
    include_root_in_json true
    
    # Convenience method to find attachments by person
    scope :for_person, -> (person_id) { where(personId: person_id) }
    
    # Convenience method to find attachments by type
    scope :by_type, -> (type) { where(type: type) }
    
    # Convenience method to find attachments by name (partial match)
    scope :by_name, -> (name) { where(q: name) }
    
    # Helper method to get the person for this attachment
    def person
      return nil unless respond_to?(:person_id) && person_id
      
      FubClient::Person.find(person_id)
    end
    
    # Upload a new attachment for a person
    def self.upload(person_id, file_path, name = nil, type = nil, description = nil)
      # This would typically be implemented with a multipart form,
      # but we'll just define the interface here
      params = {
        personId: person_id,
        file: File.new(file_path, 'rb')
      }
      params[:name] = name if name
      params[:type] = type if type
      params[:description] = description if description
      
      post("", params)
    end
    
    # Download the attachment content
    def download
      return nil unless id
      
      begin
        self.class.get("#{id}/download")
      rescue
        nil
      end
    end
    
    # Delete the attachment
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
