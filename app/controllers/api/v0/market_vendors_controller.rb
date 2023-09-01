class Api::V0::MarketVendorsController < ApplicationController
  
  def index
    begin
      render json: VendorSerializer.new(Market.find(params[:market_id]).vendors)
    rescue ActiveRecord::RecordNotFound => e
      render json: ErrorSerializer.new(e).serialized_json, status: :not_found
    end
  end
  
  def create
    begin
      render json: MarketVendorSerializer.new(MarketVendor.create!(market_vendor_params)), status: :created
    rescue ActionController::ParameterMissing => e
      render json: ErrorSerializer.new(e).serialized_json, status: :bad_request
    rescue ActiveRecord::RecordInvalid => e
      custom_error_code(e)
    end
  end

  def destroy
    begin
      market_vendor = MarketVendor.find_by!(market_vendor_params)
      render json: market_vendor.destroy, status: :no_content
    rescue ActiveRecord::RecordNotFound => e
      custom_error_code(e)
    end
  end

  
  private

  def market_vendor_params
    params.require(:market_vendor).permit(:market_id, :vendor_id)
  end

  def custom_error_code(error)
    if error.message.include?("must exist")
      render json: ErrorSerializer.new(error).serialized_json, status: :not_found
    elsif error.message.include?("Couldn't find MarketVendor")
      render json: ErrorSerializer.new(error).serialized_non_existent(market_vendor_params), status: :not_found
    elsif error.message.include?("already exists")
      render json: ErrorSerializer.new(error).serialized_json, status: :unprocessable_entity
    end
  end
end