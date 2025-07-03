module FubClient
  class Message < Resource
    collection_path 'messages'
    root_element :message
    include_root_in_json true

    scope :for_person, ->(person_id) { where(personId: person_id) }
    scope :by_type, ->(type) { where(type: type) }
    scope :sent_between, lambda { |start_date, end_date|
      where(startDate: start_date, endDate: end_date)
    }
    scope :inbound, -> { where(direction: 'inbound') }
    scope :outbound, -> { where(direction: 'outbound') }
    scope :by_user, ->(user_id) { where(userId: user_id) }
    scope :search, ->(query) { where(q: query) }

    def self.unread
      where(read: false)
    end

    def self.with_attachments
      where(hasAttachments: true)
    end

    def mark_as_read
      self.class.put("#{id}/read", {})
    end

    def person
      return nil unless respond_to?(:person_id) && person_id

      FubClient::Person.find(person_id)
    end

    def user
      return nil unless respond_to?(:user_id) && user_id

      FubClient::User.find(user_id)
    end
  end
end
