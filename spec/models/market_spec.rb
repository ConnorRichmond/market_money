require 'rails_helper'

RSpec.describe Market, type: :model do
  
  describe 'Associations' do
    it { should have_many :market_vendors }
    it { should have_many :vendors }
  end

  describe 'Validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :street }
    it { should validate_presence_of :county }
    it { should validate_presence_of :state }
    it { should validate_presence_of :zip }
    it { should validate_presence_of :lat }
    it { should validate_presence_of :lon }
  end


  describe 'Model Methods' do
    before(:each) do
      @market1 = create(:market, name: 'Market 1', city: 'City 1', state: 'State 1')
      @market2 = create(:market, name: 'Market 2', city: 'City 1', state: 'State 1')
      @market3 = create(:market, name: 'Market 3', city: 'City 1', state: 'State 1')
      @market4 = create(:market, name: 'Market 4', city: 'City 2', state: 'State 2')
      @market5 = create(:market, name: 'Market 5', city: 'City 2', state: 'State 2')
      @market6 = create(:market, name: 'Market 6', city: 'City 2', state: 'State 2')
    end

    it '#self.filter_name' do
      markets = Market.all
      search = Market.filter_name(markets, "Market 1")

      expect(search.count).to eq(1)

      expect(search.first[:id]).to eq(@market1.id)
      expect(search.first[:name]).to eq(@market1.name)
      expect(search.first[:street]).to eq(@market1.street)
      expect(search.first[:city]).to eq(@market1.city)
      expect(search.first[:county]).to eq(@market1.county)
      expect(search.first[:state]).to eq(@market1.state)
      expect(search.first[:zip]).to eq(@market1.zip)
      expect(search.first[:lat]).to eq(@market1.lat)
      expect(search.first[:lon]).to eq(@market1.lon)
    end

    it '#self.filter_city' do
      markets = Market.all
      search = Market.filter_city(markets, 'City 1')

      expect(search.count).to eq(3)

      expect(search.first[:id]).to eq(@market1.id)
      expect(search.first[:name]).to eq(@market1.name)
      expect(search.first[:city]).to eq(@market1.city)

      expect(search[1][:id]).to eq(@market2.id)
      expect(search[1][:name]).to eq(@market2.name)
      expect(search[1][:city]).to eq(@market2.city)
    end

    it '#self.filter_state' do
      markets = Market.all
      search = Market.filter_state(markets, 'State 1')

      expect(search.count).to eq(3)

      expect(search.first[:id]).to eq(@market1.id)
      expect(search.first[:name]).to eq(@market1.name)
      expect(search.first[:state]).to eq(@market1.state)
    end

    it '#self.find_markets' do
      params = { city: 'City 2', state: 'State 2' }
      search = Market.find_markets(params)

      expect(search.count).to eq(3)

      expect(search.first[:id]).to eq(@market4.id)
      expect(search.first[:name]).to eq(@market4.name)
      expect(search.first[:state]).to eq(@market4.state)

      expect(search[1][:id]).to eq(@market5.id)
      expect(search[1][:name]).to eq(@market5.name)
      expect(search[1][:state]).to eq(@market5.state)
      
      expect(search[2][:id]).to eq(@market6.id)
      expect(search[2][:name]).to eq(@market6.name)
      expect(search[2][:state]).to eq(@market6.state)
    end

    it '#self.validate_params returns true when valid' do
      params1 = { state: 'State 2' }
      params2 = { city: 'City 2', state: 'State 2' }
      params3 = { name: 'Market 5', city: 'City 2', state: 'State 2' }
      params4 = { name: 'Market 5', state: 'State 2' }
      params5 = { name: 'Market 5' }


      expect(Market.validate_params(params1)).to eq(true)
      expect(Market.validate_params(params2)).to eq(true)
      expect(Market.validate_params(params3)).to eq(true)
      expect(Market.validate_params(params4)).to eq(true)
      expect(Market.validate_params(params5)).to eq(true)
    end

    it '#self.validate_params returns false when invalid' do
      params1 = { city: 'City 2' }
      params2 = { city: 'City 2', name: 'Market 5' }
      params3 = { county: 'City 2' }

      expect(Market.validate_params(params1)).to eq(false)
      expect(Market.validate_params(params2)).to eq(false)
      expect(Market.validate_params(params3)).to eq(false)
    end

    it '#self.search returns markets when valid params searched' do
      params = { city: 'City 2', state: 'State 2' }
      search = Market.search(params)

      expect(search.count).to eq(3)
    end
    
    it '#self.search returns error when invalid params searched' do
      params = { county: 'City 2' }

      expect{ Market.search(params) }.to raise_error(SearchError)
    end
  end
end