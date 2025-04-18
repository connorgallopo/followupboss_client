module FubClient
  class Stage < Resource
    collection_path "stages"
    root_element :stage
    include_root_in_json true
    
    # Convenience method to find stages by pipeline
    scope :by_pipeline, -> (pipeline_id) { where(pipelineId: pipeline_id) }
    
    # Convenience method to find stages by type
    scope :by_type, -> (type) { where(type: type) }
    
    # Convenience method to find active stages
    def self.active
      where(active: true)
    end
    
    # Convenience method to find inactive stages
    def self.inactive
      where(active: false)
    end
    
    # Get deals in this stage
    def deals
      return [] unless id
      
      FubClient::Deal.by_stage(id)
    end
    
    # Get the number of deals in this stage
    def deal_count
      return 0 unless id
      
      begin
        response = self.class.get("#{id}/dealCount")
        return response[:count] || 0
      rescue
        return 0
      end
    end
    
    # Move a stage to a different position
    def move_to_position(position)
      self.class.put("#{id}/move", { position: position })
    end
  end
end
