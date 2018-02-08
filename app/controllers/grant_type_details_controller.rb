class GrantTypeDetailsController < ApplicationController
  before_action :set_grant_type_detail, only: [:show, :update, :destroy]

  # GET /grant_type_details
  def index
    @grant_type_details = GrantTypeDetail.all

    render json: @grant_type_details
  end

  # GET /grant_type_details/1
  def show
    render json: @grant_type_detail
  end

  # POST /grant_type_details
  def create
    @grant_type_detail = GrantTypeDetail.new(grant_type_detail_params)

    if @grant_type_detail.save
      render json: @grant_type_detail, status: :created, location: @grant_type_detail
    else
      render json: @grant_type_detail.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /grant_type_details/1
  def update
    if @grant_type_detail.update(grant_type_detail_params)
      render json: @grant_type_detail
    else
      render json: @grant_type_detail.errors, status: :unprocessable_entity
    end
  end

  # DELETE /grant_type_details/1
  def destroy
    @grant_type_detail.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_grant_type_detail
      @grant_type_detail = GrantTypeDetail.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def grant_type_detail_params
      params.fetch(:grant_type_detail, {})
    end
end
