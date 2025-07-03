module FubClient
  class Stage < Resource
    collection_path "stages"
    root_element :stage
    include_root_in_json true
    
    scope :by_pipeline, -> (pipeline_id) { where(pipelineId: pipeline_id) }
    scope :by_type, -> (type) { where(type: type) }
    
    def self.active
      where(active: true)
    end
    
    def self.inactive
      where(active: false)
    end
    
    def deals
      return [] unless id
      
      FubClient::Deal.by_stage(id)
    end
    
    def deal_count
      return 0 unless id
      
      begin
        response = self.class.get("#{id}/dealCount")
        return response[:count] || 0
      rescue
        return 0
      end
    end
    
    def move_to_position(position)
      self.class.put("#{id}/move", { position: position })
    end
  end
end
