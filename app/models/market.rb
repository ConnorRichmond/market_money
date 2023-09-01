class Market < ApplicationRecord
  has_many :market_vendors, dependent: :destroy
  has_many :vendors, through: :market_vendors

  validates_presence_of :name, :street, :city, :county, :state, :zip, :lat, :lon

  private
  
  def self.search(params)
    if validate_params(params)
      find_markets(params)
    else
      raise SearchError, "Invalid set of parameters. Please provide a valid set of parameters to perform a search with this endpoint."
    end
  end

  def self.find_markets(params)
    markets = Market.all
    markets = filter_name(markets, params[:name]) if params.has_key?(:name)
    markets = filter_city(markets, params[:city]) if params.has_key?(:city)
    markets = filter_state(markets, params[:state]) if params.has_key?(:state)
    markets
  end
  
  def self.validate_params(params)
    current_search = params.slice(:name, :city, :state).keys.map(&:to_sym)
    valid_search = [[:state], [:city, :state], [:city, :name, :state], [:name, :state], [:name]]
    valid_search.include?(current_search.sort)
  end

  def self.filter_name(markets, name)
    markets.where("name ILIKE ?", "%#{name}%")
  end
  
  def self.filter_city(markets, city)
    markets.where("city ILIKE ?", "%#{city}%")
  end
  
  def self.filter_state(markets, state)
    markets.where("state ILIKE ?", "%#{state}%")
  end
end