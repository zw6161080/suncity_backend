class MedicalTemplateSettingsController < ApplicationController

  before_action :set_medical_template_setting, only: [:show, :update]

  # GET /medical_template_settings
  def show
    authorize MedicalTemplateSetting
    data = @medical_template_setting.sections.map do |record|
      query = record
      query['current_template']   = nil
      query['impending_template'] = nil
      query['current_template']   = MedicalTemplate.find(record['current_template_id']) unless record['current_template_id'].nil?
      query['impending_template'] = MedicalTemplate.find(record['impending_template_id']) unless record['impending_template_id'].nil?
      query
    end
    response_json data
  end

  # PATCH/PUT /medical_template_settings
  def update
    authorize MedicalTemplateSetting
    if @medical_template_setting.update_with_params(medical_template_setting_params)
      response_json @medical_template_setting
    else
      response_json @medical_template_setting.errors, status: :unprocessable_entity
    end
  end

  private
    def set_medical_template_setting
      @medical_template_setting = MedicalTemplateSetting.first
    end

    def medical_template_setting_params
      params.require(:medical_template_setting)
          .permit( {
                       sections: [
                           :employee_grade,
                           :current_template_id,
                           :impending_template_id,
                           :effective_date
                       ]
                   } )
    end

end
