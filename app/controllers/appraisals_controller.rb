class AppraisalsController < ApplicationController
  include DownloadActionAble
  include SortParamsHelper
  include MineCheckHelper
  before_action :set_appraisal_basic_setting, only: [:create]
  before_action :set_appraisal, only: [:show, :update, :destroy, :initiate, :complete, :release_reports, :performance_interview, :performance_interview_check ,:complete_or_no]
  before_action :set_users, only: [:show]
  before_action :myself?, only:[:show], if: :entry_from_mine?

  def performance_interview_check
    authorize Appraisal
    if @appraisal.appraisal_status != 'completed'
      render json: { performace_interview: false, message: 'status not matched.' }, root: 'data'
      return
    end
    if @appraisal.performance_interviews.count != 0
      render json: { performance_interview: false, message: 'there is performance interview been initiated.' }
      return
    end
    render json: { performance_interview: true }
  end

  # 发起绩效面谈
  def performance_interview
    authorize Appraisal
    if @appraisal.appraisal_status != 'completed'
      render json: { performace_interview: false, message: 'status not matched.' }, root: 'data'
      return
    end
    if @appraisal.performance_interviews.count != 0
      render json: { performance_interview: false, message: 'there is performance interview been initiated.' }
      return
    end
    ActiveRecord::Base.transaction do
      @appraisal.update(appraisal_status: 'performance_interview', release_interviews: true)
      @appraisal.appraisal_participators.each do |participator|
        @appraisal.performance_interviews.create(
          appraisal_participator_id: participator.id,
          performance_interview_status: 'not_completed')
      end
    end
    render json: @appraisal
  end

  # 发起评核
  def initiate
    if @appraisal.appraisal_status != 'to_be_assessed'
      render json: { meet_the_number_conditions: false, message: '评核状态不符合 待评核' }
      return
    end
    # 检查评核人员名单中评核人数是否满足条件
    not_match_users = @appraisal.appraisal_meet_the_assessment_conditions
    if not_match_users.size > 0
      render json: { meet_the_number_conditions: false, not_match_users: not_match_users }
      return
    end
    # TODO 检查评核模版是否设置完整
    targets = @appraisal.appraisal_participators.select(:location_id, :department_id)
    location = targets.map { |rec| rec.location_id }.uniq
    department = targets.map { |rec| rec.department_id }.uniq
    department_has_finished = AppraisalDepartmentSetting.whether_appraisal_template_has_been_setted({ location: location, department: department })
    unless department_has_finished
      render json: { meet_the_number_conditions: false,  appraisal_department_setting: false, message: '评核模版设定不完整' }
      return
    end
    # 固化部分属性 & 创建自我评核关系
    @appraisal.appraisal_participators.each do |participator|
      participator.regularize_setting
      AssessRelationship.find_or_create_by(appraisal_id: @appraisal.id,
                                           appraisal_participator_id: participator.id,
                                           assessor_id: participator.user_id,
                                           assess_type: 'self_assess')
    end
    # 生成评核问卷
    ActiveRecord::Base.transaction do
      # 改变评核状态
      @appraisal.update(appraisal_status: 'assessing')
      # 创建评核问卷
      AssessRelationship.where(appraisal_id: @appraisal.id).each do |assess_relationship|
        # 获取模板
        participator = assess_relationship.appraisal_participator
        department_setting = participator.appraisal_department_setting
        group = participator.grade_to_group
        questionnaire_template_id = department_setting.group_to_questionnaire_template_id(group)
        if questionnaire_template_id
          questionnaire_template = QuestionnaireTemplate.find(questionnaire_template_id)

          questionnaire = questionnaire_template.questionnaires.create(region: participator.user.profile.region,
                                                                       user_id: participator.user.id,
                                                                       is_filled_in: false)

          @appraisal.appraisal_questionnaires.create(questionnaire_id: questionnaire.id,
                                                   assess_type: assess_relationship.assess_type,
                                                   assessor_id: assess_relationship.assessor_id,
                                                   appraisal_participator_id: assess_relationship.appraisal_participator_id)
        end
      end
    end
    render json: @appraisal.appraisal_questionnaires, include: '**'
  end

  def complete_or_no
    authorize Appraisal
    not_filled_in_questionnaires = @appraisal.appraisal_questionnaires.joins(:questionnaire).where(:questionnaires => { is_filled_in: false })
    if not_filled_in_questionnaires.count > 0
      render json: { complete_questionnaire: false }, root: 'data'
    else
      render json: { complete_questionnaire: true }, root: 'data'
    end
  end

  def complete
    authorize Appraisal
    if @appraisal.appraisal_status != 'assessing'
      render json: { complete: false, message: '评核状态不符合 评核中' }, root: 'data'
      return
    end

    # 生成报告
    ActiveRecord::Base.transaction do
      @appraisal.update(appraisal_status: 'completed')
      # @appraisal.appraisal_questionnaires
      #     .includes(:questionnaire => { :questionnaire_template => :matrix_single_choice_questions }).each do |aq|
      #   # todo 处理未填写的问卷
      #   aq.count_questionnaire_score
      # end
      @appraisal.appraisal_participators.each {|participator| participator.generate_appraisal_report_overall_score}
      @appraisal.appraisal_participators.each {|participator| participator.appraisal_report.generate_detail_report}
      @appraisal.update_self_score
    end
    render json: @appraisal.appraisal_reports

  end

  def release_reports
    @appraisal.update(release_reports: true)
    # Message.add_notification target must be an array of ids
    Message.add_notification(@appraisal, 'release_reports', @appraisal.appraisal_participators.collect(&:user_id))
    render json: { release_reports: 'success' }, root: 'data'
  end

  # GET /appraisals
  def index
    authorize Appraisal
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query.page.page(params.fetch(:page, 1)).per(20)
    meta = {
      total_count: query.total_count,
      current_page: query.current_page,
      total_pages: query.total_pages,
      sort_column: sort_column.to_s,
      sort_direction: sort_direction.to_s,
    }
    render json: query, status: 200, root: 'data', meta: meta, include: '**'
  end

  #我的评核
  def index_by_mine
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = Appraisal.joins(:appraisal_participators)
                .where(:appraisal_participators => { user_id: current_user.id })
                .where(appraisal_status: %w(assessing completed performance_interview))
    query = search_query(query)
    query = query.page.page(params.fetch(:page, 1)).per(20)
    meta = {
        total_count: query.total_count,
        current_page: query.current_page,
        total_pages: query.total_pages,
        sort_column: sort_column.to_s,
        sort_direction: sort_direction.to_s
    }
    render json: query, status: 200, root: 'data', meta: meta, each_serializer:AppraisalByMineAndDepartmentSerializer, current_user: current_user, include: '**'
  end

  #部门的评核
  def index_by_department
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = Appraisal.joins(:appraisal_participators => :user)
                .where(:users => { department_id: current_user.department_id })
                .where(appraisal_status: %w(to_be_assessed assessing completed performance_interview)).distinct(:id)
    query = search_query(query)
    query = query.page.page(params.fetch(:page, 1)).per(20)
    meta = {
        total_count: query.total_count,
        current_page: query.current_page,
        total_pages: query.total_pages,
        sort_column: sort_column.to_s,
        sort_direction: sort_direction.to_s,
    }
    render json: query, status: 200, root: 'data', meta: meta, each_serializer:AppraisalByMineAndDepartmentSerializer, current_user: current_user, include: '**'
  end

  # GET /appraisals/options
  def options
    render json: [
      {key: 'unpublished',
       chinese_name:        I18n.t('appraisal.option_appraisal_status.unpublished', locale: :'zh-HK'),
       english_name:        I18n.t('appraisal.option_appraisal_status.unpublished', locale: :en),
       simple_chinese_name: I18n.t('appraisal.option_appraisal_status.unpublished', locale: :'zh-CN')},

      {key: 'to_be_assessed',
       chinese_name:        I18n.t('appraisal.option_appraisal_status.to_be_assessed', locale: :'zh-HK'),
       english_name:        I18n.t('appraisal.option_appraisal_status.to_be_assessed', locale: :en),
       simple_chinese_name: I18n.t('appraisal.option_appraisal_status.to_be_assessed', locale: :'zh-CN')},

      {key: 'assessing',
       chinese_name:        I18n.t('appraisal.option_appraisal_status.assessing', locale: :'zh-HK'),
       english_name:        I18n.t('appraisal.option_appraisal_status.assessing', locale: :en),
       simple_chinese_name: I18n.t('appraisal.option_appraisal_status.assessing', locale: :'zh-CN')},

      {key: 'completed',
       chinese_name:        I18n.t('appraisal.option_appraisal_status.completed', locale: :'zh-HK'),
       english_name:        I18n.t('appraisal.option_appraisal_status.completed', locale: :en),
       simple_chinese_name: I18n.t('appraisal.option_appraisal_status.completed', locale: :'zh-CN')},
    ]
  end

  # POST /appraisals/can_create
  # 检查是否可以创建360评核(params同创建)
  def can_create
    whether_employee_setting_completed = AppraisalEmployeeSetting.whether_setting_has_finished(params)
    # whether_department_setting_completed = AppraisalDepartmentSetting.whether_appraisal_template_has_been_setted(params)
    # if whether_employee_setting_completed && whether_department_setting_completed
    if whether_employee_setting_completed
      render json: { can_create: true }, root: 'data'
    else
      render json: {
        can_create: false,
        employee_setting_status: whether_employee_setting_completed,
        # department_setting_status: whether_department_setting_completed
      }, root: 'data'
    end
  end

  def destroy
    if %w(unpublished to_be_assessed).include? @appraisal.appraisal_status
      @appraisal.appraisal_participate_departments.destroy_all
      CandidateRelationship.where(appraisal_id: @appraisal.id).destroy_all
      AssessRelationship.where(appraisal_id: @appraisal.id).destroy_all
      @appraisal.appraisal_participators.destroy_all
      @appraisal.destroy
      render json: { destroy: true }
      return
    end
    render json: { destroy: false, message: '当前状态不能删除' }
  end

  # POST /appraisals
  def create
    authorize Appraisal
    # 检查部门设定和员工设定的完整度
    whether_employee_setting_completed = AppraisalEmployeeSetting.whether_setting_has_finished(params)
    if !whether_employee_setting_completed
      render json: {
        can_create: 'false',
        employee_setting_status: whether_employee_setting_completed,
      }, root: 'data'
      return
    end

    ActiveRecord::Base.transaction do
      # 筛选评核人员
      participators = User.where(location_id: params['location'])
                        .where(department_id: params['department'])
                        .where(position_id: params['position'])
                        .where(grade: params['grade'])

      from = Time.zone.parse(params['date_of_employment']['begin']).beginning_of_day rescue nil
      to   = Time.zone.parse(params['date_of_employment']['end']).end_of_day rescue nil
      if from && to
        participators = participators.joins(:profile)
                          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from ", from: from)
                          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
      elsif from
        participators = participators.joins(:profile)
                          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
      elsif to
        participators = participators.joins(:profile)
                          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
      end



      # 创建评核
      participator_amount = participators.count rescue 0
      participator_department_amount = participators.where(department_id:current_user.department_id).count rescue 0

      raise LogicError, {id: 422, message: '參數不完整'}.to_json unless appraisal_params
      raise LogicError, {id: 422, message: '時間不符合規則'}.to_json if params[:date_begin] > params[:date_end]
      appraisal = Appraisal.create(appraisal_params.as_json.merge(
        appraisal_status: :unpublished,
        participator_amount: participator_amount,
        participator_department_amount: participator_department_amount,
        appraisal_introduction: @appraisal_basic_setting.introduction
      ))
      # copy 相关文件 from 基础设定
      appraisal.create_appraisal_attachments
      appraisal.save!
      if participator_amount > 0
        # 创建评核人员名单
        participators.each do |participator|
          appraisal_department_setting = set_appraisal_department_setting(participator)
          appraisal_employee_setting = AppraisalEmployeeSetting.find_by_user_id(participator.id)
          if appraisal_employee_setting && appraisal_department_setting
            AppraisalParticipator.create({
                                           appraisal_id: appraisal.id,
                                           user_id: participator.id,
                                           location_id: participator.location_id,
                                           department_id: participator.department_id,
                                           appraisal_department_setting_id: set_appraisal_department_setting(participator).id,
                                           appraisal_employee_setting_id: appraisal_employee_setting.id,
                                           appraisal_grade: appraisal_employee_setting.level_in_department})
          end
        end

        Location.model_with_departments.each do |location|
          location.departments.each do |department|
            appraisal.appraisal_participate_departments
                .create(location_id: location.id,
                        department_id: department.id,
                        confirmed: false,
                        participator_amount: participators.where(location_id: location.id, department_id: department.id).count
                )
          end
        end

        # 创建评审候选关系
        appraisal.appraisal_participators.all.each do |participator|
          participator.create_candidate_participators
        end
      end
    end
    render json: Appraisal.last
  end

  # GET /appraisals/appraisal_id
  def show
    render json: @appraisal, include: '**'
  end

  # GET /appraisals/appraisal_id
  def update
    if @appraisal.update(params.permit(:appraisal_status))
      render json: @appraisal
    else
      render json: @appraisal.errors, status: :unprocessable_entity
    end
  end

  private

  def set_users
    @users = User.where(id: @appraisal.appraisal_participators.pluck(:user_id))
  end

  def update_ave_scores
    @appraisal.update_appraisal_average_score
  end

  def set_appraisal
    authorize Appraisal unless entry_from_mine? || (%w(show release_reports).include? params[:action])
    @appraisal = Appraisal.find(params[:id])
  end

  def set_appraisal_basic_setting
    @appraisal_basic_setting = AppraisalBasicSetting.first
  end

  def set_appraisal_department_setting(participator)
    AppraisalDepartmentSetting.find_by(location_id: participator.location_id, department_id: participator.department_id)
  end

  # Only allow a trusted parameter "white list" through.
  def appraisal_params
    params.require(:appraisal_name)
    params.require(:date_begin)
    params.require(:date_end)
    params.require(:location)
    params.require(:department)
    params.require(:position)
    params.require(:grade)
    params.permit(*Appraisal.create_params)
  end

  def search_query(query = Appraisal.all)
    {
      appraisal_status:                 :by_appraisal_status,
      appraisal_date:                   :by_appraisal_date,
      participator_amount:              :by_participator_amount,
      participator_department_amount:   :by_participator_department_amount,
      ave_total_appraisal:              :by_ave_total_appraisal,
      ave_superior_appraisal:           :by_ave_superior_appraisal,
      ave_colleague_appraisal:          :by_ave_colleague_appraisal,
      ave_subordinate_appraisal:        :by_ave_subordinate_appraisal,
      ave_self_appraisal:               :by_ave_self_appraisal,
      total_ave_self_appraisal:         :by_total_ave_self_appraisal,
      ave_department_appraisal:         :by_ave_department_appraisal
    }.each do |key, value|
      query = query.send(value, params[key]) if params[key]
    end
    query.order_by((params[:sort_column] || :created_at), (params[:sort_direction] || :desc))
  end
end
