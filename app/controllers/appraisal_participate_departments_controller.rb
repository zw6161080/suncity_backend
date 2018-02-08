class AppraisalParticipateDepartmentsController < ApplicationController

  before_action :set_appraisal_participate_department, only: [:update, :show]

  # GET /appraisal_participate_departments
  def index
    departments = AppraisalParticipateDepartment
                      .includes(:department)
                      .where(appraisal_id: params[:appraisal_id])
    department_data = departments.as_json(include: :department)

    location_ids  = departments.select(:location_id).distinct.pluck(:location_id)
    location_data = location_ids.map do |location_id|
      record         = Location.find(location_id).as_json
      record[:count] = departments.where(location_id: record['id']).pluck(:participator_amount).sum
      record
    end

    total_count = departments.pluck(:participator_amount).sum

    render json: { department: department_data,
                   location:   location_data,
                   total:      { chinese_name:        I18n.t('appraisal.total', locale: :'zh-HK'),
                                 english_name:        I18n.t('appraisal.total', locale: :en),
                                 simple_chinese_name: I18n.t('appraisal.total', locale: :'zh-CN'),
                                 count: total_count } }
  end

  # GET /appraisal_participate_departments/1
  def show
    render json: { department: @appraisal_participate_department.as_json(include: :department),
                   location:   @appraisal_participate_department.as_json(include: :location),
                   total:      { chinese_name:        I18n.t('appraisal.total', locale: :'zh-HK'),
                                 english_name:        I18n.t('appraisal.total', locale: :en),
                                 simple_chinese_name: I18n.t('appraisal.total', locale: :'zh-CN'),
                                 count: @appraisal_participate_department.participator_amount } }
  end

  # PATCH/PUT /appraisal_participate_departments/1
  def update
    if @appraisal_participate_department.update(appraisal_participate_department_params.permit(:confirmed))
      render json: @appraisal_participate_department
    else
      render json: @appraisal_participate_department.errors, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_appraisal_participate_department
      @appraisal_participate_department = AppraisalParticipateDepartment.find(params[:id])
    end

    def appraisal_participate_department_params
      params.require(:appraisal_participate_department).permit(*AppraisalParticipateDepartment.create_params)
    end

end
