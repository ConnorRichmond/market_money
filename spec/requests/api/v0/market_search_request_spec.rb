require 'rails_helper'

RSpec.describe 'Markets Search API' do
  
  describe 'GET /api/v0/markets/search' do

    before(:each) do
      @market1 = create(:market, name: 'Market 1', city: "City 1", state: "State 1")
      @market2 = create(:market, name: 'Market 2', city: "City 1", state: "State 1")
      @market3 = create(:market, name: 'Market 3', city: "City 2", state: "State 2")
    end

    context 'when valid combinations of search attributes are provided' do
      it 'can search by name' do
        get "/api/v0/markets/search?name=Market 1"
        
        expect(response).to be_successful

        markets = JSON.parse(response.body, symbolize_names: true)

        expect(markets).to have_key(:data)
        expect(markets[:data]).to be_an(Array)
        expect(markets[:data].count).to eq(1)

        market = markets[:data].first[:attributes]

        expect(market[:name]).to eq(@market1.name)
        expect(market[:street]).to eq(@market1.street)
        expect(market[:city]).to eq(@market1.city)
        expect(market[:county]).to eq(@market1.county)
        expect(market[:state]).to eq(@market1.state)
        expect(market[:zip]).to eq(@market1.zip)
        expect(market[:lat]).to eq(@market1.lat)
        expect(market[:lon]).to eq(@market1.lon)
      end

      it 'can search by state' do
        get "/api/v0/markets/search?state=State 1"

        expect(response).to be_successful

        markets = JSON.parse(response.body, symbolize_names: true)

        expect(markets).to have_key(:data)
        expect(markets[:data]).to be_an(Array)
        expect(markets[:data].count).to eq(2)

        second_market = markets[:data][1][:attributes]

        expect(second_market[:name]).to eq(@market2.name)
        expect(second_market[:street]).to eq(@market2.street)
        expect(second_market[:city]).to eq(@market2.city)
        expect(second_market[:county]).to eq(@market2.county)
        expect(second_market[:state]).to eq(@market2.state)
        expect(second_market[:zip]).to eq(@market2.zip)
        expect(second_market[:lat]).to eq(@market2.lat)
        expect(second_market[:lon]).to eq(@market2.lon)
      end

      it 'can search by name and state' do 
        get "/api/v0/markets/search?state=State 2&name=Market 3"

        expect(response).to be_successful

        markets = JSON.parse(response.body, symbolize_names: true)

        expect(markets).to have_key(:data)
        expect(markets[:data]).to be_an(Array)
        expect(markets[:data].count).to eq(1)

        market = markets[:data].first[:attributes]
        
        expect(market[:name]).to eq(@market3.name)
        expect(market[:street]).to eq(@market3.street)
        expect(market[:city]).to eq(@market3.city)
        expect(market[:county]).to eq(@market3.county)
        expect(market[:state]).to eq(@market3.state)
        expect(market[:zip]).to eq(@market3.zip)
        expect(market[:lat]).to eq(@market3.lat)
        expect(market[:lon]).to eq(@market3.lon)
      end

      it 'can search by city and state' do
        get "/api/v0/markets/search?city=City 1&state=State 1"

        expect(response).to be_successful

        markets = JSON.parse(response.body, symbolize_names: true)

        expect(markets).to have_key(:data)
        expect(markets[:data]).to be_an(Array)
        expect(markets[:data].count).to eq(2)

        first_market = markets[:data].first[:attributes]

        expect(first_market[:name]).to eq(@market1.name)
        expect(first_market[:street]).to eq(@market1.street)
        expect(first_market[:city]).to eq(@market1.city)
        expect(first_market[:county]).to eq(@market1.county)
        expect(first_market[:state]).to eq(@market1.state)
        expect(first_market[:zip]).to eq(@market1.zip)
        expect(first_market[:lat]).to eq(@market1.lat)
        expect(first_market[:lon]).to eq(@market1.lon)
      end

      it 'can search by name, city, and state' do
        get "/api/v0/markets/search?city=City 1&state=State 1&name=Market 2"

        expect(response).to be_successful

        markets = JSON.parse(response.body, symbolize_names: true)

        expect(markets).to have_key(:data)
        expect(markets[:data]).to be_an(Array)
        expect(markets[:data].count).to eq(1)

        first_market = markets[:data].first[:attributes]

        expect(first_market[:name]).to eq(@market2.name)
        expect(first_market[:street]).to eq(@market2.street)
        expect(first_market[:city]).to eq(@market2.city)
        expect(first_market[:county]).to eq(@market2.county)
        expect(first_market[:state]).to eq(@market2.state)
        expect(first_market[:zip]).to eq(@market2.zip)
        expect(first_market[:lat]).to eq(@market2.lat)
        expect(first_market[:lon]).to eq(@market2.lon)
      end

      it 'returns blank array if search is valid, but no results' do
        get "/api/v0/markets/search?city=Eugene&state=Oregon"

        expect(response).to be_successful
        expect(response.status).to eq(200)

        empty_response = JSON.parse(response.body, symbolize_names: true)

        expect(empty_response).to have_key(:data)
        expect(empty_response[:data]).to be_an(Array)
        expect(empty_response[:data].blank?).to be(true)
      end
    end

    context 'when invalid search attributes are provided' do
      it 'returns error for city only search' do
        get "/api/v0/markets/search?city=City 1"

        expect(response.status).to eq(422)

        error_response = JSON.parse(response.body, symbolize_names: true)

        expect(error_response).to have_key(:errors)
        expect(error_response[:errors]).to be_an(Array)

        expect(error_response[:errors].first).to have_key(:details)

        error = error_response[:errors].first[:details]
        expect(error).to eq("Invalid set of parameters. Please provide a valid set of parameters to perform a search with this endpoint.")
      end

      it 'returns error for city and name only search' do
        get "/api/v0/markets/search?city=City 1&name=Market 2"

        expect(response).to_not be_successful
        expect(response.status).to eq(422)

        error_response = JSON.parse(response.body, symbolize_names: true)
        error = error_response[:errors].first[:details]

        expect(error).to eq("Invalid set of parameters. Please provide a valid set of parameters to perform a search with this endpoint.")
      end

      it 'returns 422 error when invalid parameters are used' do
        get "/api/v0/markets/search?county=City 1"
        
        expect(response).to_not be_successful
        expect(response.status).to eq(422)

        error_response = JSON.parse(response.body, symbolize_names: true)
        error = error_response[:errors].first[:details]

        expect(error).to eq("Invalid set of parameters. Please provide a valid set of parameters to perform a search with this endpoint.")
      end
    end
  end
end