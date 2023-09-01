require 'rails_helper'

RSpec.describe Vendor, type: :model do
  describe 'Associations' do
    it { should have_many :market_vendors}
    it { should have_many :markets}
  end

  describe 'Validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :description }
    it { should validate_presence_of :contact_name }
    it { should validate_presence_of :contact_phone }
    
    context 'for boolean values' do
      it 'validates credit_accepted presence' do
        vendor = build(:vendor, credit_accepted: nil)

        expect(vendor).to_not be_valid
        expect(vendor.errors[:credit_accepted]).to include('cannot be blank (must be true or false)')
      end
  
      it 'passes validation when credit_accepted is true' do
        vendor = build(:vendor, credit_accepted: true)

        expect(vendor).to be_valid
      end
  
      it 'passes validation when credit_accepted is false' do
        vendor = build(:vendor, credit_accepted: false)

        expect(vendor).to be_valid
      end
    end
  end
end