class AppraisalBasicSettingsController < ApplicationController
  before_action :set_appraisal_basic_setting, only: [:show, :update]

  # GET /appraisal_basic_setting
  def show
    authorize AppraisalBasicSetting
    render json: @appraisal_basic_setting, root: 'data', include: '**'
  end

  # PATCH/PUT /appraisal_basic_setting
  def update
    authorize AppraisalBasicSetting
    raise LogicError, {id: 422, message: '參數不完整'}.to_json unless appraisal_basic_setting_params
    @appraisal_basic_setting.update(appraisal_basic_setting_params)
    render json: @appraisal_basic_setting, root: 'data'
  end

  private
    def set_appraisal_basic_setting
      @appraisal_basic_setting = AppraisalBasicSetting.all.first
    end

    def appraisal_basic_setting_params
      update_params = params.require(
        :appraisal_basic_setting
      ).permit(
        :ratio_superior,
        :ratio_subordinate,
        :ratio_collegue,
        :ratio_self,
        :ratio_others_superior,
        :ratio_others_subordinate,
        :ratio_others_collegue,
        :questionnaire_submit_once_only,
        :introduction,
        :group_A => [],
        :group_B => [],
        :group_C => [],
        :group_D => [],
        :group_E => [],
      )
      update_params
    end
end
