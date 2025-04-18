module FubClient
  class Resource
    include Her::Model
    use_api FubClient::Client.instance.her_api
    
    # Ensure parsing methods handle null responses gracefully
    collection_path "/"
    
    # Safe version of all that returns empty array on error
    def self.safe_all
      begin
        result = all
        # If we got nil back instead of a collection, return an empty array
        result.nil? ? [] : result
      rescue => e
        # Return empty array on any exception
        []
      end
    end
    
    scope :by_page, -> (page, per_page) { 
      where(offset: (page - 1)*per_page, limit: per_page) 
    }
    
    def self.total
      begin
        by_page(1, 1).metadata[:total]
      rescue => e
        0
      end
    end
    
    # Override default methods to handle nil data better
    def self.method_missing(method, *args, &blk)
      begin
        super
      rescue NoMethodError => e
        if e.message.include?('nil:NilClass') || e.message.include?('for nil:NilClass')
          # If the issue is nil data being accessed, return empty array for collection methods
          return []
        else
          raise e
        end
      end
    end
  end
end
