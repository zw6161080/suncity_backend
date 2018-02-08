class AppraisalParticipatorsController < ApplicationController
  include SortParamsHelper
  include GenerateXlsxHelper
  include StatementBaseActions
  before_action :set_appraisal
  before_action :set_appraisal_participator, only: [:show, :update, :destroy, :create_assessor, :destroy_assessor]

  def after_query(query)
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = query.order_by(sort_column , sort_direction)
    respond_to do |format|
      format.json {
        query = query.page.page(params.fetch(:page, 1)).per(20)
        meta = {
            total_count: query.total_count,
            current_page: query.current_page,
            total_pages: query.total_pages,
            sort_column: sort_column.to_s,
            sort_direction: sort_direction.to_s,
        }
        render json: query, meta: meta, root: 'data', include: '**'
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        appraisal_participator_number_tag = Rails.cache.fetch('appraisal_participator_number_tag', :expires_in => 24.hours) do
          1
        end
        Rails.cache.write('appraisal_participator_number_tag', appraisal_participator_number_tag + 1)
        export_id = ("0000"+ appraisal_participator_number_tag.to_s).match(/\d{4}$/)[0]
        file_name = "#{@appraisal.appraisal_name}#{@appraisal.date_begin.strftime('%Y/%m/%d')}~#{@appraisal.date_end.strftime('%Y/%m/%d')}_#{I18n.t('appraisal_participator.assessors_filename')}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(
            query_ids: query.ids,
            query_model: controller_name,
            statement_columns: model.statement_columns_base('appraisal_participator_distributions'),
            serializer: 'AppraisalParticipatorSerializer',
            options: JSON.parse(model.options_later.to_json),
            my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def index
    after_query(search_query)
  end

  def index_by_department
    query = @appraisal.appraisal_participators.joins(:user).where(:users => { department_id: current_user.department_id })
    query = search_query(query)
    after_query(query)
  end

  def index_by_mine
    query = @appraisal.appraisal_participators.where(user_id: current_user.id)
    query = search_query(query)
    after_query(query)
  end

  def index_by_distribution
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query.order_by(sort_column , sort_direction)
    respond_to do |format|
      format.json {
        query = query.page.page(params.fetch(:page, 1)).per(20)
        meta = {
            total_count: query.total_count,
            current_page: query.current_page,
            total_pages: query.total_pages,
            sort_column: sort_column.to_s,
            sort_direction: sort_direction.to_s,
        }
        render json: query, meta: meta, root: 'data', include: '**'
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        appraisal_participator_number_tag = Rails.cache.fetch('appraisal_participator_number_tag', :expires_in => 24.hours) do
          1
        end
        Rails.cache.write('appraisal_participator_number_tag', appraisal_participator_number_tag + 1)
        export_id = ("0000"+ appraisal_participator_number_tag.to_s).match(/\d{4}$/)[0]
        file_name = "#{@appraisal.appraisal_name}#{@appraisal.date_begin.strftime('%Y/%m/%d')}~#{@appraisal.date_end.strftime('%Y/%m/%d')}_#{I18n.t('appraisal_participator.candidates_filename')}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(
            query_ids: query.ids,
            query_model: controller_name,
            statement_columns: model.statement_columns_base('appraisal_participators'),
            serializer: 'AppraisalParticipatorSerializer',
            options: JSON.parse(model.options_later.to_json),
            my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def not_filled_participators
    sort_column = sort_column_sym(params[:sort_column], :created_at)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    # query = not_filled_participator_query.order_by(sort_column , sort_direction)
    query = not_filled_participator_query
    query = query.page.page(params.fetch(:page, 1)).per(20)
    meta = {
        total_count: query.total_count,
        current_page: query.current_page,
        total_pages: query.total_pages,
        sort_column: sort_column.to_s,
        sort_direction: sort_direction.to_s,
    }
    render json: query, meta: meta, root: 'data', each_serializer: AppraisalQuestionnaireNotFilledInSerializer, include: '**'
  end

  def departmental_confirm
    targets = AppraisalParticipateDepartment.find(params[:ids])
    raise LogicError, { id:422, message: '找不到评核参与部门' } unless targets
    targets.each do |target|
      target.update(confirmed: true)
    end
    render json: { confirm: true }
  end

  def side_bar_options
    query = @appraisal.appraisal_participate_departments
    render json: query, root: 'data', include: '**'
  end

  # GET /appraisals/:appraisal_id/appraisal_participators/can_add_to_participator_list
  def can_add_to_participator_list
    # 检查员工是否可以添加至评核人员名单
    # 检查员工设定
    not_match_employee_setting = []
    if %w(assessing completed performance_interview).include? @appraisal.appraisal_status
      render json: { can_create: false, message: '评核状态不符合' }
      return
    end
    if(params[:user_ids] == []) || ( params[:user_ids] == nil)
      render json: { can_create: false, message: 'user_ids is [] or nil'}, root: 'data'
      return
    end
    params[:user_ids].each do |user_id|
      # 不存在员工设定 或 员工设定未完成
      appraisal_employee_setting = AppraisalEmployeeSetting.find_by(user_id: user_id)
      if !appraisal_employee_setting || !appraisal_employee_setting.has_finished
        not_match_employee_setting << user_id
      end
    end

    if not_match_employee_setting.count != 0
      render json: { can_create: false, message: '不存在员工设定 或 员工设定未完成', not_match_users: User.where(id: not_match_employee_setting) }, root: 'data'
    else
      render json: { can_create: true, not_match_users: [] }, root: 'data'
    end
  end

  # POST /appraisal/:appraisal_id/appraisal_participators
  # 添加员工
  def create
    # 检查
    not_match_employee_setting = []
    if(params[:user_ids] == []) || ( params[:user_ids] == nil)
      render json: { can_create: false, message: 'user_ids is [] or nil'}, root: 'data'
      return
    end
    if %w(assessing completed performance_interview).include? @appraisal.appraisal_status
      render json: { can_create: false, message: '评核状态不符合' }
      return
    end
    params[:user_ids].each do |user_id|
      # 不存在员工设定 或 员工设定未完成
      appraisal_employee_setting = AppraisalEmployeeSetting.find_by(user_id: user_id)
      if !appraisal_employee_setting || !appraisal_employee_setting.has_finished
        not_match_employee_setting << user_id
      end
    end
    if not_match_employee_setting.count != 0
      render json: { can_create: false, message: '不存在员工设定 或 员工设定未完成', not_match_users: User.where(id: not_match_employee_setting) }, root: 'data'
      return
    end
    ActiveRecord::Base.transaction do
      User.where(id: params[:user_ids]).each do |user|
        @appraisal.appraisal_participators.find_or_create_by(user_id: user.id) do |appraisal_participator|
          appraisal_employee_setting = AppraisalEmployeeSetting.find_by(user_id: user.id)
          appraisal_participator.update({appraisal_id: @appraisal.id,
                                         user_id: user.id,
                                         location_id: user.location_id,
                                         department_id: user.department_id,
                                         appraisal_department_setting_id: get_appraisal_department_setting_id(user),
                                         appraisal_employee_setting_id: appraisal_employee_setting.id
                                         # appraisal_grade: appraisal_employee_setting.level_in_department
                                        })
        end
      end
      @appraisal.appraisal_participators.each do |record|
        record.candidate_relationships.destroy_all
        record.create_candidate_participators
      end
    end
    # 更新评核人数
    @appraisal.update_participator_count
    # 更新部门评核人数
    @appraisal.update_department_participator_amount
    render json: { created: true }, root: 'data'
  end

  # GET /appraisal_participators/1
  def show
    case params[:assessors_type]
      when 'superior_assessors' then
        assessors_type = I18n.t('appraisal_participator.assessors_type.superior_assessment')
        assessors = @appraisal_participator.superior_assessors
      when 'colleague_assessors' then
        assessors_type = I18n.t('appraisal_participator.assessors_type.colleague_assessment')
        assessors = @appraisal_participator.colleague_assessors
      when 'subordinate_assessors' then
        assessors_type = I18n.t('appraisal_participator.assessors_type.subordinate_assessment')
        assessors = @appraisal_participator.subordinate_assessors
    end
    render json: {data: @appraisal_participator.as_json(include: {user: {include: [:department, :position]}}).merge(assessors_type: assessors_type),
                  assessors: assessors}
  end

  # 创建评核人
  # POST /appraisals/:appraisal_id/appraisal_participators/create_assessor
  def create_assessor
    raise LogicError, {id: 422, message: '參數不完整'}.to_json unless params[:assess_type] && params[:appraisal_id] && params[:id] && params[:assessor_id]
    raise LogicError, {id: 422, message: '同一个评核不能出现相同的评核者'}.to_json if @appraisal_participator.assess_relationships.where(assess_type: 'superior_assess').pluck(:assessor_id).include?params[:assessor_id]
    raise LogicError, {id: 422, message: '同一个评核不能出现相同的评核者'}.to_json if @appraisal_participator.assess_relationships.where(assess_type: 'colleague_assess').pluck(:assessor_id).include?params[:assessor_id]
    raise LogicError, {id: 422, message: '同一个评核不能出现相同的评核者'}.to_json if @appraisal_participator.assess_relationships.where(assess_type: 'subordinate_assess').pluck(:assessor_id).include?params[:assessor_id]
    raise LogicError, {id: 422, message: '非自我评核中不能出现本人'}.to_json if params[:assessor_id] == @appraisal_participator.user_id unless params[:assess_type] == 'self_assess'
    @appraisal_participator.assess_relationships.create(
      assess_type: params[:assess_type],
      appraisal_id: params[:appraisal_id],
      appraisal_participator_id: params[:id],
      assessor_id: params[:assessor_id]
    )
    render json: @appraisal_participator.assess_relationships
  end

  # 删除评核人
  # DELETE /appraisals/:appraisal_id/appraisal_participators/destroy_assessor
  def destroy_assessor
    if @appraisal_participator.assess_relationships.find_by(assessor_id: params[:assessor_id], assess_type: params[:assess_type]).destroy
      render json: { destroy: 'success' }, root: 'data'
    else
      render json: @appraisal_participator.assess_relationships.find_by(assessor_id: params[:assessor_id], assess_type: params[:assess_type]).destroy.error
    end
  end

  # DELETE /appraisal_participators/1
  def destroy
    if %w(unpublished to_be_assessed).include? @appraisal.appraisal_status
      @appraisal.clear_candidate_relationships
      @appraisal_participator.destroy
      @appraisal.reset_candidate_relationships
      @appraisal.update_participator_count
      @appraisal.update_department_participator_amount
      render json: { destroy: true }, root: 'data'
      return
    end
    render json: { destroy: false }, root: 'data'
  end

  # GET /appraisal_participators/auto_assign
  def auto_assign
    targets = @appraisal.appraisal_participators.select(:location_id, :department_id)
    location = targets.map { |rec| rec.location_id }.uniq
    department = targets.map { |rec| rec.department_id }.uniq
    department_has_finished = AppraisalDepartmentSetting.whether_appraisal_template_has_been_setted({ location: location, department: department })
    employee_setting_has_finished = AppraisalEmployeeSetting.whether_setting_has_finished({ location: location, department: department })
    if department_has_finished && employee_setting_has_finished
      ActiveRecord::Base.transaction do
        @appraisal.appraisal_participators.each do |appraisal_participator|
          appraisal_participator.create_assess_participators
        end
      end
      render json: { auto_assign: true, department_setting: department_has_finished, employee_setting: employee_setting_has_finished }, root: 'data'
      return
    end

    render json: { auto_assign: false, department_setting: department_has_finished, employee_setting: employee_setting_has_finished }, root: 'data'
  end

  # GET /appraisal_participators/options
  def options
    render json: AppraisalParticipator.options
  end


  private
  def set_appraisal_participator
    @appraisal_participator = AppraisalParticipator.find(params[:id])
  end

  def set_appraisal
    authorize Appraisal
    @appraisal = Appraisal.find(params[:appraisal_id])
  end

  def appraisal_participator_params
    params.require(:appraisal_participator).permit(*AppraisalParticipator.create_params)
  end

  def get_appraisal_department_setting_id(user)
    AppraisalDepartmentSetting.find_by(location_id: user.location_id, department_id: user.department_id).id
  end

  def not_filled_participator_query
    # query = @appraisal.appraisal_participators
    #             .joins(:appraisal_questionnaires => :questionnaire)
    #             .where(:questionnaires => {is_filled_in: false})
    #             .group(:id)
    query = User.joins(:appraisal_questionnaires => :questionnaire).where(appraisal_questionnaires: {appraisal_id: @appraisal.id}).where(:questionnaires => {is_filled_in: false}).group(:id)
    query
  end

  def search_query(query = @appraisal.appraisal_participators.all)
    query = query.joins(:user => :profile)
    %w(employee_id employee_name location department position grade division_of_job date_of_employment).each do  |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
      query = query.by_assess_others(params[:assess_others], params[:appraisal_id]) if params[:assess_others]
    query
  end

end
