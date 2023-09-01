class MarketVendor < ApplicationRecord
  belongs_to :market
  belongs_to :vendor

  validate :cannot_already_exist, on: :create
  
private

  def cannot_already_exist
    if MarketVendor.exists?(market_id: market_id, vendor_id: vendor_id)
      errors.add(:base, "MarketVendor association between market with market_id=#{market.id} and vendor_id=#{vendor.id} already exists")
    end
  end
end