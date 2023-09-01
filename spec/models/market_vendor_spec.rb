require 'rails_helper'

RSpec.describe MarketVendor, type: :model do
  describe 'Associations' do
    it { should belong_to :market }
    it { should belong_to :vendor }
  end
  
  describe 'custom validation' do
    it 'returns error when MarketVendor already exists' do
      market = create(:market)
      vendor = create(:vendor)
      MarketVendor.create!(market_id: market.id, vendor_id: vendor.id)
      
      market_vendor = MarketVendor.new(market_id: market.id, vendor_id: vendor.id)

      expect(market_vendor).to_not be_valid
      expect(market_vendor.errors[:base]).to include("MarketVendor association between market with market_id=#{market.id} and vendor_id=#{vendor.id} already exists")
    end
  end
end