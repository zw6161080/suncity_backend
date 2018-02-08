class FamilyMemberInformationsController < ApplicationController
  include MineCheckHelper
  before_action :set_user, only: [:show, :update]
  before_action :myself?, only:[:show], if: :entry_from_mine?
  # GET /family_member_informations/1
  def show
    authorize FamilyMemberInformation unless entry_from_mine?
    render json: @user.family_member_information, adapter: :attributes
  end

  # PATCH/PUT /profit_conflict_informations/1
  def update
    authorize FamilyMemberInformation
    fm = FamilyMemberInformation.find_or_create_by(user_id: @user.id)
    if fm.update(family_member_information_params)
      render json: fm, adapter: :attributes
    else
      render json: fm.errors, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    # Only allow a trusted parameter "white list" through.
    def family_member_information_params
      params.require(:family_member_information).permit(:family_fathers_name_chinese, :family_fathers_name_english, :family_mothers_name_chinese, :family_mothers_name_english, :family_partenrs_name_chinese, :family_partenrs_name_english, :family_kids_name_chinese, :family_kids_name_english, :family_bothers_name_chinese, :family_bothers_name_english, :family_sisters_name_chinese, :family_sisters_name_english)
    end
end
