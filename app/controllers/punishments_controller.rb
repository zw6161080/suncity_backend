# coding: utf-8
class PunishmentsController < ApplicationController

  include SortParamsHelper
  include CurrentUserHelper
  include GenerateXlsxHelper
  include MineCheckHelper
  include CareerRecordHelper

  before_action :set_punishment, only: [:show, :update, :destroy]
  before_action :set_profile_punishment, only: [:profile_show, :profile_update]
  before_action :set_user, only: [:profile_index]
  before_action :myself?, only:[:profile_index], if: :entry_from_mine?
  # GET /punishments
  def index
    authorize Punishment
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
    if [:employee_no,:department_id,:position_id].include?(sort_column)
      case sort_column
        when :employee_no then
          query = query.includes(:user)
                      .order("users.empoid #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
        when :department_id then
          query = query.includes(:user)
                      .order("users.department_id #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
        when :position_id then
          query = query.includes(:user)
                      .order("users.position_id #{sort_direction}")
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
    data = query.map do |punishment|
      punishment.get_json_data
    end
    response_json data.as_json, meta: meta
  end

  # GET /punishments/export
  def export
    authorize Punishment
    # 数据查询
    sort_column = sort_column_sym(params[:sort_column], 'punishment_date')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
    if [:employee_no,:department_id,:position_id].include?(sort_column)
      case sort_column
        when :employee_no then
          query = query.includes(:user).order("users.empoid #{sort_direction}")
        when :department_id then
          query = query.includes(:user).order("users.department_id #{sort_direction}")
        when :position_id then
          query = query.includes(:user).order("users.position_id #{sort_direction}")
      end
    else
      query = query.order(sort_column => sort_direction)
    end
    data = query.map do |punishment|
      punishment.get_json_data
    end
    # 数据筛选
    selected_data = data.map do |record|
      one_record = {}
      one_record[:punishment_status]         = record.dig 'punishment_status'
      one_record[:employee_id]               = record.dig 'user.empoid'
      if record.dig('punishment_date')
        one_record[:punishment_date]         = record.dig('punishment_date').strftime('%Y/%m/%d')
      else
        one_record[:punishment_date]         = ' '
      end
      if record.dig 'punishment_result'
        one_record[:punishment_result]       = record.dig 'punishment_result'
      else
        one_record[:punishment_result]       = ' '
      end
      if record.dig 'punishment_category'
        str = ''
        record.dig('punishment_category').split(',').each do |category|
          str += I18n.t(category)+'，'
        end
        one_record[:punishment_category]     = str.chop
      else
        one_record[:punishment_category]     = ' '
      end
      if record.dig 'punishment_content'
        one_record[:punishment_content]      = ''
        record.dig('punishment_content').split(',').each do |content|
          one_record[:punishment_content] += I18n.t(content)
        end
        one_record[:punishment_content]      = one_record[:punishment_content].chop+'。'
      else
        one_record[:punishment_content]      = ' '
      end
      one_record[:punishment_recording_date] = record.dig('created_at').strftime('%Y/%m/%d')
      one_record[:punishment_remarks]        = record.dig 'punishment_remarks'
      if I18n.locale==:en
        one_record[:employee_name]       = record.dig 'user.english_name'
        one_record[:employee_department] = record.dig 'user.department.english_name'
        one_record[:employee_position]   = record.dig 'user.position.english_name'
        one_record[:punishment_recorder] = record.dig('tracker').english_name
      elsif I18n.locale==:'zh-CN'
        one_record[:employee_name]       = record.dig 'user.simple_chinese_name'
        one_record[:employee_department] = record.dig 'user.department.simple_chinese_name'
        one_record[:employee_position]   = record.dig 'user.position.simple_chinese_name'
        one_record[:punishment_recorder] = record.dig('tracker').simple_chinese_name
      else
        one_record[:employee_name]       = record.dig 'user.chinese_name'
        one_record[:employee_department] = record.dig 'user.department.chinese_name'
        one_record[:employee_position]   = record.dig 'user.position.chinese_name'
        one_record[:punishment_recorder] = record.dig('tracker').chinese_name
      end
      one_record
    end
    # 生成Excel
    xlsx_data = {
        fields: {:punishment_status         => I18n.t('punishment.header.punishment_status'),
                 :employee_name             => I18n.t('punishment.header.employee_name'),
                 :employee_id               => I18n.t('punishment.header.employee_id'),
                 :employee_department       => I18n.t('punishment.header.employee_department'),
                 :employee_position         => I18n.t('punishment.header.employee_position'),
                 :punishment_date           => I18n.t('punishment.header.punishment_date'),
                 :punishment_result         => I18n.t('punishment.header.punishment_result'),
                 :punishment_category       => I18n.t('punishment.header.punishment_category'),
                 :punishment_content        => I18n.t('punishment.header.punishment_content'),
                 :punishment_recorder       => I18n.t('punishment.header.punishment_recorder'),
                 :punishment_recording_date => I18n.t('punishment.header.punishment_recording_date'),
                 :punishment_remarks        => I18n.t('punishment.header.punishment_remarks')},
        records: selected_data,
    }
    response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
    punishment_export_number_tag = Rails.cache.fetch('punishment_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+punishment_export_number_tag.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('punishment_export_number_tag', punishment_export_number_tag + 1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: I18n.t('punishment.filename')+Time.zone.now.strftime('%Y%m%d')+export_id.to_s+'.xlsx')
    GenerateTableJob.perform_later(data: xlsx_data, my_attachment: my_attachment)
    render json: my_attachment
  end

  # GET /punishments/:id/index_by_empoid_or_name
  def index_by_empoid_or_name
    response_json Punishment.detail_by_user_id(params[:id]).as_json(include: [:user])
  end

  # GET /punishments/1
  # 完成页/详情页
  def show
    if @punishment
      response_json({ punishment_infomation: @punishment.as_json(include: [
                                                            { user: { include: [:department, :position, :location]}},
                                                            { approval_items: { include: { user: { include: [:department, :position]}}}},
                                                            { attend_attachments: { include: [:creator]}},]),
                           user_profile:          @user_profile.as_json })
    else
      response_json [], status: :unprocessable_entity
    end
  end

  # GET /punishments/show_profile
  # 新增页
  def show_profile
    authorize Punishment
    profile = User.find(params[:user_id]).profile
    department_data = Department.find(profile.data['position_information']['field_values']['department'])
    position_data   = Position.find(profile.data['position_information']['field_values']['position'])
    location_data   = Location.find(profile.data['position_information']['field_values']['location'])
    response_json({ profile: profile, select: Config.get(:selects),
                    department_data: department_data, position_data: position_data, location_data: location_data })
  end

  # POST /punishments
  # 新增页
  def create
    authorize Punishment
    punishment = Punishment.create(punishment_params.as_json.merge(
        records_in_where: 'not_profile',
        punishment_status: 'punishment.enum_punishment_status.punishing',
        tracker_id: current_user.id,
        track_date: Time.zone.now)
    )
    if punishment[:incident_suspended]
      # 新增职程信息
      user = User.find(punishment[:user_id])
      user.create_career_record_for_suspension_investigation(
        career_begin: params[:incident_suspended_date],
        deployment_instructions: params['deployment_instructions'],
        comment: params['comment'],
        inputer_id: current_user.id
      )
    end
    response_json punishment.id
  end

  # PATCH/PUT /punishments/1
  # 完成页
  def update
    authorize Punishment
    profile_abolition_date  = nil
    case punishment_params.as_json['punishment_result']
      when 'punishment.enum_punishment_result.classA_written_warning' then
        profile_abolition_date  = Time.zone.parse(punishment_params.as_json['punishment_date']) + 6.month
      when 'punishment.enum_punishment_result.classB_written_warning' then
        profile_abolition_date  = Time.zone.parse(punishment_params.as_json['punishment_date']) + 12.month
      when 'punishment.enum_punishment_result.final_written_warning' then
        profile_abolition_date  = Time.zone.parse(punishment_params.as_json['punishment_date']) + 24.month
    end
    if @punishment.update(punishment_params.as_json.merge(
            punishment_status: 'punishment.enum_punishment_status.punished',
            profile_abolition_date: profile_abolition_date,
            tracker_id: current_user.id,
            track_date: Time.zone.now ) )
      @punishment.create_approval_items(params[:approval_items])
      @punishment.create_attend_attachments(params[:attend_attachments], current_user)

      # if profile_abolition_date && Time.zone.now.to_datetime > profile_abolition_date
      # end

      relation_group_users = Role.find_by(key: 'relation_group')&.users
      employee = User.find_by(id: @punishment.user_id)
      Message.add_notification(@punishment,
                               'punishment_at_abolition_date',
                               relation_group_users.pluck(:id).uniq,
                               { employee: employee }) unless (relation_group_users.nil? || relation_group_users.empty?)

      if punishment_params[:reinstated]
        # 新增职程信息
        user = User.find(@punishment[:user_id])
        user.finish_career_record_for_suspension_investigation(
          career_begin: @punishment.incident_suspended_date,
          career_end: punishment_params[:reinstated_date],
          inputer_id: current_user.id
        )
      end
      response_json @punishment.id
    else
      response_json @punishment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /punishments/1
  def destroy
    authorize Punishment
    @punishment.destroy
    response_json
  end

  # GET /punishments/field_options
  def field_options
    response_json Punishment.field_options
  end

  # GET /punishments/profile_index
  def profile_index

    authorize Punishment unless  entry_from_mine?

    query = Punishment
                .includes(:tracker)
                .where(user_id: params[:user_id])
                .where(records_in_where: 'profile')
                .order('punishment_date' => :desc)
    # 當前處分扣分
    current_profile_penalty_score = query
                                        .where(profile_punishment_status: 'in_effect')
                                        .where(punishment_result: ['classA_written_warning','classB_written_warning'])
                                        .sum('profile_penalty_score')
    # 當前處分狀態
    current_profile_punishment_status = I18n.t('punishment.current_punishment_status.no_punishment')
    unless query
           .where(profile_punishment_status: 'in_effect')
           .where(punishment_result: ['classA_written_warning','classB_written_warning','final_written_warning'])
           .empty?
      current_profile_punishment_status = I18n.t('punishment.current_punishment_status.in_effect')
    end
    # 當前效力廢止日期
    current_profile_abolition_date = nil
    unless query
               .where(profile_punishment_status: 'in_effect')
               .where(punishment_result: ['classA_written_warning','classB_written_warning','final_written_warning'])
               .empty?
      current_profile_abolition_date = query
                                           .where(profile_punishment_status: 'in_effect')
                                           .where(punishment_result: ['classA_written_warning','classB_written_warning','final_written_warning'])
                                           .order('profile_abolition_date' => :desc)
                                           .first['profile_abolition_date']
    end
    # 多语言
    data = query.map do |punishment|
      punishment.dealing_with_language
    end
    response_json({
                      data: data.as_json,
                      current_profile_penalty_score: current_profile_penalty_score,
                      current_profile_punishment_status: current_profile_punishment_status,
                      current_profile_abolition_date: current_profile_abolition_date })
  end

  # POST /punishments/profile_create
  def profile_create
    profile_validity_period = nil
    profile_penalty_score   = nil
    profile_abolition_date  = nil
    case punishment_params.as_json['punishment_result']
      when 'punishment.enum_punishment_result.verbal_warning' then
        profile_validity_period = nil
        profile_penalty_score   = 0
        profile_abolition_date  = nil
      when 'punishment.enum_punishment_result.classA_written_warning' then
        profile_validity_period = 6
        profile_penalty_score   = 2
        profile_abolition_date  = Time.zone.parse(punishment_params.as_json['punishment_date']) + 6.month
      when 'punishment.enum_punishment_result.classB_written_warning' then
        profile_validity_period = 12
        profile_penalty_score   = 4
        profile_abolition_date  = Time.zone.parse(punishment_params.as_json['punishment_date']) + 12.month
      when 'punishment.enum_punishment_result.final_written_warning' then
        profile_validity_period = 24
        profile_penalty_score   = nil
        profile_abolition_date  = Time.zone.parse(punishment_params.as_json['punishment_date']) + 24.month
    end
    punishment = Punishment.create(punishment_params.as_json.merge(
        records_in_where: 'profile',
        profile_validity_period: profile_validity_period,
        profile_penalty_score: profile_penalty_score,
        profile_abolition_date: profile_abolition_date,
        tracker_id: current_user.id,
        track_date: Time.zone.now ) )
    response_json punishment
  end

  # GET /punishments/profile_show
  def profile_show
    if @punishment
      response_json @punishment.as_json(include: :tracker)
    else
      response_json [], status: :unprocessable_entity
    end
  end

  # PATCH /punishments/profile_update
  def profile_update
    profile_validity_period = @punishment.profile_validity_period
    profile_penalty_score   = @punishment.profile_penalty_score
    if punishment_params.as_json['punishment_result']
      case punishment_params.as_json['punishment_result']
        when 'punishment.enum_punishment_result.verbal_warning' then
          profile_validity_period = nil
          profile_penalty_score   = 0
        when 'punishment.enum_punishment_result.classA_written_warning' then
          profile_validity_period = 6
          profile_penalty_score   = 2
        when 'punishment.enum_punishment_result.classB_written_warning' then
          profile_validity_period = 12
          profile_penalty_score   = 4
        when 'punishment.enum_punishment_result.final_written_warning' then
          profile_validity_period = 24
          profile_penalty_score   = nil
      end
    end
    if @punishment.update(punishment_params.as_json.merge(
        profile_validity_period: profile_validity_period,
        profile_penalty_score: profile_penalty_score ))
      response_json @punishment
    else
      response_json @punishment.errors, status: :unprocessable_entity
    end
  end

  private
    def create_career_record(user)
      new_row = params[:new_career_record].permit(career_required_array + career_permitted_array)
      new_row = new_row.merge inputer_id: current_user.id, user_id: user.id, deployment_type: 'through_the_transfer_probation_period'
      CareerRecord.create!(new_row)
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_punishment
      @punishment = Punishment.detail_by_id params[:id]
      @user_profile = User.find(@punishment['user_id']).profile
    end

    def set_profile_punishment
      @punishment = Punishment.includes(:tracker).find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def punishment_params
      params.require(:punishment).permit(*Punishment.create_params)
    end



    def search_query
      query = Punishment
                  .includes(user: [:department, :position])
                  .includes(:tracker)
                  .where(records_in_where: 'not_profile')
      {
          punishment_status:   :by_punishment_status,
          employee_no:         :by_users_employee_no,
          department_id:       :by_users_department_id,
          position_id:         :by_users_position_id,
          punishment_result:   :by_punishment_result,
      }.each do |key, value|
        query = query.send(value, params[key]) if params[key]
      end

      if params[:employee_name]
        if params[:employee_name] =~ /^[A-Za-z]/
          query = query.where(users: {english_name: params[:employee_name]})
        else
          query = query.where(users: {chinese_name: params[:employee_name]})
        end
      end

      if params[:punishment_date]
        if params[:punishment_date][:begin].present? && params[:punishment_date][:end].present?
          query = query.where(punishment_date: Time.zone.parse(params[:punishment_date][:begin])..Time.zone.parse(params[:punishment_date][:end]))
        elsif params[:punishment_date][:begin].present? && params[:punishment_date][:end].blank?
          query = query.where("punishment_date >= ?", Time.zone.parse(params[:punishment_date][:begin]))
        elsif params[:punishment_date][:begin].blank? && params[:punishment_date][:end].present?
          query = query.where("punishment_date <= ?", Time.zone.parse(params[:punishment_date][:end]))
        end
      end

      if params[:punishment_category]
        params_category = params[:punishment_category].split(',')
        ids = []
        query.each do |query_record|
          if query_record.punishment_category.present?
            flag = true
            params_category.each do |params_record|
              unless query_record.punishment_category.include?(params_record)
                flag = false
              end
            end
            ids += [query_record.id] if flag
          end
        end
        query = query.where(id: ids)
      end
      query
    end

end
