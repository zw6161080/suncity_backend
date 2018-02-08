class ProfitConflictInformationsController < ApplicationController
  include MineCheckHelper
  before_action :set_user, only: [:show, :update]
  before_action :myself?, only:[:show], if: :entry_from_mine?
  # GET /profit_conflict_informations/1
  def show
    authorize ProfitConflictInformation unless entry_from_mine?
    render json: @user.profit_conflict_information, adapter: :attributes
  end

  # PATCH/PUT /profit_conflict_informations/1
  def update
    authorize ProfitConflictInformation
    pc = ProfitConflictInformation.find_or_create_by(user_id: @user.id)
    if pc.update(profit_conflict_information_params)
      render json: pc, adapter: :attributes
    else
      render json: pc.errors, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    # Only allow a trusted parameter "white list" through.
    def profit_conflict_information_params
      params.require(:profit_conflict_information).permit(:have_or_no, :number)
    end
end
