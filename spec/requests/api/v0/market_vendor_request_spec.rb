require 'rails_helper'

RSpec.describe 'Market Vendors API' do
  describe 'GET /markets/:id/vendors' do

    before(:each) do
      @market1 = create(:market)
      @market2 = create(:market)
      
      vendor_ids = create_list(:vendor, 6).pluck(:id)
  
      @market1.market_vendors.create!(vendor_id: vendor_ids[0])
      @market1.market_vendors.create!(vendor_id: vendor_ids[1])
      @market1.market_vendors.create!(vendor_id: vendor_ids[2])
      @market1.market_vendors.create!(vendor_id: vendor_ids[3])
      @market1.market_vendors.create!(vendor_id: vendor_ids[4])
  
      @market2.market_vendors.create!(vendor_id: vendor_ids[5]) 
    end

    context 'using a valid market ID (happy path)' do
      it 'returns a list of Vendors' do
        get "/api/v0/markets/#{@market1.id}/vendors"

        expect(response).to be_successful

        vendors = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(vendors.count).to eq(5)
        
        vendors.each do |vendor|
          expect(vendor).to have_key(:id)
          expect(vendor[:id]).to be_an(String)
          expect(vendor[:type]).to eq('vendor')

          expect(vendor[:attributes]).to have_key(:name)
          expect(vendor[:attributes][:name]).to be_a(String)

          expect(vendor[:attributes]).to have_key(:description)
          expect(vendor[:attributes][:description]).to be_a(String)

          expect(vendor[:attributes]).to have_key(:contact_name)
          expect(vendor[:attributes][:contact_name]).to be_a(String)

          expect(vendor[:attributes]).to have_key(:contact_phone)
          expect(vendor[:attributes][:contact_phone]).to be_a(String)

          expect(vendor[:attributes]).to have_key(:credit_accepted)
          expect(vendor[:attributes][:credit_accepted]).to eq(true).or eq(false)
        end
      end
    end

    context 'using a invalid market ID (sad path)' do
      it 'returns a 404 error' do
        id = 123123123123123
        get "/api/v0/markets/#{id}/vendors"

        expect(response).to_not be_successful
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

  describe 'POST /api/v0/market_vendors' do

    before(:each) do
      @market = create(:market)
      @vendor = create(:vendor)
    end

    context 'when valid market and vendor ids are used' do
      it 'sends a 201 status code and creates MarketVendor object' do
        expect(MarketVendor.exists?(market_id: @market.id, vendor_id: @vendor.id)).to eq(false)

        params = { market_id: @market.id, vendor_id: @vendor.id }
        headers = { 'Content-Type' => 'application/json' }
        
        post '/api/v0/market_vendors', headers: headers, params: JSON.generate(market_vendor: params)

        expect(MarketVendor.exists?(market_id: @market.id, vendor_id: @vendor.id)).to eq(true)
        
        expect(response).to be_successful
        expect(response.status).to eq(201)

        market_vendor = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(market_vendor).to be_a(Hash)

        expect(market_vendor[:type]).to eq("market_vendor")

        expect(market_vendor[:attributes]).to have_key(:market_id)
        expect(market_vendor[:attributes][:market_id]).to be_an(Integer)

        expect(market_vendor[:attributes]).to have_key(:vendor_id)
        expect(market_vendor[:attributes][:vendor_id]).to be_an(Integer)
      end
    end

    context 'when invalid market or vendor ids are used' do
      it 'returns a 404 status code error for invalid market ID' do
        params = { market_id: 123123123123123, vendor_id: @vendor.id } #invalid market ID
        headers = { 'Content-Type' => 'application/json' }
        post '/api/v0/market_vendors', headers: headers, params: JSON.generate(market_vendor: params)
        
        expect(response).to_not be_successful
        expect(response.status).to eq(404)

        not_found = JSON.parse(response.body, symbolize_names: true)

        expect(not_found[:errors].first[:details]).to eq("Validation failed: Market must exist")
      end
      
      it 'returns a 404 status code error for invalid vendor ID' do
        params = { market_id: @market.id, vendor_id: 123123123123123 }
        headers = { 'Content-Type' => 'application/json' }
        post '/api/v0/market_vendors', headers: headers, params: JSON.generate(market_vendor: params)
        
        expect(response).to_not be_successful
        expect(response.status).to eq(404)

        not_found = JSON.parse(response.body, symbolize_names: true)

        expect(not_found[:errors].first[:details]).to eq("Validation failed: Vendor must exist")
      end
    end

    context 'when  market and/or vendor ids are not passed in (blank)' do
      it 'returns a 400 status code error for missing ids' do
        params = {  }
        headers = { 'Content-Type' => 'application/json' }
        post '/api/v0/market_vendors', headers: headers, params: JSON.generate(market_vendor: params)
        
        expect(response).to_not be_successful
        expect(response.status).to eq(400)

        not_found = JSON.parse(response.body, symbolize_names: true)

        expect(not_found[:errors].first[:details]).to eq("param is missing or the value is empty: market_vendor")
      end
    end

    context 'when a MarketVendor already exists for the market and vendor' do
      it 'returns a 422 status code error' do
        MarketVendor.create!(market_id: @market.id, vendor_id: @vendor.id)
        params = { market_id: @market.id, vendor_id: @vendor.id }
        headers = { 'Content-Type' => 'application/json' }
        post '/api/v0/market_vendors', headers: headers, params: JSON.generate(market_vendor: params)
        
        expect(response).to_not be_successful
        expect(response.status).to eq(422)

        not_found = JSON.parse(response.body, symbolize_names: true)

        expect(not_found[:errors].first[:details]).to eq("Validation failed: MarketVendor association between market with market_id=#{@market.id} and vendor_id=#{@vendor.id} already exists")
      end
    end
  end

  describe 'DELETE /api/v0/market_vendors' do

    before(:each) do
      @market = create(:market)
      @vendor = create(:vendor)
      @market_vendor = MarketVendor.create!(market_id: @market.id, vendor_id: @vendor.id)
    end

    context 'when valid market and vendor IDs are sent' do
      it 'returns a 204 status code and destroys the MarketVendor association object' do
        params = { market_id: @market.id, vendor_id: @vendor.id }
        headers = { 'Content-Type' => 'application/json' }

        expect(MarketVendor.exists?(params)).to eq(true)

        delete '/api/v0/market_vendors', headers: headers, params: JSON.generate(market_vendor: params)

        expect(MarketVendor.exists?(params)).to eq(false)

        expect(response).to be_successful
        expect(response.status).to eq(204)

        expect(response.body).to eq("")
      end

      it 'returns a 404 status code' do
        m_id = 321321321321
        v_id = 123123123123
        params = { market_id: m_id, vendor_id:  v_id}
        headers = { 'Content-Type' => 'application/json' }


        delete '/api/v0/market_vendors', headers: headers, params: JSON.generate(market_vendor: params)

        expect(response).to_not be_successful
        expect(response.status).to eq(404)

        not_found = JSON.parse(response.body, symbolize_names: true)

        expect(not_found[:errors].first[:details]).to eq("Couldn't find MarketVendor with market_vendors.market_id=#{m_id} AND market_vendors.vendor_id=#{v_id}")
      end
    end
  end
end