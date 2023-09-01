require 'rails_helper'

RSpec.describe 'Vendors API' do
  
  before(:each) do
    @market1 = create(:market)
    @market2 = create(:market)
    
    vendors = create_list(:vendor, 5)
    vendor_ids = vendors.pluck(:id)

    @vendor1 = vendors[0]
    
    @market1.market_vendors.create!(vendor_id: vendor_ids[1])
    @market1.market_vendors.create!(vendor_id: vendor_ids[2])
    @market1.market_vendors.create!(vendor_id: vendor_ids[3])
    @market1.market_vendors.create!(vendor_id: vendor_ids[4])
  end
  
  describe 'GET /vendors/:id' do
    context 'using a valid vendor ID (happy path)' do
      it 'returns the vendors details' do
        id = @vendor1.id

        get "/api/v0/vendors/#{id}"
        
        expect(response).to be_successful

        vendor = JSON.parse(response.body, symbolize_names: true)[:data]

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

    context 'using a invalid vendor ID (sad path)' do
      it 'returns a 404 error (not found)' do
        id = 123123123123123

        get "/api/v0/vendors/#{id}"
        
        expect(response).to_not be_successful
        expect(response.status).to eq(404)

        not_found = JSON.parse(response.body, symbolize_names: true)

        expect(not_found).to have_key(:errors)
        expect(not_found[:errors]).to be_an(Array)

        expect(not_found[:errors].first).to have_key(:details)
        expect(not_found[:errors].first[:details]).to be_a(String)
        expect(not_found[:errors].first[:details]).to eq("Couldn't find Vendor with 'id'=123123123123123")
      end
    end
  end

  describe 'POST /vendors' do
    context 'using valid inputs for Vendor attributes' do
      it 'should successfully create a Vendor (created)' do
        vendor_params = ({
          name: "Buzzy Bees",
          description: "Local honey and wax products",
          contact_name: "Scarlett Johansson",
          contact_phone: "8389928383",
          credit_accepted: true
        })
        headers = {"CONTENT_TYPE" => "application/json"}

        post '/api/v0/vendors', headers: headers, params: JSON.generate(vendor: vendor_params)
        
        expect(response).to be_successful
        expect(response.status).to eq(201)

        created_vendor = JSON.parse(response.body, symbolize_names: true)[:data]

        expect(created_vendor[:attributes][:name]).to eq("Buzzy Bees")
        expect(created_vendor[:attributes][:description]).to eq("Local honey and wax products")
        expect(created_vendor[:attributes][:contact_name]).to eq("Scarlett Johansson")
        expect(created_vendor[:attributes][:contact_phone]).to eq("8389928383")
        expect(created_vendor[:attributes][:credit_accepted]).to eq(true)
      end
    end

    context 'using invalid inputs for Vendor attributes' do
      it 'should send a 400 error (bad request)' do
        vendor_params = ({
                          name: "",
                          description: "Local honey and wax products",
                          contact_name: "Scarlett Johansson",
                          credit_accepted: false
                        })
        headers = {"CONTENT_TYPE" => "application/json"}

        post '/api/v0/vendors', headers: headers, params: JSON.generate(vendor: vendor_params)
        
        expect(response.status).to eq(400)
 
        not_found = JSON.parse(response.body, symbolize_names: true)

        expect(not_found).to have_key(:errors)
        expect(not_found[:errors]).to be_an(Array)

        expect(not_found[:errors].first).to have_key(:details)
        expect(not_found[:errors].first[:details]).to be_a(String)
        expect(not_found[:errors].first[:details]).to eq("Validation failed: Name can't be blank, Contact phone can't be blank")
      end
    end

    describe 'PATCH /vendors/:id' do
      context 'using valid inputs to update Vendor attributes' do
        it 'should successfully update the Vendor' do
          expect(@vendor1.name).to_not eq("Buzzy Bees")
          expect(@vendor1.description).to_not eq("Local honey and wax products")
          
          id = @vendor1.id
          vendor_params = ( {name: "Buzzy Bees", description: "Local honey and wax products" })
          headers = {"CONTENT_TYPE" => "application/json"}
  
          patch "/api/v0/vendors/#{id}", headers: headers, params: JSON.generate(vendor: vendor_params)
  
          expect(response).to be_successful
          expect(response.status).to eq(200)

          updated_vendor = JSON.parse(response.body, symbolize_names: true)[:data]

          expect(updated_vendor[:attributes][:name]).to eq("Buzzy Bees")
          expect(updated_vendor[:attributes][:description]).to eq("Local honey and wax products")
        end
      end

      context 'using invalid vendor ID' do
        it 'should send a 404 error (not found)' do
          id = 123123123123123
          vendor_params = ({ name: "Buzzy Bees", description: "Local honey and wax products" })
          headers = {"CONTENT_TYPE" => "application/json"}

          patch "/api/v0/vendors/#{id}", headers: headers, params: JSON.generate(vendor: vendor_params)

          expect(response.status).to eq(404)
          
          not_found = JSON.parse(response.body, symbolize_names: true)[:errors].first

          expect(not_found[:details]).to eq("Couldn't find Vendor with 'id'=123123123123123")
        end
      end

      context 'using invalid inputs to update Vendor attributes' do
        it 'should send a 400 error (bad request)' do
          id = @vendor1.id
          vendor_params = ({ description: "" }) #cannot be blank
          headers = {"CONTENT_TYPE" => "application/json"}
  
          patch "/api/v0/vendors/#{id}", headers: headers, params: JSON.generate(vendor: vendor_params)
  
          expect(response).to_not be_successful
          expect(response.status).to eq(400)
 
          not_found = JSON.parse(response.body, symbolize_names: true)[:errors].first

          expect(not_found[:details]).to eq("Validation failed: Description can't be blank")
        end
      end
    end
    describe 'DELETE /vendors/:id' do
      context 'using valid Vendor ID' do
        it 'sends code 204 (:no_content)' do
          id = @vendor1.id
          
          delete "/api/v0/vendors/#{id}"

          expect(response).to be_successful
          expect(response.status).to eq(204)

          expect(response.body).to eq("")
        end
      end

      context 'using invalid Vendor ID' do
        it 'sends code 404 (not found)' do
          id = 123123123123123
          
          delete "/api/v0/vendors/#{id}"

          expect(response.status).to eq(404)

          not_found = JSON.parse(response.body, symbolize_names: true)[:errors].first

          expect(not_found[:details]).to eq("Couldn't find Vendor with 'id'=123123123123123")
        end
      end
    end
  end
end