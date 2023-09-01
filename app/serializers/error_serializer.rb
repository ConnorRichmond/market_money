class ErrorSerializer
  def initialize(error_object)
    @error_object = error_object
  end

  def serialized_json
    {
      "errors": [
          { 
            "details": @error_object.message,
          }
      ]
    }
  end

  def serialized_non_existent(data)
    {
      "errors": [
          { 
            "details": "Couldn't find MarketVendor with market_vendors.market_id=#{data[:market_id]} AND market_vendors.vendor_id=#{data[:vendor_id]}",
          }
      ]
    }
  end
  
end