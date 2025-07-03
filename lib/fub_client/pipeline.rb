module FubClient
  class Pipeline < Resource
    collection_path "pipelines"
    root_element :pipeline
    include_root_in_json true
    
    def self.active
      where(active: true)
    end
    
    def self.inactive
      where(active: false)
    end
    
    def stages
      return [] unless id
      
      FubClient::Stage.by_pipeline(id)
    end
    
    def deals
      return [] unless id
      
      FubClient::Deal.where(pipelineId: id)
    end
    
    def stats
      return {} unless id
      
      begin
        self.class.get("#{id}/stats")
      rescue
        {}
      end
    end
    
    def move_to_position(position)
      self.class.put("#{id}/move", { position: position })
    end
    
    def update_stages(stages_data)
      self.class.put("#{id}/stages", { stages: stages_data })
    end
  end
end
