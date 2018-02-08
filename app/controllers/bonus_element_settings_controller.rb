class BonusElementSettingsController < ApplicationController
  before_action :set_bonus_element_setting, only: [:show, :update, :destroy]

  # GET /bonus_element_settings
  def index
    authorize BonusElementSetting
    @bonus_element_settings = BonusElementSetting.all

    render json: @bonus_element_settings
  end

  # # GET /bonus_element_settings/1
  # def show
  #   render json: @bonus_element_setting
  # end

  # POST /bonus_element_settings
  # def create
  #   @bonus_element_setting = BonusElementSetting.new(bonus_element_setting_params)
  #
  #   if @bonus_element_setting.save
  #     render json: @bonus_element_setting, status: :created, location: @bonus_element_setting
  #   else
  #     render json: @bonus_element_setting.errors, status: :unprocessable_entity
  #   end
  # end

  # PATCH/PUT /bonus_element_settings/1
  def update
    authorize BonusElementSetting
    if @bonus_element_setting.update(bonus_element_setting_params)
      render json: @bonus_element_setting
    else
      render json: @bonus_element_setting.errors, status: :unprocessable_entity
    end
  end

  # PATCH /bonus_element_settings/reset
  def reset
    authorize BonusElementSetting
    BonusElement.reset_all_settings
    response_json
  end

  # PATCH/PUT /bonus_element_settings/batch_update
  def batch_update
    BonusElementSetting.batch_update(bonus_element_setting_batch_params[:updates])
    response_json
  end

  # DELETE /bonus_element_settings/1
  # def destroy
  #   @bonus_element_setting.destroy
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bonus_element_setting
      @bonus_element_setting = BonusElementSetting.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def bonus_element_setting_params
      params.permit(:department_id, :location_id, :bonus_element_id, :value)
    end

    def bonus_element_setting_batch_params
      params.permit(updates: [:department_id, :location_id, :bonus_element_id, :value])
    end

end
