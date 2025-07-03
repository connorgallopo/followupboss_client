module FubClient
  class TeamInbox < Resource
    collection_path 'teamInboxes'
    root_element :team_inbox
    include_root_in_json true

    # Get all team inboxes
    def self.all_inboxes
      get('')
    rescue StandardError
      []
    end

    # Helper method to get the team associated with this inbox
    def team
      return nil unless respond_to?(:team_id) && team_id

      FubClient::Team.find(team_id)
    end

    # Get messages in this team inbox
    def messages(limit = 20, offset = 0)
      return [] unless id

      begin
        params = {
          limit: limit,
          offset: offset
        }

        response = self.class.get("#{id}/messages", params)
        response[:messages] || []
      rescue StandardError
        []
      end
    end

    # Get participants in a conversation
    def participants(conversation_id)
      return [] unless id && conversation_id

      begin
        response = self.class.get("#{id}/conversations/#{conversation_id}/participants")
        response[:participants] || []
      rescue StandardError
        []
      end
    end

    # Add a message to a conversation
    def add_message(conversation_id, content, user_id = nil)
      return false unless id && conversation_id && content

      params = { content: content }
      params[:userId] = user_id if user_id

      begin
        self.class.post("#{id}/conversations/#{conversation_id}/messages", params)
        true
      rescue StandardError
        false
      end
    end
  end
end
