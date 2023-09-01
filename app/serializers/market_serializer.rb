class MarketSerializer

  include JSONAPI::Serializer
  attributes :name, :street, :city, :county, :state, :zip, :lat, :lon

  attribute :vendor_count do |object|
    object.vendors.count
  end
  
end