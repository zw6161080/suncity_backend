class AppraisalGroupsController < ApplicationController
  before_action :set_appraisal_group, only: [:update, :destroy]
  before_action :set_appraisal_department_setting, only: [:create, :update]

  # POST /appraisal_groups
  def create
    raise LogicError, {id: 422, message: '參數不完整'}.to_json unless appraisal_group_params
    @appraisal_group = @appraisal_department_setting.appraisal_groups.create(appraisal_group_params)
    render json: @appraisal_group
  end

  # PATCH/PUT /appraisal_groups/1
  def update
    appraisal_group = @appraisal_department_setting.appraisal_groups.find(params[:id])
    raise LogicError, {id: 422, message: '分组不存在'}.to_json unless appraisal_group
    result = appraisal_group.update(params.permit(:name))

    render json: result
  end

  # DELETE /appraisal_groups/1
  def destroy
    @appraisal_group.destroy
  end

  private

  def set_appraisal_department_setting
    @appraisal_department_setting = AppraisalDepartmentSetting.find(params[:appraisal_department_setting_id])
  end

    # Use callbacks to share common setup or constraints between actions.
    def set_appraisal_group
      @appraisal_group = AppraisalGroup.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def appraisal_group_params
      params.permit(:name, :appraisal_department_setting_id)
    end
end
