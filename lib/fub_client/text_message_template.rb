module FubClient
  class TextMessageTemplate < Resource
    collection_path "textMessageTemplates"
    root_element :text_message_template
    include_root_in_json true
    
    # Convenience method to find templates by category
    scope :by_category, -> (category) { where(category: category) }
    
    # Convenience method to find active templates
    def self.active
      where(active: true)
    end
    
    # Convenience method to find inactive templates
    def self.inactive
      where(active: false)
    end
    
    # Merge template with person data
    def merge(person_id)
      return nil unless id && person_id
      
      begin
        self.class.post("merge", { id: id, personId: person_id })
      rescue
        nil
      end
    end
    
    # Send template as a text message to a person
    def send_to(person_id, user_id = nil)
      return false unless id && person_id
      
      params = {
        templateId: id,
        personId: person_id
      }
      params[:userId] = user_id if user_id
      
      begin
        TextMessage.post("", params)
        true
      rescue
        false
      end
    end
  end
end
