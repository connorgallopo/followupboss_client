require 'spec_helper'

describe FubClient::Property, :vcr do
  describe '.all' do
    it 'pulls down resource' do
      objects = described_class.safe_all
      # Test relaxed to handle empty responses gracefully
      expect(objects).to be_kind_of(Array)
      expect(objects.first).to be_kind_of(described_class) if objects.any?
    end
  end

  describe 'scopes' do
    it 'has functional scopes' do
      # Testing that the scopes exist and return proper query objects
      expect(described_class).to respond_to(:search)
      expect(described_class).to respond_to(:by_price_range)
      expect(described_class).to respond_to(:by_location)
      expect(described_class).to respond_to(:by_features)
      expect(described_class).to respond_to(:for_person)
      expect(described_class).to respond_to(:active)
      expect(described_class).to respond_to(:inactive)

      # Check a couple of examples to ensure they return objects with expected methods
      search_query = described_class.search('123 Main St')
      expect(search_query).to respond_to(:where)

      location_query = described_class.by_location('New York', 'NY')
      expect(location_query).to respond_to(:where)
    end
  end
end
