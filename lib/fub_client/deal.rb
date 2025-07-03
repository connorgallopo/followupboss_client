module FubClient
  class Deal < Resource
    collection_path 'deals'
    root_element :deal
    include_root_in_json true

    scope :by_stage, ->(stage_id) { where(stageId: stage_id) }
    scope :for_person, ->(person_id) { where(personId: person_id) }
    scope :closing_between, lambda { |start_date, end_date|
      where(closeDateStart: start_date, closeDateEnd: end_date)
    }
    scope :by_price_range, ->(min, max) { where(minPrice: min, maxPrice: max) }
    scope :assigned_to, ->(user_id) { where(assignedTo: user_id) }

    def self.active
      where(status: 'active')
    end

    def self.won
      where(status: 'won')
    end

    def self.lost
      where(status: 'lost')
    end

    def people
      return [] unless respond_to?(:person_ids) && person_ids.is_a?(Array)

      person_ids.map do |id|
        FubClient::Person.find(id)
      end.compact
    end

    def property
      return nil unless respond_to?(:property_id) && property_id

      FubClient::Property.find(property_id)
    end
  end
end
