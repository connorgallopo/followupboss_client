module FubClient
  class Team < Resource
    collection_path 'teams'
    root_element :team
    include_root_in_json true

    # Convenience method to find teams by name (partial match)
    scope :by_name, ->(name) { where(q: name) }

    # Convenience method to find active teams
    def self.active
      where(active: true)
    end

    # Get users who are members of this team
    def members
      return [] unless id

      begin
        response = self.class.get("#{id}/members")
        response[:members] || []
      rescue StandardError
        []
      end
    end

    # Add a user to this team
    def add_user(user_id, team_leader = false)
      return false unless id && user_id

      params = { userId: user_id }
      params[:teamLeader] = team_leader if team_leader

      begin
        self.class.post("#{id}/members", params)
        true
      rescue StandardError
        false
      end
    end

    # Remove a user from this team
    def remove_user(user_id)
      return false unless id && user_id

      begin
        self.class.delete("#{id}/members/#{user_id}")
        true
      rescue StandardError
        false
      end
    end

    # Get team statistics
    def stats
      return {} unless id

      begin
        self.class.get("#{id}/stats")
      rescue StandardError
        {}
      end
    end
  end
end
