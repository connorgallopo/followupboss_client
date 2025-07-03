module FubClient
  class Group < Resource
    collection_path 'groups'
    root_element :group
    include_root_in_json true

    # Convenience method to find groups by name (partial match)
    scope :by_name, ->(name) { where(q: name) }

    # Convenience method to find active groups
    def self.active
      where(active: true)
    end

    # Get members of this group
    def members
      return [] unless id

      begin
        response = self.class.get("#{id}/members")
        response[:members] || []
      rescue StandardError
        []
      end
    end

    # Add a user to this group
    def add_user(user_id)
      return false unless id && user_id

      begin
        self.class.post("#{id}/members", { userId: user_id })
        true
      rescue StandardError
        false
      end
    end

    # Remove a user from this group
    def remove_user(user_id)
      return false unless id && user_id

      begin
        self.class.delete("#{id}/members/#{user_id}")
        true
      rescue StandardError
        false
      end
    end

    # Get round-robin distribution information
    def self.round_robin
      get('roundRobin')
    rescue StandardError
      nil
    end
  end
end
