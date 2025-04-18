module FubClient
  class Pipeline < Resource
    collection_path "pipelines"
    root_element :pipeline
    include_root_in_json true
    
    # Convenience method to find active pipelines
    def self.active
      where(active: true)
    end
    
    # Convenience method to find inactive pipelines
    def self.inactive
      where(active: false)
    end
    
    # Get the stages in this pipeline
    def stages
      return [] unless id
      
      FubClient::Stage.by_pipeline(id)
    end
    
    # Get the deals in this pipeline
    def deals
      return [] unless id
      
      FubClient::Deal.where(pipelineId: id)
    end
    
    # Get summary statistics for this pipeline
    def stats
      return {} unless id
      
      begin
        self.class.get("#{id}/stats")
      rescue
        {}
      end
    end
    
    # Move the pipeline to a different position
    def move_to_position(position)
      self.class.put("#{id}/move", { position: position })
    end
    
    # Update multiple stages in this pipeline at once
    def update_stages(stages_data)
      self.class.put("#{id}/stages", { stages: stages_data })
    end
  end
end
