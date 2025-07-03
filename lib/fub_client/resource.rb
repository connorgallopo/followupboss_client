module FubClient
  class Resource
    include Her::Model
    use_api FubClient::Client.instance.her_api
    
    collection_path "/"
    
    def self.safe_all
      begin
        result = all
        result.nil? ? [] : result
      rescue => e
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
    
    def self.method_missing(method, *args, &blk)
      begin
        super
      rescue NoMethodError => e
        if e.message.include?('nil:NilClass') || e.message.include?('for nil:NilClass')
          return []
        else
          raise e
        end
      end
    end
  end
end
