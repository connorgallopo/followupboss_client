module FubClient
  class Property < Resource
    collection_path 'properties'
    root_element :property
    include_root_in_json true

    scope :search, ->(query) { where(q: query) }
    scope :by_price_range, ->(min, max) { where(minPrice: min, maxPrice: max) }
    scope :by_location, lambda { |city, state = nil, zip = nil|
      params = { city: city }
      params[:state] = state if state
      params[:zip] = zip if zip
      where(params)
    }
    scope :by_features, lambda { |beds = nil, baths = nil, sq_ft = nil|
      params = {}
      params[:beds] = beds if beds
      params[:baths] = baths if baths
      params[:minSqFt] = sq_ft if sq_ft
      where(params)
    }
    scope :for_person, ->(person_id) { where(personId: person_id) }
    scope :active, -> { where(active: true) }
    scope :inactive, -> { where(active: false) }
  end
end
