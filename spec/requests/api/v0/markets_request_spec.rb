require 'rails_helper'

RSpec.describe 'Markets API' do
  before(:each) do
    @all_markets = create_list(:market, 3)
    
    vendor_ids = create_list(:vendor, 10).pluck(:id)

    @all_markets.each do |market|
      ids = vendor_ids.sample(4)
      MarketVendor.create!(market_id: market.id, vendor_id: ids[0])
      MarketVendor.create!(market_id: market.id, vendor_id: ids[1])
      MarketVendor.create!(market_id: market.id, vendor_id: ids[2])
      MarketVendor.create!(market_id: market.id, vendor_id: ids[3])
    end

  end
  
  describe "GET /markets" do
    it 'sends a list of Markets' do
      get '/api/v0/markets'
      
      expect(response).to be_successful
      
      markets = JSON.parse(response.body, symbolize_names: true)
      
      expect(markets[:data].count).to eq(3)

      markets[:data].each do |market|
        expect(market).to have_key(:id)
        expect(market[:id]).to be_an(String)
      
        expect(market).to have_key(:type)
        expect(market[:type]).to eq("market")
  
        expect(market[:attributes]).to have_key(:name)
        expect(market[:attributes][:name]).to be_a(String)
        
        expect(market[:attributes]).to have_key(:street)
        expect(market[:attributes][:street]).to be_a(String)
        
        expect(market[:attributes]).to have_key(:city)
        expect(market[:attributes][:city]).to be_a(String)
        
        expect(market[:attributes]).to have_key(:county)
        expect(market[:attributes][:county]).to be_a(String)
        
        expect(market[:attributes]).to have_key(:state)
        expect(market[:attributes][:state]).to be_a(String)
        
        expect(market[:attributes]).to have_key(:zip)
        expect(market[:attributes][:zip]).to be_a(String)
        
        expect(market[:attributes]).to have_key(:lat)
        expect(market[:attributes][:lat]).to be_a(String)
        
        expect(market[:attributes]).to have_key(:lon)
        expect(market[:attributes][:lon]).to be_a(String)
      end
    end

    it 'also sends a markets count of vendors' do
      get '/api/v0/markets'

      expect(response).to be_successful

      markets = JSON.parse(response.body, symbolize_names: true)

      markets[:data].each do |market|
        expect(market[:attributes]).to have_key(:vendor_count)
        expect(market[:attributes][:vendor_count]).to be_an(Integer)
        expect(market[:attributes][:vendor_count]).to eq(4)
      end
    end
  end

  describe "GET /markets/:id" do
    it 'sends the markets info for valid ids' do
      market_id = @all_markets.first.id
  
      get "/api/v0/markets/#{market_id}"

      expect(response).to be_successful
      
      market = JSON.parse(response.body, symbolize_names: true)[:data]
      expect(market).to have_key(:id)
      expect(market[:id]).to be_an(String)
    
      expect(market).to have_key(:type)
      expect(market[:type]).to eq("market")

      expect(market[:attributes]).to have_key(:name)
      expect(market[:attributes][:name]).to be_a(String)
      
      expect(market[:attributes]).to have_key(:street)
      expect(market[:attributes][:street]).to be_a(String)
      
      expect(market[:attributes]).to have_key(:city)
      expect(market[:attributes][:city]).to be_a(String)
      
      expect(market[:attributes]).to have_key(:county)
      expect(market[:attributes][:county]).to be_a(String)
      
      expect(market[:attributes]).to have_key(:state)
      expect(market[:attributes][:state]).to be_a(String)
      
      expect(market[:attributes]).to have_key(:zip)
      expect(market[:attributes][:zip]).to be_a(String)
      
      expect(market[:attributes]).to have_key(:lat)
      expect(market[:attributes][:lat]).to be_a(String)
      
      expect(market[:attributes]).to have_key(:lon)
      expect(market[:attributes][:lon]).to be_a(String)

      expect(market[:attributes]).to have_key(:vendor_count)
      expect(market[:attributes][:vendor_count]).to be_an(Integer)
      expect(market[:attributes][:vendor_count]).to eq(4)
    end

    it 'sends error if market ID is invalid' do
      get "/api/v0/markets/123123123123123"
      
      expect(response.status).to eq(404)

      not_found = JSON.parse(response.body, symbolize_names: true)

      expect(not_found).to have_key(:errors)
      expect(not_found[:errors]).to be_an(Array)

      expect(not_found[:errors].first).to have_key(:details)
      expect(not_found[:errors].first[:details]).to be_a(String)
      expect(not_found[:errors].first[:details]).to eq("Couldn't find Market with 'id'=123123123123123")
    end
  end
end