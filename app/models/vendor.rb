class Vendor < ApplicationRecord
  has_many :market_vendors, dependent: :destroy
  has_many :markets, through: :market_vendors

  validates_presence_of :name, :description, :contact_name, :contact_phone
  validate :boolean_values, on: :create

  private

  def boolean_values
    if credit_accepted.nil?
      errors.add(:credit_accepted, 'cannot be blank (must be true or false)')
    end
  end
  
end