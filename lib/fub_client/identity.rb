module FubClient
  class Identity < Resource
    collection_path 'identity'
    root_element :identity
    include_root_in_json true

    def self.current
      get('')
    rescue StandardError
      nil
    end

    def user
      return nil unless respond_to?(:user_id) && user_id

      FubClient::User.find(user_id)
    end

    def teams
      return [] unless respond_to?(:team_ids) && team_ids.is_a?(Array)

      team_ids.map do |id|
        FubClient::Team.find(id)
      end.compact
    end

    def has_permission?(permission)
      return false unless respond_to?(:permissions) && permissions.is_a?(Array)

      permissions.include?(permission)
    end
  end
end
