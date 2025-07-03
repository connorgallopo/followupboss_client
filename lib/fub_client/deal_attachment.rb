module FubClient
  class DealAttachment < Resource
    collection_path 'dealAttachments'
    root_element :deal_attachment
    include_root_in_json true

    # Convenience method to find attachments by deal
    scope :for_deal, ->(deal_id) { where(dealId: deal_id) }

    # Convenience method to find attachments by type
    scope :by_type, ->(type) { where(type: type) }

    # Convenience method to find attachments by name (partial match)
    scope :by_name, ->(name) { where(q: name) }

    # Helper method to get the deal for this attachment
    def deal
      return nil unless respond_to?(:deal_id) && deal_id

      FubClient::Deal.find(deal_id)
    end

    # Upload a new attachment for a deal
    def self.upload(deal_id, file_path, name = nil, type = nil, description = nil)
      # This would typically be implemented with a multipart form,
      # but we'll just define the interface here
      params = {
        dealId: deal_id,
        file: File.new(file_path, 'rb')
      }
      params[:name] = name if name
      params[:type] = type if type
      params[:description] = description if description

      post('', params)
    end

    # Download the attachment content
    def download
      return nil unless id

      begin
        self.class.get("#{id}/download")
      rescue StandardError
        nil
      end
    end

    # Delete the attachment
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
