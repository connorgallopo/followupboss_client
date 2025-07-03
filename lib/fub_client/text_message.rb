module FubClient
  class TextMessage < Resource
    collection_path 'textMessages'
    root_element :text_message
    include_root_in_json true

    scope :for_person, ->(person_id) { where(personId: person_id) }
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

    def person
      return nil unless respond_to?(:person_id) && person_id

      FubClient::Person.find(person_id)
    end

    def user
      return nil unless respond_to?(:user_id) && user_id

      FubClient::User.find(user_id)
    end

    def self.send_message(person_id, message, user_id = nil)
      params = {
        personId: person_id,
        message: message
      }
      params[:userId] = user_id if user_id

      post('', params)
    end

    def mark_as_read
      self.class.put("#{id}/read", {})
    end
  end
end
