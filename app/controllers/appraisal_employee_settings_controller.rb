class AppraisalEmployeeSettingsController < ApplicationController
  include StatementBaseActions
  before_action :set_appraisal_employee_setting, only: [:update]

  # GET /appraisal_employee_settings
  def index
    authorize AppraisalEmployeeSetting
    params[:page] ||= 1
    meta = {}

    query_result = search_query
    query_result = query_result.page(params[:page].to_i).per(20)
    meta['total_count'] = query_result.total_count
    meta['total_page'] = query_result.total_pages
    meta['current_page'] = query_result.current_page
    render json: query_result, root: 'data', meta: meta, include: '**'
  end

  def side_bar_options
    query = AppraisalEmployeeSetting.all.joins(:user)
    data = [
      {
        key: 'all',
        chinese_name: '全部',
        english_name: 'All',
        simple_chinese_name: '全部',
        count: query.count
      }
    ]
    Location.where.not(id: 32).each do |location|
      departments = location.departments.where.not(id: 1).map do |department|
        department.as_json.merge(member_count: query.where(:users => {location_id: location.id, department_id: department.id}).count)
      end
      data.push(location.as_json.merge(departments: departments, member_count: query.where(:users => {location_id: location.id}).count))
    end
    render json: { side_bar_options: data }
  end

  def field_options
    render json: AppraisalEmployeeSetting.field_options
  end

  # PATCH/PUT /appraisal_employee_settings/1
  def update
    authorize AppraisalEmployeeSetting
    raise LogicError, {id: 422, message: '參數不完整'}.to_json unless params[:appraisal_group_id] && params[:level_in_department]
    if @appraisal_employee_setting.update(update_params)
      @appraisal_employee_setting.update_status
      @appraisal_employee_setting.reset_candidate_relationship
      render json: @appraisal_employee_setting
    else
      render json: @appraisal_employee_setting.errors, status: :unprocessable_entity
    end
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_appraisal_employee_setting
    @appraisal_employee_setting = AppraisalEmployeeSetting.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def appraisal_employee_setting_params
    params.permit(:appraisal_group_id, :level_in_department)
  end

  def update_params
    params.permit(:appraisal_group_id, :level_in_department)
  end

  def search_query
    query = AppraisalEmployeeSetting.all.left_outer_joins(:user => :profile)
      .by_has_finished(params[:has_finished])
      .by_level_in_department(params[:level_in_department])
      .by_location(params[:location])
      .by_department(params[:department])
      .by_position(params[:position])
      .by_grade(params[:grade])
      .by_division_of_job(params[:division_of_job])
      .by_working_status(params[:working_status])
      .by_id(params[:id])
      .by_empoid(params[:empoid])
      .by_user(params[:user])
      .by_name(params[:name])
      .order_by((params[:sort_column] || :created_at), (params[:sort_direction] || :desc) )
      query = AppraisalEmployeeSetting.by_users_employee_name(query, params[:chinese_name])
      query
  end

end
