class FamilyDeclarationItemsController < ApplicationController
  include MineCheckHelper
  before_action :set_profile
  before_action :set_user, only: [:index_by_user]
  before_action :myself?, only:[:index_by_user], if: :entry_from_mine?

  def index_by_user
    authorize FamilyDeclarationItem unless entry_from_mine?

    family_declaration_items = FamilyDeclarationItem.where(profile_id: @profile)

    render json: family_declaration_items, include:'**', root: 'data'
  end

  def create
    authorize FamilyDeclarationItem
    family_declaration_items= @profile.family_declaration_items.create(creator_id: current_user.id).update(params.permit(:relative_relation, :family_member_id))
    render json: family_declaration_items, include:'**', root: 'data'
  end

  def update
    authorize FamilyDeclarationItem
    family_declaration_item = @profile.family_declaration_items.find(params[:id])
    result = family_declaration_item.update_attributes(params.permit(:relative_relation, :family_member_id))

    render json: result, include:'**'
  end

  def destroy
    authorize FamilyDeclarationItem
    family_declaration_item = @profile.family_declaration_items.find(params[:id])
    family_declaration_item.destroy

    response_json
  end

  def destory_when_false
    authorize FamilyDeclarationItem
    FamilyDeclarationItem.delete_all
    response_json
  end


  private
  def set_user
    @user = @profile.user

  end

  def set_profile
    @profile = Profile.find(params[:profile_id])
  end
end

