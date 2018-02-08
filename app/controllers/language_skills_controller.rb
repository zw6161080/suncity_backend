class LanguageSkillsController < ApplicationController
  include MineCheckHelper
  before_action :set_user, only: [:show, :update]
  before_action :myself?, only:[:show], if: :entry_from_mine?
  # GET /language_skills/1
  def show
    authorize LanguageSkill unless entry_from_mine?
    render json: @user.language_skill, adapter: :attributes
  end

  # PATCH/PUT /language_skills/1
  def update
    authorize LanguageSkill
    ls = LanguageSkill.find_by(user_id: @user.id)
    ls = LanguageSkill.create(user_id: @user.id) unless ls
    if ls.update(language_skill_params)
      render json: ls, adapter: :attributes
    else
      render json: ls.errors, status: :unprocessable_entity
    end
  end


  private
    def set_user
      @user = User.find(params[:user_id])
    end

    # Only allow a trusted parameter "white list" through.
    def language_skill_params
      params.require(:language_skill)
      params.permit(
          :language_chinese_writing,
          :language_contanese_speaking,
          :language_contanese_listening,
          :language_mandarin_speaking,
          :language_mandarin_listening,
          :language_english_speaking,
          :language_english_listening,
          :language_english_writing,
          :language_other_name,
          :language_other_speaking,
          :language_other_listening,
          :language_other_writing,
          :language_skill)
    end
end
