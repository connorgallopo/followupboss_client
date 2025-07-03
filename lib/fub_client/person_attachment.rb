module FubClient
  class PersonAttachment < Resource
    collection_path 'personAttachments'
    root_element :person_attachment
    include_root_in_json true

    scope :for_person, ->(person_id) { where(personId: person_id) }
    scope :by_type, ->(type) { where(type: type) }
    scope :by_name, ->(name) { where(q: name) }

    def person
      return nil unless respond_to?(:person_id) && person_id

      FubClient::Person.find(person_id)
    end

    def self.upload(person_id, file_path, name = nil, type = nil, description = nil)
      params = {
        personId: person_id,
        file: File.new(file_path, 'rb')
      }
      params[:name] = name if name
      params[:type] = type if type
      params[:description] = description if description

      post('', params)
    end

    def download
      return nil unless id

      begin
        self.class.get("#{id}/download")
      rescue StandardError
        nil
      end
    end

    def delete
      return false unless id

      begin
        self.class.delete(id.to_s)
        true
      rescue StandardError
        false
      end
    end
  end
end
