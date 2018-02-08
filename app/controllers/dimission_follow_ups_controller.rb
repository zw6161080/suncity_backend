class DimissionFollowUpsController < ApplicationController
  before_action :set_dimission_follow_up, only: [:show, :update]

  # GET /dimission_follow_ups
  def index
    query = DimissionFollowUp.all
              .page.page(params[:page].presence || 1).per(10)
    response_json query, { pagination: true }
  end

  # GET /dimission_follow_ups/1
  def show
    response_json @dimission_follow_up
  end

  # PATCH/PUT /dimission_follow_ups/1
  def update
    update_params = dimission_follow_up_params.permit(*DimissionFollowUp.update_params)
    update_params['handler_id'] = current_user.id
    if @dimission_follow_up.update(update_params)
      response_json @dimission_follow_up
    else
      render json: @dimission_follow_up.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dimission_follow_up
      @dimission_follow_up = DimissionFollowUp.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def dimission_follow_up_params
      params.fetch(:dimission_follow_up, {})
    end
end
