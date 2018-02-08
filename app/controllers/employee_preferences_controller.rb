class EmployeePreferencesController < ApplicationController
  before_action :set_roster_preference, only: [:index]

  before_action :set_employee_preference, only: [:set_employee_roster_preferences,
                                                 :set_employee_general_holiday_preferences]

  def index
    params[:page] ||= 1
    meta = {}
    all_result = search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    final_result = format_result(result.as_json(include: {
                                                  employee_roster_preferences: {},
                                                  employee_general_holiday_preferences: {}
                                                }, methods: []))

    response_json final_result, meta: meta
  end

  def set_employee_roster_preferences
    ActiveRecord::Base.transaction do
      if params[:employee_roster_preferences]
        @employee_preference.employee_roster_preferences.each do |p|
          update_params = params[:employee_roster_preferences].find { |item| item[:id].to_i == p.id }
          if update_params == nil
            p.destroy
          else
            p.update(update_params.permit(
                       :user_id,
                       :employee_preference_id,
                       :date_range,
                     ))

            p.class_setting_group = update_params[:class_setting_group]
            start_date, end_date = update_params[:date_range].split('~')
            p.start_date = start_date
            p.end_date = end_date
            p.save
          end
        end

        params[:employee_roster_preferences].each do |item|
          exist = @employee_preference.employee_roster_preferences.where(id: item['id'].to_i).first
          if exist == nil
            p = @employee_preference.employee_roster_preferences.create(item.permit(
                                                                          :user_id,
                                                                          :employee_preference_id,
                                                                          :date_range,
                                                                        ))

            p.class_setting_group = item[:class_setting_group]
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

  def set_employee_general_holiday_preferences
    ActiveRecord::Base.transaction do
      if params[:employee_general_holiday_preferences]
        @employee_preference.employee_general_holiday_preferences.each do |p|
          update_params = params[:employee_general_holiday_preferences].find { |item| item[:id].to_i == p.id }
          if update_params == nil
            p.destroy
          else
            p.update(update_params.permit(
                       :user_id,
                       :employee_preference_id,
                       :date_range,
                     ))

            p.day_group = update_params[:day_group]
            start_date, end_date = update_params[:date_range].split('~')
            p.start_date = start_date
            p.end_date = end_date
            p.save
          end
        end

        params[:employee_general_holiday_preferences].each do |item|
          exist = @employee_preference.employee_general_holiday_preferences.where(id: item['id'].to_i).first
          if exist == nil
            p = @employee_preference.employee_general_holiday_preferences.create(item.permit(
                                                                                   :user_id,
                                                                                   :employee_preference_id,
                                                                                   :date_range,
                                                                                 ))

            p.day_group = item[:day_group]
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

  private

  def set_roster_preference
    @roster_preference = RosterPreference.find(params[:roster_preference_id])
  end

  def set_employee_preference
    @employee_preference = EmployeePreference.find(params[:id])
  end

  def search_query
    tag = false
    # region = params[:region] || 'macau'
    # lang_key = params[:lang] || 'zh-TW'

    # lang = if lang_key == 'zh-TW'
    #          'chinese_name'
    #        elsif lang_key == 'zh-US'
    #          'english_name'
    #        else
    #          'simple_chinese_name'
    #        end

    employee_preferences = @roster_preference.employee_preferences
                             .by_user_name(params[:employee])
                             .by_empoid(params[:empoid])
                             .by_department(params[:department])
                             .by_position(params[:position])
                             .by_date_of_employment(params[:date_of_employment])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      if params[:sort_column] == 'department' || params[:sort_column] == 'position'
        employee_preferences = employee_preferences.includes(:user).order("users.#{params[:sort_column]}_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'empoid'
        employee_preferences = employee_preferences.includes(:user).order("users.empoid #{params[:sort_direction]}")
      elsif params[:sort_column] == 'employee'
        employee_preferences = employee_preferences.order("user_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'date_of_employment'
        employee_preferences = employee_preferences.includes(user: :profile).order("profiles.data -> 'position_information' -> 'field_values' -> 'date_of_employment' #{params[:sort_direction]}")
      else
        employee_preferences = employee_preferences.order("#{params[:sort_column]} #{params[:sort_direction]}")
      end
      tag = true
    end

    employee_preferences = employee_preferences.includes(:user).order("users.empoid asc") if tag == false

    employee_preferences
  end

  def format_result(json)
    json.map do |hash|
      employee = hash['user_id'] ? User.find(hash['user_id']) : nil
      hash['employee'] = employee ?
      {
        id: hash['user_id'],
        chinese_name: employee['chinese_name'],
        english_name: employee['english_name'],
        simple_chinese_name: employee['chinese_name'],
        empoid: employee['empoid'],
        grade: employee['grade'],
        date_of_employment: employee.profile.data['position_information']['field_values']['date_of_employment']
      } : nil


      department = employee ? employee.department : nil
      hash['department'] = department ?
      {
        id: department['id'],
        chinese_name: department['chinese_name'],
        english_name: department['english_name'],
        simple_chinese_name: department['chinese_name']
      } : nil

      position = employee ? employee.position : nil
      hash['position'] = position ?
      {
        id: position['id'],
        chinese_name: position['chinese_name'],
        english_name: position['english_name'],
        simple_chinese_name: position['chinese_name']
      } : nil

      hash
    end
  end
end
