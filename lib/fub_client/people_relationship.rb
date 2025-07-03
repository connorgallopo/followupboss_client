module FubClient
  class PeopleRelationship < Resource
    collection_path 'peopleRelationships'
    root_element :people_relationship
    include_root_in_json true

    scope :for_person, ->(person_id) { where(personId: person_id) }
    scope :with_related_person, ->(related_person_id) { where(relatedPersonId: related_person_id) }
    scope :by_type, ->(type) { where(type: type) }

    def person
      return nil unless respond_to?(:person_id) && person_id

      FubClient::Person.find(person_id)
    end

    def related_person
      return nil unless respond_to?(:related_person_id) && related_person_id

      FubClient::Person.find(related_person_id)
    end

    def self.create_relationship(person_id, related_person_id, type, description = nil)
      params = {
        personId: person_id,
        relatedPersonId: related_person_id,
        type: type
      }
      params[:description] = description if description

      post('', params)
    end
  end
end
