# coding: utf-8
class RosterPreferencesController < ApplicationController
  include GenerateXlsxHelper
  before_action :set_roster_preference, only: [:show, :update]
  before_action :set_employee_preferences, only: [:show]

  def index
    authorize RosterPreference
    RosterPreference.initial_table
    result = RosterPreference.all.map do |p|
      p.as_json(
        include: {
          location: {},
          department: {},
          latest_updater: {}
        }
      ).merge(
        {
          users_count: users_count(p.location_id, p.department_id)
        }
      )
    end

    response_json result.as_json
  end

  def roster_model_state_setting_filter
    result = {}
    # result[:roster_models] = user.roster_model_states.find_by(source_id: nil)&.histories&.order(created_at: :desc)&.first
    result[:roster_models] = RosterModel.all
    result[:departments] = Department.all
    result[:positions] = Position.all
    response_json result.as_json
  end

  def employee_roster_model_state_settings
    authorize RosterPreference
    params[:page] ||= 1
    meta = {}
    all_result = search_query_for_user
    # all_result = User.all.order(empoid: :asc)
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)

    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    final_result = format_user_result(result.as_json(include: [], methods: []))

    response_json final_result, meta: meta
  end

  def employee_roster_model_state_settings_export_xlsx
    authorize RosterPreference
    all_result = search_query_for_user
    final_result = format_user_result(all_result.as_json(include: [], methods: []))
    model_state_settings_export_num = Rails.cache.fetch('model_state_settings_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + model_state_settings_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('model_state_settings_export_number_tag', model_state_settings_export_num+1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'RosterPreferencesController', table_fields_methods: 'get_table_fields', table_fields_args: [], my_attachment: my_attachment)
    render json: my_attachment
  end


  def raw_show
    @roster_preference.remove_dup_general_holiday_settings

    @roster_preference.setting_intervals

    @roster_preference.setting_employee_preferences

    result = @roster_preference.as_json(
      include: {
        location: {},
        department: {},
        latest_updater: {},
        class_people_preferences: {methods: [:class_setting_detail]},
        roster_interval_preferences: {methods: [:position_detail]},
        general_holiday_interval_preferences: {methods: [:position_detail]},
        classes_between_general_holiday_preferences: {methods: [:position_detail]},
      }
    )

    whether_together_preferences = @roster_preference.whether_together_preferences.map do |p|
      group_members_detail = User.where(id: p.group_members).as_json
      p.as_json.merge(
        {
          group_members_detail: group_members_detail
        }
      )
    end

    result[:whether_together_preferences] = whether_together_preferences
    response_json result.as_json
  end

  def show_from_roster_list
    authorize RosterPreference
    raw_show
  end

  def show
    raw_show
  end

  def update
    ActiveRecord::Base.transaction do
      @roster_preference.latest_updater_id = params[:latest_updater_id]
      @roster_preference.save

      if params[:class_people_preferences]
        @roster_preference.class_people_preferences.each do |p|
          update_param = params[:class_people_preferences].find { |item| item[:class_setting_id].to_i == p.class_setting_id.to_i }
          p.update(update_param.permit(
                     :max_of_total,
                     :min_of_total,
                     :max_of_manager_level,
                     :min_of_manager_level,
                     :max_of_director_level,
                     :min_of_director_level
                   ))
        end
      end

      if params[:roster_interval_preferences]
        @roster_preference.roster_interval_preferences.each do |p|
          update_params = params[:roster_interval_preferences].find { |item| item[:position_id].to_i == p.position_id.to_i }
          p.update(update_params.permit(:interval_hours))
        end
      end

      if params[:general_holiday_interval_preferences]
        @roster_preference.general_holiday_interval_preferences.each do |p|
          update_params = params[:general_holiday_interval_preferences].find { |item| item[:position_id].to_i == p.position_id.to_i }
          p.update(update_params.permit(:max_interval_days))
        end
      end

      if params[:classes_between_general_holiday_preferences]
        @roster_preference.classes_between_general_holiday_preferences.each do |p|
          update_params = params[:classes_between_general_holiday_preferences].find { |item| item[:position_id].to_i == p.position_id.to_i }
          p.update(update_params.permit(:max_classes_count))
        end
      end

      if params[:whether_together_preferences]
        @roster_preference.whether_together_preferences.each do |p|
          update_params = params[:whether_together_preferences].find { |item| item[:id].to_i == p.id }
          if update_params == nil
            p.destroy
          else
            p.update(update_params.permit(
                       :group_name,
                       :date_range,
                       :comment,
                       :is_together
                     ))

            p.group_members = update_params[:group_members]
            start_date, end_date = update_params[:date_range].split('~')
            p.start_date = start_date
            p.end_date = end_date
            p.save
          end
        end

        params[:whether_together_preferences].each do |item|
          exist = @roster_preference.whether_together_preferences.where(id: item['id'].to_i).first
          if exist == nil
            p = @roster_preference.whether_together_preferences.create(item.permit(
                                                                         :group_name,
                                                                         :date_range,
                                                                         :comment,
                                                                         :is_together
                                                                       ))
            p.group_members = item[:group_members]
            start_date, end_date = item[:date_range].split('~')
            p.start_date = start_date
            p.end_date = end_date
            p.save
          end
        end
      end

      response_json :ok
    end
  end

  def patch_intervals
    ActiveRecord::Base.transaction do
      RosterPreference.all.each do |p|
        # position_ids = User.where(location_id: p.location_id, department_id: p.department_id).pluck(:position_id).compact.uniq
        # positions = Position.where(id: position_ids)

        positions = Position.joins(:departments, :locations).where('departments.id = ? AND locations.id = ?', p.department_id, p.location_id)

        positions.each do |position|
          if p.roster_interval_preferences.where(position_id: position.id).count == 0
            p.roster_interval_preferences.create(position_id: position.id, interval_hours: 0)
          end

          if p.general_holiday_interval_preferences.where(position_id: position.id).count == 0
            p.general_holiday_interval_preferences.create(position_id: position.id)
          end

          if p.classes_between_general_holiday_preferences.where(position_id: position.id).count == 0
            p.classes_between_general_holiday_preferences.create(position_id: position.id)
          end
        end
      end
      response_json :ok
    end
  end

  def destroy_all_intervals
    ActiveRecord::Base.transaction do
      RosterPreference.all.each do |p|
        p.roster_interval_preferences.each { |i| i.destroy }
        p.general_holiday_interval_preferences.each { |i| i.destroy }
        p.classes_between_general_holiday_preferences.each { |i| i.destroy }
      end
      response_json :ok
    end
  end

  private

  def set_roster_preference
    @roster_preference = RosterPreference.find(params[:id])
  end

  def users_count(location_id, department_id)
    User.where(location_id: location_id, department_id: department_id).count
  end

  def set_employee_preferences
    roster_preference = RosterPreference.find(params[:id])
    EmployeePreference.setting_users(roster_preference)
  end

  def search_query_for_user
    tag = false

    user_query = User.all

    user_query = params[:empoid] ? user_query.where("empoid like ?", "%#{params[:empoid]}%") : user_query
    user_query = params[:user] ? user_query.where("#{select_language.to_s} like ?", "%#{params[:user]}%") : user_query
    user_query = params[:department] ? user_query.where(department_id: params[:department]) : user_query
    user_query = params[:position] ? user_query.where(position_id: params[:position]) : user_query

    if params[:date_of_employment]
      ids = []
      range = params[:date_of_employment][:begin].in_time_zone.to_date .. params[:date_of_employment][:end].in_time_zone.to_date
      user_query.each do |user|
        if range.include?(user.profile.data['position_information']['field_values']['date_of_employment']&.in_time_zone&.to_date)
          ids += [user.id]
        end
      end
      user_query = user_query.where(id: ids)
    end

    if params[:roster_model]
      roster_models = params[:roster_model].map(& :to_i)
      ids = []
      user_query.each do |user|
        # rms = user.roster_model_states.find_by(source_id: nil)&.histories&.order(created_at: :desc)&.first
        rms = user.roster_model_states.where(source_id: nil).by_in_service(params[:query_date]).order(created_at: :desc)&.first
        if roster_models.include?(rms&.roster_model_id)
          ids += [user.id]
        end
      end
      user_query = user_query.where(id: ids)
    end

    if params[:effective_date]
      ids = []
      range = params[:effective_date][:begin].in_time_zone.to_date .. params[:effective_date][:end].in_time_zone.to_date
      user_query.each do |user|
        # rms = user.roster_model_states.find_by(source_id: nil)&.histories&.order(created_at: :desc)&.first
        rms = user.roster_model_states.where(source_id: nil).by_in_service(params[:query_date]).order(created_at: :desc)&.first
        if range.include?(rms&.start_date&.in_time_zone&.to_date)
          ids += [user.id]
        end
      end
      user_query = user_query.where(id: ids)
    end

    if params[:start_week_no]
      ids = []
      user_query.each do |user|
        # rms = user.roster_model_states.find_by(source_id: nil)&.histories&.order(created_at: :desc)&.first
        rms = user.roster_model_states.where(source_id: nil).by_in_service(params[:query_date]).order(created_at: :desc)&.first
        if params[:start_week_no].to_i == rms&.start_week_no
          ids += [user.id]
        end
      end
      user_query = user_query.where(id: ids)
    end

    if params[:current_week_no]
      ids = []
      user_query.each do |user|
        # rms = user.roster_model_states.find_by(source_id: nil)&.histories&.order(created_at: :desc)&.first
        rms = user.roster_model_states.where(source_id: nil).by_in_service(params[:query_date]).order(created_at: :desc)&.first
        if params[:current_week_no].to_i == rms&.current_week_no
          ids += [user.id]
        end
      end
      user_query = user_query.where(id: ids)
    end

    query_date = Time.zone.parse(params[:query_date]) rescue nil

    if query_date &&  params[:current_week_no_for_query_date]
      ids = []
      user_query.each do |user|
        rms = user.roster_model_states.by_in_service(params[:query_date]).order(created_at: :desc)&.first
        if params[:current_week_no_for_query_date].to_i == rms&.current_week_no_for_query_date(query_date)
          ids += [user.id]
        end
      end
      user_query = user_query.where(id: ids)
    elsif query_date
      ids = []
      user_query.each do |user|
        rms = user.roster_model_states.by_in_service(params[:query_date]).order(created_at: :desc)&.first
        ids += [rms.user_id] if rms&.user_id
      end
      user_query = user_query.where(id: ids)
    end

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      default_order = "empoid ASC"
      default_order_with_self = "users.empoid DESC"

      params[:query_date] ||= Time.zone.now.to_date

      if params[:sort_column] == 'empoid'
        user_query = user_query.order("empoid #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'user'
        user_query = user_query.order("id #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'department' || params[:sort_column] == 'position'
        column = "#{params[:sort_column]}_id"
        user_query = user_query.order("#{column} #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'date_of_employment'
        user_query = user_query.includes(:profile).order("profiles.data -> 'position_information' -> 'field_values' -> 'date_of_employment' #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'roster_model'
        user_query = user_query.includes(:roster_model_states).where("roster_model_states.start_date <= ?", params[:query_date]).where("roster_model_states.end_date = ? OR roster_model_states.end_date >= ?", nil, params[:query_date]).order("roster_model_states.roster_model_id #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'effective_date'
        user_query = user_query.includes(:roster_model_states).where("roster_model_states.start_date <= ?", params[:query_date]).where("roster_model_states.end_date = ? OR roster_model_states.end_date >= ?", nil, params[:query_date]).order("roster_model_states.start_date #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'start_week_no'
        user_query = user_query.includes(:roster_model_states).where("roster_model_states.start_date <= ?", params[:query_date]).where("roster_model_states.end_date = ? OR roster_model_states.end_date >= ?", nil, params[:query_date]).order("roster_model_states.start_week_no #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'current_week_no'
        user_query = user_query.includes(:roster_model_states).where("roster_model_states.start_date <= ?", params[:query_date]).where("roster_model_states.end_date = ? OR roster_model_states.end_date >= ?", nil, params[:query_date]).order("roster_model_states.current_week_no #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'current_week_no_for_query_date'
        #todo(jinxin) 排序延後
        #user_query = user_query.includes(:roster_model_states).where("roster_model_states.effective_date <= ?", params[:query_date]).where("roster_model_states.end_date = ? OR roster_model_states.end_date >=", nil, params[:query_date]).order("roster_model_states.current_week_no #{params[:sort_direction]}", default_order_with_self)
      else
        user_query= user_query.order("#{params[:sort_column]} #{params[:sort_direction]}", default_order)
      end
      tag = true
    end

    user_query = user_query.order(empoid: :asc) if tag == false
    user_query
  end

  def format_user_result(json)
    json.map do |hash|
      user = User.find_by(id: hash['id'])
      hash['date_of_employment'] = user ? user.profile.data['position_information']['field_values']['date_of_employment'] : nil
      roster_model_state = RosterModelState.where(user_id: user['id']).by_in_service(params[:query_date]).order(created_at: :desc).first
      hash['current_state'] = if roster_model_state
                                query_date = Time.zone.parse(params[:query_date]) rescue  nil
                                if query_date
                                  current_week_no_for_query_date = roster_model_state&.current_week_no_for_query_date(query_date)
                                  roster_model_state.as_json(include: :roster_model).merge(current_week_no_for_query_date: current_week_no_for_query_date )
                                else
                                  roster_model_state.as_json(include: :roster_model)
                                end
                              else
                                nil
                              end
      department = hash['department_id'] ? Department.find_by(id: hash['department_id']) : nil
      hash['department'] = department ?
      {
        id: hash['department_id'],
        chinese_name: department['chinese_name'],
        english_name: department['english_name'],
        simple_chinese_name: department['simple_chinese_name'],
      } : nil

      position = hash['position_id'] ? Position.find_by(id: hash['position_id']) : nil
      hash['position'] = position ?
      {
        id: hash['position_id'],
        chinese_name: position['chinese_name'],
        english_name: position['english_name'],
        simple_chinese_name: position['simple_chinese_name'],
      } : nil

      hash
    end
  end

  def self.get_table_fields
    empoid = {
      chinese_name: '員工編號',
      english_name: 'empoid',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        # rst["user"] ? rst["user"][:empoid].rjust(8, '0') : 0
        "\s#{rst["empoid"]}"
      }
    }

    name = {
      chinese_name: '員工姓名',
      english_name: 'Name',
      simple_chinese_name: '员工姓名',
      get_value: -> (rst, options){
        rst[options[:name_key].to_s]
      }
    }

    department = {
      chinese_name: '部門',
      english_name: 'Department',
      simple_chinese_name: '部门',
      get_value: -> (rst, options){
        rst['department'] ? rst['department'][options[:name_key]] : ''
      }
    }

    position = {
      chinese_name: '職位',
      english_name: 'Position',
      simple_chinese_name: '职位',
      get_value: -> (rst, options){
        rst['position'] ? rst['position'][options[:name_key]] : ''
      }
    }

    entry_date = {
      chinese_name: '入職日期',
      english_name: 'Entry date',
      simple_chinese_name: '入职日期',
      get_value: -> (rst, options){
        rst['date_of_employment'] ? rst['date_of_employment'] : ''
      }
    }

    roster_model = {
      chinese_name: '使用更模',
      english_name: 'Roster Model',
      simple_chinese_name: '使用更模',
      get_value: -> (rst, options){
        (rst['current_state'] && rst['current_state']['roster_model']) ? rst['current_state']['roster_model']['chinese_name']: ''
      }
    }

    effective_date = {
      chinese_name: '更模生效日期',
      english_name: 'Effective Date',
      simple_chinese_name: '更模生效日期',
      get_value: -> (rst, options){
        rst['current_state'] ? rst['current_state']['effective_date']: ''
      }
    }

    start_week_no = {
      chinese_name: '更模開始星期',
      english_name: 'Start Week No',
      simple_chinese_name: '更模开始星期',
      get_value: -> (rst, options){
        rst['current_state'] ? rst['current_state']['start_week_no']: ''
      }
    }

    current_week_no = {
      chinese_name: '目前更模星期',
      english_name: 'Current Week No',
      simple_chinese_name: '目前更模星期',
      get_value: -> (rst, options){
        rst['current_state'] ? rst['current_state']['current_week_no']: ''
      }
    }

    [empoid, name, department, position, entry_date,
                    roster_model, effective_date, start_week_no, current_week_no]
  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '按員工排班設定'
    elsif select_language.to_s == 'english_name'
      'For Employee Settings'
    else
      '按员工排班设定'
    end
  end
end
