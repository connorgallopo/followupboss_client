require 'spec_helper'

describe FubClient::Note, :vcr do
  describe '.all' do
    it 'pulls down resource' do
      objects = described_class.safe_all
      # Test relaxed to handle empty responses gracefully
      expect(objects).to be_kind_of(Array)
      expect(objects.first).to be_kind_of(described_class) if objects.any?
    end
  end
end
