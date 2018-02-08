class OccupationTaxSettingsController < ApplicationController
  before_action :set_occupation_tax_setting, only: [:show, :update, :destroy]

  # GET /occupation_tax_settings/1
  def show
    authorize OccupationTaxSetting
    render json: @occupation_tax_setting
  end

  # POST /occupation_tax_settings
  # def create
  #   @occupation_tax_setting = OccupationTaxSetting.first_or_create(occupation_tax_setting_params)
  #
  #   if @occupation_tax_setting.update(occupation_tax_setting_params)
  #     render json: @occupation_tax_setting, status: :created, location: occupation_tax_settings_url
  #   else
  #     render json: @occupation_tax_setting.errors, status: :unprocessable_entity
  #   end
  # end

  # PATCH/PUT /occupation_tax_settings/1
  def update
    authorize OccupationTaxSetting
    if @occupation_tax_setting.update(occupation_tax_setting_params)
      render json: @occupation_tax_setting
    else
      render json: @occupation_tax_setting.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /occupation_tax_settings/reset
  def reset
    authorize OccupationTaxSetting
    OccupationTaxSetting.reset_predefined
    render json: { success: true }, status: :ok
  end

  # DELETE /occupation_tax_settings/1
  # def destroy
  #   @occupation_tax_setting.destroy
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_occupation_tax_setting
      @occupation_tax_setting = OccupationTaxSetting.first
    end

    # Only allow a trusted parameter "white list" through.
    def occupation_tax_setting_params
      params
        .require(:occupation_tax_setting)
        .permit(
          :deduct_percent,
          :favorable_percent,
          { ranges: [:limit, :tax_rate] }
        )
    end
end
