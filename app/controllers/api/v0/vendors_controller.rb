class Api::V0::VendorsController < ApplicationController

  def index
    begin
      render json: VendorSerializer.new(Market.find(params[:market_id]).vendors)
    rescue ActiveRecord::RecordNotFound => e
      render json: ErrorSerializer.new(e).serialized_json, status: :not_found
    end
  end

  def show
    begin
      render json: VendorSerializer.new(Vendor.find(params[:id]))
    rescue ActiveRecord::RecordNotFound => e
      render json: ErrorSerializer.new(e).serialized_json, status: :not_found
    end
  end

  def create
    begin
      render json: VendorSerializer.new(Vendor.create!(vendor_params)), status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: ErrorSerializer.new(e).serialized_json, status: :bad_request
    end
  end

  def update
    begin
      Vendor.find(params[:id]).update!(vendor_params)
      render json: VendorSerializer.new(Vendor.find(params[:id]))
    rescue ActiveRecord::RecordNotFound => e
      render json: ErrorSerializer.new(e).serialized_json, status: :not_found
    rescue ActiveRecord::RecordInvalid => e
      render json: ErrorSerializer.new(e).serialized_json, status: :bad_request
    end
  end

  def destroy
    begin
      render json: Vendor.destroy(params[:id]), status: :no_content
    rescue ActiveRecord::RecordNotFound => e
      render json: ErrorSerializer.new(e).serialized_json, status: :not_found
    end
  end

  private

  def vendor_params
    params.require(:vendor).permit(:name, :description, :contact_name, :contact_phone, :credit_accepted)
  end
  
end