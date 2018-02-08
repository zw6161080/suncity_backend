  # coding: utf-8
class ClientCommentsController < ApplicationController
  include MineCheckHelper
  include SortParamsHelper
  include GenerateXlsxHelper

  before_action :set_client_comment, only: [:show, :update]
  before_action :set_user, only: [:index]
  before_action :myself?, only:[:index], if: :entry_from_mine?
  # GET /client_comments
  def index
    authorize ClientComment  unless entry_from_mine?
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
    if [:employee_id, :department, :position, :last_tracker, :employee_name, :questionnaire_template].include?(sort_column)
      case sort_column
      when :employee_id then
        query = query.includes(:user)
                  .order("users.empoid #{sort_direction}")
                  .page
                  .page(params.fetch(:page, 1))
                  .per(20)
      when :department then
        query = query.includes(:user)
                  .order("users.department_id #{sort_direction}")
                  .page
                  .page(params.fetch(:page, 1))
                  .per(20)
      when :position then
        query = query.includes(:user)
                  .order("users.position_id #{sort_direction}")
                  .page
                  .page(params.fetch(:page, 1))
                  .per(20)
      when :last_tracker then
        query = query
                  .order("last_tracker_id #{sort_direction}")
                  .page(params.fetch(:page, 1))
                  .per(20)
      when :employee_name
        query = query.includes(:user)
                  .order("users.#{select_language} #{sort_direction}")
                  .page
                  .page(params.fetch(:page, 1))
                  .per(20)
      when :questionnaire_template
        query = query.includes(:user)
                  .order("questionnaire_template_id #{sort_direction}")
                  .page
                  .page(params.fetch(:page, 1))
                  .per(20)

      end
    else
      query = query
                .order(sort_column => sort_direction)
                .page
                .page(params.fetch(:page, 1))
                .per(20)
    end
    meta = {
      total_count: query.total_count,
      current_page: query.current_page,
      total_pages: query.total_pages,
      sort_column: sort_column.to_s,
      sort_direction: sort_direction.to_s,
    }
    data = query.map do |record|
      record.get_json_data
    end
    response_json data.as_json, meta: meta
  end

  # GET /client_comments/export
  def export
    # 数据查询
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
    if [:employee_id, :department, :position, :last_tracker].include?(sort_column)
      case sort_column
      when :employee_id then
        query = query.includes(:user).order("users.empoid #{sort_direction}")
      when :department then
        query = query.includes(:user).order("users.department_id #{sort_direction}")
      when :position then
        query = query.includes(:user).order("users.position_id #{sort_direction}")
      when :last_tracker then
        query = query.order("last_tracker_id #{sort_direction}")
      end
    else
      query = query.order(sort_column => sort_direction)
    end
    data = query.map do |record|
      record.get_json_data
    end

    # 数据筛选
    selected_data = data.map do |record|
      one_record = {}
      one_record[:employee_id] = record.dig 'user.empoid'
      one_record[:client_fill_in_date] = record.dig('client_fill_in_date').strftime('%Y/%m/%d')
      one_record[:client_account] = record.dig 'client_account'
      one_record[:client_name] = record.dig 'client_name'
      if record.dig('last_track_date')
        one_record[:last_track_date] = record.dig('last_track_date').strftime('%Y/%m/%d')
      else
        one_record[:last_track_date] = ' '
      end
      if record.dig('last_track_content')
        one_record[:last_track_content] = record.dig('last_track_content')
      else
        one_record[:last_track_content] = ' '
      end
      if I18n.locale==:en
        one_record[:employee_name] = record.dig 'user.english_name'
        one_record[:department] = record.dig 'user.department.english_name'
        one_record[:position] = record.dig 'user.position.english_name'
        one_record[:questionnaire_template] = record.dig 'questionnaire_template.english_name'
        one_record[:last_tracker] = record.dig 'last_tracker.english_name' rescue nil
      elsif I18n.locale==:'zh-CN'
        one_record[:employee_name] = record.dig 'user.simple_chinese_name'
        one_record[:department] = record.dig 'user.department.simple_chinese_name'
        one_record[:position] = record.dig 'user.position.simple_chinese_name'
        one_record[:questionnaire_template] = record.dig 'questionnaire_template.simple_chinese_name'
        one_record[:last_tracker] = record.dig 'last_tracker.simple_chinese_name' rescue nil
      else
        one_record[:employee_name] = record.dig 'user.chinese_name'
        one_record[:department] = record.dig 'user.department.chinese_name'
        one_record[:position] = record.dig 'user.position.chinese_name'
        one_record[:questionnaire_template] = record.dig 'questionnaire_template.chinese_name'
        one_record[:last_tracker] = record.dig 'last_tracker.chinese_name' rescue nil
      end
      one_record[:last_tracker] = ' ' if one_record[:last_tracker]==nil
      one_record
    end
    # 生成Excel
    xlsx_data = {
      fields: {:employee_name => I18n.t('client_comment.header.employee_name'),
               :employee_id => I18n.t('client_comment.header.employee_id'),
               :department => I18n.t('client_comment.header.department'),
               :position => I18n.t('client_comment.header.position'),
               :questionnaire_template => I18n.t('client_comment.header.questionnaire_template'),
               :client_fill_in_date => I18n.t('client_comment.header.client_fill_in_date'),
               :client_account => I18n.t('client_comment.header.client_account'),
               :client_name => I18n.t('client_comment.header.client_name'),
               :last_tracker => I18n.t('client_comment.header.last_tracker'),
               :last_track_date => I18n.t('client_comment.header.last_track_date'),
               :last_track_content => I18n.t('client_comment.header.last_track_content')},
      records: selected_data,
    }
    response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
    client_comment_export_number_tag = Rails.cache.fetch('client_comment_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000"+client_comment_export_number_tag.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('client_comment_export_number_tag', client_comment_export_number_tag+1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: I18n.t('client_comment.filename')+Time.zone.now.strftime('%Y%m%d')+export_id.to_s+'.xlsx')
    GenerateTableJob.perform_later(data: xlsx_data, my_attachment: my_attachment)
    render json: my_attachment
  end

  # GET /client_comments/1
  def show
    # authorize ClientComment
    query = @client_comment.as_json(include: {user: {include: [:location, :department, :position, :profile]}})
    tracks = ClientCommentTrack.includes(:user).where(client_comment_id: @client_comment.id).as_json(include: :user)
    response_json query: query.as_json, tracks: tracks
  end

  # POST /client_comments
  def create
    # authorize ClientComment unless entry_from_mine?
    client_comment = ClientComment.create(client_comment_params.as_json)
    ClientCommentTrack.create({
                                content: params['track_content'],
                                user_id: current_user.id,
                                track_date: Time.zone.now,
                                client_comment_id: client_comment.id
                              }) if params['track_content']
    if params[:questionnaire_template_id]
      template = QuestionnaireTemplate.find(params[:questionnaire_template_id])
      questionnaire_id = template.questionnaires.create_with_params(
        params[:questionnaire],
        params[:fill_in_the_blank_questions],
        params[:choice_questions],
        params[:matrix_single_choice_questions],
      )

      client_comment.questionnaire_id = questionnaire_id
      client_comment.save!
    end

    response_json client_comment
  end

  # PATCH/PUT /client_comments/1
  def update
    authorize ClientComment
    if @client_comment.update(client_comment_params.permit(
      :client_account,
      :client_name,
      :client_fill_in_date,
      :client_phone,
      :client_account_date,
      :involving_staff,
      :event_time_start,
      :event_time_end,
      :event_place,
      :questionnaire_template_id,
      :questionnaire_id))

      questionnaire = Questionnaire.find(params[:questionnaire_id])
      questionnaire_id = questionnaire.update_with_params(
        params[:questionnaire],
        params[:fill_in_the_blank_questions],
        params[:choice_questions],
        params[:matrix_single_choice_questions],
      )
      @client_comment.questionnaire_id = questionnaire_id
      @client_comment.save!
      render json: @client_comment
    else
      render json: @client_comment.errors, status: :unprocessable_entity
    end
  end

  # GET /client_comments/show_tracker
  def show_tracker
    authorize ClientComment
    response_json User.find(params[:user_id]).as_json(include: [:location, :department, :position, :profile])
  end

  # GET /client_comments/columns
  def columns
    authorize ClientComment
    render json: [
      {key: 'employee_name', chinese_name: '跟進員工姓名', english_name: 'Followed up name', simple_chinese_name: '跟进员工姓名'},
      {key: 'employee_id', chinese_name: '跟進員工編號', english_name: 'Staff ID', simple_chinese_name: '跟进员工编号'},
      {key: 'department', chinese_name: '跟進員工部門', english_name: 'Staff department', simple_chinese_name: '跟进员工部门'},
      {key: 'position', chinese_name: '跟進員工職位', english_name: 'Staff position', simple_chinese_name: '跟进员工职位'},
      {key: '', chinese_name: '客戶意見問卷模板', english_name: 'Customer opinion questionnaire template', simple_chinese_name: '客户意见问卷模板'},
      {key: 'client_fill_in_date', chinese_name: '客戶填寫日期', english_name: 'Filling date', simple_chinese_name: '客户填写日期'},
      {key: 'client_account', chinese_name: '客戶戶口', english_name: 'Customer account', simple_chinese_name: '客户户口'},
      {key: 'client_name', chinese_name: '客戶姓名', english_name: 'Customer name', simple_chinese_name: '客户姓名'},
      {key: 'last_tracker', chinese_name: '最新跟進人', english_name: 'The latest follower', simple_chinese_name: '最新跟进人'},
      {key: 'last_track_date', chinese_name: '最新跟進日期', english_name: 'Latest follow-up date', simple_chinese_name: '最新跟进日期'},
      {key: 'last_track_content', chinese_name: '最新跟進內容', english_name: 'Latest follow-up content', simple_chinese_name: '最新跟进内容'},
      {key: 'operation', chinese_name: '操作', english_name: 'Operate', simple_chinese_name: '操作'},
    ]
  end

  # GET /client_comments/options
  def options
    # authorize ClientComment unless entry_from_mine?
    response_json ClientComment.options
  end

  private


  def set_user
    @user = User.find(params[:user_id]) if  entry_from_mine?
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_client_comment
    @client_comment = ClientComment.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def client_comment_params
    params.permit(*ClientComment.create_params)
  end

  def search_query
    query = ClientComment.includes(user: [:department, :position]).includes(:last_tracker)
    {
      user_id: :by_user_id, # 用于区分：客户意见 我的客户意见
      employee_name: :by_employee_name,
      employee_id: :by_employee_id,
      department: :by_department,
      position: :by_position,
      client_fill_in_date: :by_client_fill_in_date,
      client_account: :by_client_account,
      client_name: :by_client_name,
      last_tracker: :by_last_tracker,
      last_track_date: :by_last_track_date,
      questionnaire_template: :by_questionnaire_template
    }.each do |key, value|
      query = query.send(value, params[key]) if params[key]
    end
    query
  end

end
