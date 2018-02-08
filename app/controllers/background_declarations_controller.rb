class BackgroundDeclarationsController < ApplicationController
  include MineCheckHelper
  before_action :set_user, only: [:show, :update]
  # GET /background_declarations/1
  def show
    render json: @user.background_declaration, adapter: :attributes
  end

  # PATCH/PUT /background_declarations/1
  def update
    bd = BackgroundDeclaration.find_by(user_id: @user.id)
    bd = BackgroundDeclaration.create(user_id: @user.id,
                                 have_any_relatives: false,
                                 relative_criminal_record: false,
                                 relative_business_relationship_with_suncity: false
    ) unless bd
    if bd.update(background_declaration_params)
      render json: bd, adapter: :attributes
    else
      render json: bd.errors, status: :unprocessable_entity
    end
  end

  private
    def set_user
      @user = User.find(params[:user_id])
    end

    # Only allow a trusted parameter "white list" through.
    def background_declaration_params
      params.permit(
          :have_any_relatives,
          :relative_criminal_record,
          :relative_criminal_record_detail,
          :relative_business_relationship_with_suncity,
          :relative_business_relationship_with_suncity_detail)
    end
end
