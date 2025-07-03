module FubClient
  class Resource
    include Her::Model
    use_api FubClient::Client.instance.her_api

    collection_path '/'

    def self.safe_all
      result = all
      result.nil? ? [] : result
    rescue StandardError
      []
    end

    scope :by_page, lambda { |page, per_page|
      where(offset: (page - 1) * per_page, limit: per_page)
    }

    def self.total
      by_page(1, 1).metadata[:total]
    rescue StandardError
      0
    end

    def self.method_missing(method, *args, &blk)
      super
    rescue NoMethodError => e
      return [] if e.message.include?('nil:NilClass') || e.message.include?('for nil:NilClass')

      raise e
    end
  end
end
