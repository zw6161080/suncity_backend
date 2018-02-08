class AppraisalDepartmentSettingsController < ApplicationController
  before_action :set_appraisal_department_setting, only: [:update, :update_group_situation]


  def location_with_departments
    render json: Location.with_departments
  end

  def fields_options
    options = {
      appraisal_questionnaire_templates: QuestionnaireTemplate.where(template_type: '360_assessment'),
      options: Config.get('appraisal_department_setting')['fields_options']
    }
    render json: options
  end

  # GET /appraisal_department_settings
  def index
    authorize AppraisalDepartmentSetting
    @appraisal_department_settings = AppraisalDepartmentSetting.all

    render json: @appraisal_department_settings
  end

  # PATCH/PUT /appraisal_department_settings/1
  def update
    authorize AppraisalDepartmentSetting
    if @appraisal_department_setting.update(appraisal_department_setting_params)
      @appraisal_department_setting.appraisal_employee_settings.each do |employee_setting|
        employee_setting.clear_level_in_department
      end
      render json: @appraisal_department_setting
    else
      render json: @appraisal_department_setting.errors, status: :unprocessable_entity
    end
  end

  def batch_update
    authorize AppraisalDepartmentSetting
    raise LogicError, {id: 422, message: '參數不完整'}.to_json unless params[:location_ids]
    if AppraisalDepartmentSetting.batch_update(params[:location_ids], appraisal_department_setting_params)
      AppraisalDepartmentSetting.where(location_id: params[:location_ids]).each do |department_setting|
        department_setting.appraisal_employee_settings.each do |employee_setting|
          employee_setting.clear_level_in_department
        end
      end
      render json: AppraisalDepartmentSetting.batch_update(params[:location_ids], appraisal_department_setting_params)
    else
      render json: @appraisal_department_settings.errors, status: :unprocessable_entity
    end
  end

  def update_group_situation
    @appraisal_department_setting.appraisal_employee_settings.each do |employee_setting|
      employee_setting.clear_appraisal_group
    end
    @appraisal_department_setting.update(params.permit(:whether_group_inside))
    @appraisal_department_setting.appraisal_groups.destroy_all
    if @appraisal_department_setting.whether_group_inside
      params['group_names'].each do |group_name|
        @appraisal_department_setting.appraisal_groups.create(name: group_name, appraisal_department_setting_id: @appraisal_department_setting.id)
      end
    end
    render json: @appraisal_department_setting
  end

  private
    def set_appraisal_department_setting
      @appraisal_department_setting = AppraisalDepartmentSetting.find(params[:id])
      end

    def set_appraisal_department_settings
      @appraisal_department_settings = AppraisalDepartmentSetting.where(location_id: params[:location_id])
    end

    def appraisal_department_setting_params
      params.permit(
              :can_across_appraisal_grade,
              :appraisal_mode_superior,
              :appraisal_times_superior,
              :appraisal_mode_collegue,
              :appraisal_times_collegue,
              :appraisal_mode_subordinate,
              :appraisal_times_subordinate,
              :appraisal_grade_quantity_inside,
              :group_A_appraisal_template_id,
              :group_B_appraisal_template_id,
              :group_C_appraisal_template_id,
              :group_D_appraisal_template_id,
              :group_E_appraisal_template_id
      )
    end
end