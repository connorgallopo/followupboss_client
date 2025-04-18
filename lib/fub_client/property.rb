module FubClient
  class Property < Resource
    collection_path "properties"
    root_element :property
    include_root_in_json true
    
    # Convenience method to find properties by address or MLS number
    scope :search, -> (query) { where(q: query) }
    
    # Convenience method to find properties by price range
    scope :by_price_range, -> (min, max) { where(minPrice: min, maxPrice: max) }
    
    # Convenience method to find properties by location
    scope :by_location, -> (city, state = nil, zip = nil) { 
      params = { city: city }
      params[:state] = state if state
      params[:zip] = zip if zip
      where(params)
    }
    
    # Convenience method to find properties by features
    scope :by_features, -> (beds = nil, baths = nil, sq_ft = nil) { 
      params = {}
      params[:beds] = beds if beds
      params[:baths] = baths if baths
      params[:minSqFt] = sq_ft if sq_ft
      where(params)
    }
    
    # Find properties associated with a person
    scope :for_person, -> (person_id) { where(personId: person_id) }
    
    # Find active vs inactive listings
    scope :active, -> { where(active: true) }
    scope :inactive, -> { where(active: false) }
  end
end
