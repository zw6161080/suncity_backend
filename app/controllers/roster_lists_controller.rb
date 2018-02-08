# coding: utf-8
class RosterListsController < ApplicationController
  include GenerateXlsxHelper
  before_action :set_roster_list, only: [:show, :destroy, :to_draft, :to_public, :to_sealed, :roster_objects, :object_batch_update, :filter_options, :roster_objects_export_xlsx]
  before_action :set_employee_preferences, only: [:show]
  # before_action :set_users, only: [:show]

  def index
    authorize RosterList
    params[:page] ||= 1
    meta = {}
    # RosterList.all.each { |r| r.fill_in_data }
    all_result = search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)

    # meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page
    # result.each { |r| r.fill_in_data }

    final_result = format_result(result.as_json(include: [], methods: []))

    response_json final_result, meta: meta
  end

  def show
    authorize RosterList
    @roster_list.fill_in_data
    result = @roster_list.as_json(
      include: {
        location: {},
        department: {},
      },
      methods: [:roster_preferences_id]
    )
    response_json result
  end

  def roster_objects
    # all_roster_objects = @roster_list.roster_objects
    all_roster_objects = RosterObject
                           .where(location_id: @roster_list.location_id,
                                  department_id: @roster_list.department_id)
                           .by_date(@roster_list.start_date, @roster_list.end_date)

    # user_ids = User.where(location_id: @roster_list.location_id, department_id: @roster_list.department_id).pluck(:id)
    u_ids = all_roster_objects.pluck(:user_id)
    # u_ids = @roster_list.roster_list_users.pluck(:id)
    user_ids = u_ids - [2, 120] # rm admin user ids
    result, meta = return_response_roster_objects(params[:page], all_roster_objects, user_ids, @roster_list.start_date, @roster_list.end_date, @roster_list.location_id, @roster_list.department_id)
    response_json result.as_json, meta: meta
  end

  def import_xlsx
    # authorize RosterList
    file = params[:file]
    location_id = params[:location_id]
    department_id = params[:department_id]

    roster_table_xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    code_regexp = /^\d+$/

    # working_time_regexp = /\p{Han}{0,2}\s*\d{2}:\d{2}\s*-\s*\p{Han}{0,2}\s*\d{2}:\d{2}/u

    # 2200 - 2300
    working_time_regexp_0 = /\s*\d{4}\s*-\s*\s*\d{4}/

    # 2200 - 次日 2300
    working_time_regexp_1 = /\s*\d{4}\s*-\s*\p{Han}{2}\s*\d{4}/

    # 次日 2200 - 次日 2300
    working_time_regexp_2 = /\p{Han}{2}\s*\d{4}\s*-\s*\p{Han}{2}\s*\d{4}/


    wht_regexp = /\p{Han}{0,2}\s*\d{2}:\d{2}\s*-\s*\p{Han}{0,2}\s*\d{2}:\d{2}\s+\p{Han}{0,2}\s*\d{2}:\d{2}\s*-\s*\p{Han}{0,2}\s*\d{2}:\d{2}/

    holiday_regexp = /^\p{Han}+$/

    result = {}

    empoid_regexp = /員工編號|员工编号|empoid/

    header = roster_table_xlsx.sheet(roster_table_xlsx.sheets.first).row(1).map do |c|
      if c.class == String && match_p = empoid_regexp.match(c)
        match_p[0]
      else
        c
      end
    end

    date_columns = header.select { |column| column.class == Date }
    (2..roster_table_xlsx.last_row).each do |i|
      row = Hash[[header, roster_table_xlsx.row(i)].transpose]
      row_user = User.find_by(empoid: row["員工編號"].to_s.rjust(8, '0'))

      if row_user
        date_columns.each do |d|
          # content = "#{row[d]}"
          content = row[d].to_s.strip

          ro = RosterObject.where(user_id: row_user.id,
                                  roster_date: d,
                                  location_id: location_id,
                                  department_id: department_id).first
          if ro == nil
            ro = RosterObject.create(user_id: row_user.id,
                                     location_id: location_id,
                                     department_id: department_id,
                                     roster_date: d)
          end

          date_of_employment = row_user.profile.data['position_information']['field_values']['date_of_employment']
          entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

          position_resigned_date = row_user.profile.data['position_information']['field_values']['resigned_date']
          leave = position_resigned_date ? position_resigned_date.in_time_zone.to_date : nil

          if (ro.is_active == 'active' || ro.is_active == nil) &&
             (d >= entry) &&
             (leave == nil || d < leave)

            att = Attend.find_attend_by_user_and_date(row_user.id, d)
            if att == nil
              Attend.create(user_id: row_user.id,
                            attend_date: d.in_time_zone,
                            attend_weekday: d.in_time_zone.wday,
                            roster_object_id: ro.id,
                           )
            else
              att.roster_object_id = ro.id
              att.save!
            end

            # update roster_object

            if record_1 = AdjustRosterRecord.where(user_a_id: row_user.id, user_a_adjust_date: d, is_deleted: [false, nil]).first ||
                          record_2 = AdjustRosterRecord.where(user_b_id: row_user.id, user_b_adjust_date: d, is_deleted: [false, nil]).first
              if record_1
                if record_1.apply_type == 'for_class'
                  result[:has_adjust_class_group] = result[:has_adjust_class_group] ? (result[:has_adjust_class_group] << { user: row_user, date: d }).uniq : [{ user: row_user, date: d }]
                elsif record_1.apply_type == 'for_holiday'
                  result[:has_adjust_holiday_group] = result[:has_adjust_holiday_group] ? (result[:has_adjust_holiday_group] << { user: row_user, date: d }).uniq : [{ user: row_user, date: d }]
                end
              end

              if record_2
                if record_2.apply_type == 'for_class'
                  result[:has_adjust_class_group] = result[:has_adjust_class_group] ? (result[:has_adjust_class_group] << { user: row_user, date: d }).uniq : [{ user: row_user, date: d }]
                elsif record_2.apply_type == 'for_holiday'
                  result[:has_adjust_holiday_group] = result[:has_adjust_holiday_group] ? (result[:has_adjust_holiday_group] << { user: row_user, date: d }).uniq : [{ user: row_user, date: d }]
                end
              end
            end

            if record_1 = WorkingHoursTransactionRecord.where(user_a_id: row_user.id, source_id: nil, apply_date: d, is_deleted: [false, nil]).first ||
                          record_2 = WorkingHoursTransactionRecord.where(user_b_id: row_user.id, source_id: nil, apply_date: d, is_deleted: [false, nil]).first
              if record_1
                if record_1.apply_type == 'borrow_hours'
                  result[:has_wht_borrow_group] = result[:has_wht_borrow_group] ? (result[:has_wht_borrow_group] << { user: row_user, date: d }).uniq : [{ user: row_user, date: d }]
                elsif record_1.apply_type == 'return_hours'
                  result[:has_wht_return_group] = result[:has_wht_return_group] ? (result[:has_wht_return_group] << { user: row_user, date: d }).uniq : [{ user: row_user, date: d }]
                end
              end

              if record_2
                if record_2.apply_type == 'borrow_hours'
                  result[:has_wht_borrow_group] = result[:has_wht_borrow_group] ? (result[:has_wht_borrow_group] << { user: row_user, date: d }).uniq : [{ user: row_user, date: d }]
                elsif record_2.apply_type == 'return_hours'
                  result[:has_wht_return_group] = result[:has_wht_return_group] ? (result[:has_wht_return_group] << { user: row_user, date: d }).uniq : [{ user: row_user, date: d }]
                end
              end
            end


            if HolidayRecord.where(user_id: row_user.id, source_id: nil, is_deleted: [false, nil]).where("start_date <= ? AND end_date >= ?", d, d).count > 0
              result[:has_holiday_record_group] = result[:has_holiday_record_group] ? (result[:has_holiday_record_group] << { user: row_user, date: d }).uniq : [{ user: row_user, date: d }]
            end

            if ro.holiday_type == nil && ro.borrow_return_type == nil && ro.adjust_type == nil
              # if code_regexp.match(content)
              if working_time_regexp_0.match(content) # xxxx-xxxx
                st = content.split('-').first
                ed = content.split('-').second
                fmt_st = RosterObject.fmt_colon(st)
                fmt_ed = RosterObject.fmt_colon(ed)
                w_time= [fmt_st, fmt_ed].join('-')
                ro.working_time = w_time
                ro.class_setting_id = nil
                ro.is_general_holiday = nil
                ro.save
                RosterObject.update_attend_and_states(ro)
              elsif working_time_regexp_2.match(content) # 次日 xxxx-次日 xxxx
                st = content.split('-').first
                ed = content.split('-').second
                fmt_st = RosterObject.fmt_time_with_next(st)
                fmt_ed = RosterObject.fmt_time_with_next(ed)
                w_time = [fmt_st, fmt_ed].join('-')
                ro.working_time = w_time
                ro.class_setting_id = nil
                ro.is_general_holiday = nil
                ro.save
                RosterObject.update_attend_and_states(ro)
              elsif working_time_regexp_1.match(content) # xxxx-次日 xxxx
                st = content.split('-').first
                ed = content.split('-').second
                fmt_st = RosterObject.fmt_colon(st)
                fmt_ed = RosterObject.fmt_time_with_next(ed)
                w_time = [fmt_st, fmt_ed].join('-')
                ro.working_time = w_time
                ro.class_setting_id = nil
                ro.is_general_holiday = nil
                ro.save
                RosterObject.update_attend_and_states(ro)
              elsif content == '公休' || content == 'General Holiday'
                ro.is_general_holiday = true
                ro.working_time = nil
                ro.class_setting_id = nil
                ro.save
                RosterObject.update_attend_and_states(ro)
              # elsif wht_regexp.match(content)
              #   result[:import_wht_group] = result[:import_wht_group] ? result[:import_wht_group] << { user: row_user, date: d } : [{ user: row_user, date: d }]
              #   response_json result.as_json
              # elsif holiday_regexp.match(content) && content != '公休' && content != 'General Holiday'
              #   result[:import_holiday_group] = result[:import_holiday_group] ? result[:import_holiday_group] << { user: row_user, date: d } : [{ user: row_user, date: d }]
              #   response_json result.as_json
              # elsif code_regexp.match(content)
              # class_setting = ClassSetting.find_by(code: content)
              # byebug
              # if class_setting
              #   ro.class_setting_id = class_setting.id
              #   ro.is_general_holiday = nil
              #   ro.working_time = nil
              #   ro.save
              #   RosterObject.update_attend_and_states(ro)
              # else
              #   result[:import_error_group] = result[:import_error_group] ? (result[:import_error_group] << { user: row_user, date: d }).uniq : [{ user: row_user, date: d }]
              # end
              elsif content != ''
                class_setting = ClassSetting.find_by(code: content)
                if class_setting
                  ro.class_setting_id = class_setting.id
                  ro.is_general_holiday = nil
                  ro.working_time = nil
                  ro.save
                  RosterObject.update_attend_and_states(ro)
                else
                  result[:import_error_group] = result[:import_error_group] ? (result[:import_error_group] << { user: row_user, date: d }).uniq : [{ user: row_user, date: d }]
                end
                # result[:import_error_group] = result[:import_error_group] ? (result[:import_error_group] << { user: row_user, date: d }).uniq : [{ user: row_user, date: d }]
              end
            end

          end
        end
      end
    end

    response_json result.as_json
  end

  def roster_objects_export_xlsx
    # authorize RosterList
    # all_roster_objects = @roster_list.roster_objects
    all_roster_objects = RosterObject
                           .where(location_id: @roster_list.location_id,
                                  department_id: @roster_list.department_id)
                           .by_date(@roster_list.start_date, @roster_list.end_date)
    # user_ids = User.where(location_id: @roster_list.location_id, department_id: @roster_list.department_id).pluck(:id)
    u_ids = all_roster_objects.pluck(:user_id)
    user_ids = u_ids - [2, 120] # rm admin user ids
    final_result, _ = return_response_roster_objects(params[:page], all_roster_objects, user_ids, @roster_list.start_date, @roster_list.end_date, @roster_list.location_id, @roster_list.department_id)

    language = select_language.to_s
    roster_objects_export_num = Rails.cache.fetch('roster_objects_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + roster_objects_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('roster_objects_export_number_tag', roster_objects_export_num+1)

    start_date = @roster_list.start_date.in_time_zone.to_date.to_s
    end_date = @roster_list.end_date.in_time_zone.to_date.to_s

    is_detail = true
    display_type = params[:display_type]

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_roster_objects_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json), controller_name: 'RosterListsController', table_fields_methods: 'get_table_fields', table_fields_args: [start_date, end_date, is_detail, display_type], my_attachment: my_attachment, sheet_name: 'RosterListTable')
    render json: my_attachment
  end

  def self_roster_objects
    all_roster_objects = RosterObject.
                           where(user_id: params[:user_id])
                           .by_date(params[:start_date], params[:end_date])

    user_ids = [params[:user_id]]
    result, meta = return_response_roster_objects(params[:page], all_roster_objects, user_ids, params[:start_date].in_time_zone.to_date, params[:end_date].in_time_zone.to_date, nil, nil)
    response_json result.as_json, meta: meta
  end

  def department_roster_objects
    authorize RosterList
    # all_roster_objects = RosterObject.where(location_id: params[:location_id],
    #                                         department_id: params[:department_id],
    #                                         roster_date: params[:start_date] .. params[:end_date])

    public_and_sealed_list_ids = RosterList.where("status = ? OR status = ?", 1, 2).pluck(:id)

    all_roster_objects = RosterObject
                           .where(roster_list_id: public_and_sealed_list_ids)
                           .by_location_id(params[:location_id])
                           .by_department_id(params[:department_id])
                           .by_date(params[:start_date], params[:end_date])

    u_ids = User.where(location_id: params[:location_id], department_id: params[:department_id]).pluck(:id)
    user_ids = u_ids - [2, 120] # rm admin user ids
    result, meta = return_response_roster_objects(params[:page], all_roster_objects, user_ids, params[:start_date].in_time_zone.to_date, params[:end_date].in_time_zone.to_date, params[:location_id].to_i, params[:department_id].to_i)
    response_json result.as_json, meta: meta
  end

  def query_roster_objects
    authorize RosterList
    params[:page] ||= 1
    meta = {}

    # status 1 for is_public, status 2 for is_sealed
    public_and_sealed_list_ids = RosterList.where("status = ? OR status = ?", 1, 2).pluck(:id)
    all_roster_objects = RosterObject
                           .where(roster_list_id: public_and_sealed_list_ids)
                           .by_location_id(params[:location_id])
                           .by_department_id(params[:department_id])
                           .by_users(params[:user_ids])
                           .by_date(params[:start_date], params[:end_date])

    user_query = User.where.not(id: [2, 120]) # no admin
    user_query_with_location = params[:location_id] ? user_query.where(location_id: params[:location_id]) : user_query
    user_query_with_department = params[:department_id] ? user_query_with_location.where(department_id: params[:department_id]) : user_query_with_location
    user_result = params[:user_ids] ? user_query_with_department.where(id: params[:user_ids]) : user_query_with_department
    user_result = sort_result(user_result)
    meta['total_count'] = user_result.count
    result = user_result.page(params[:page].to_i).per(20)
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    user_roster_map = all_roster_objects.group_by { |roster_object| roster_object.user_id }
    new_result = format_query_result(result, user_roster_map, params[:start_date].in_time_zone.to_date, params[:end_date].in_time_zone.to_date, nil, nil)

    # result, meta = return_response_roster_objects(params[:page], all_roster_objects)
    response_json new_result.as_json, meta: meta
  end

  def query_roster_objects_export_xlsx
    authorize RosterList
    user_query = User.all
    user_query_with_location = params[:location_id] ? user_query.where(location_id: params[:location_id]) : user_query
    user_query_with_department = params[:department_id] ? user_query_with_location.where(department_id: params[:department_id]) : user_query_with_location
    user_result = params[:user_ids] ? user_query_with_department.where(id: params[:user_ids]) : user_query_with_department
    user_result = sort_result(user_result)

    public_and_sealed_list_ids = RosterList.where("status = ? OR status = ?", 1, 2).pluck(:id)
    all_roster_objects = RosterObject
                           .where(roster_list_id: public_and_sealed_list_ids)
                           .by_location_id(params[:location_id])
                           .by_department_id(params[:department_id])
                           .by_users(params[:user_ids])
                           .by_date(params[:start_date], params[:end_date])
    user_roster_map = all_roster_objects.group_by { |roster_object| roster_object.user_id }
    final_result = format_query_result(user_result, user_roster_map, params[:start_date].in_time_zone.to_date, params[:end_date].in_time_zone.to_date, nil, nil)

    language = select_language.to_s
    roster_objects_query_export_num = Rails.cache.fetch('roster_objects_query_export_number_tag', :expires_in => 24.hours) do
      1
    end

    export_id = ("0000" + roster_objects_query_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('roster_objects_query_export_number_tag', roster_objects_query_export_num+1)

    start_date = params[:start_date].in_time_zone.to_date.to_s
    end_date = params[:end_date].in_time_zone.to_date.to_s
    is_detail = false

    display_type = params[:display_type]

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_roster_objects_query_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'RosterListsController', table_fields_methods: 'get_table_fields', table_fields_args: [start_date, end_date, is_detail, display_type], my_attachment: my_attachment, sheet_name: 'RosterListTable')
    render json: my_attachment
  end

  def fetch_one_roster_object_info
    template = RosterObject.find_by(id: params[:roster_object_id])
    true_info = RosterObject.where(user_id: template&.user_id, roster_date: template&.roster_date, is_active: ['active', nil]).first
    result = true_info ? true_info.as_json(include: [:location, :department, :class_setting]) : nil
    response_json result.as_json
  end

  def holiday_to_general_holiday
    roster_object = RosterObject.find_by(id: params[:roster_object_id])
    roster_object.holiday_type = nil
    roster_object.holiday_record_id = nil
    roster_object.change_to_general_holiday = true
    roster_object.save

    inactive_ro = RosterObject.where(user_id: roster_object.user_id, roster_date: roster_object.roster_date, is_active: 'inactive').first
    if inactive_ro
      inactive_ro.holiday_type = nil
      inactive_ro.holiday_record_id = nil
      inactive_ro.change_to_general_holiday = true
    end

    roster_object.roster_object_logs.create(
      modified_reason: 'dont_calc_holiday',
      approver_id: current_user.id,
      approval_time: Time.zone.now.to_datetime,
      class_setting_id: roster_object.class_setting_id,
      is_general_holiday: roster_object.is_general_holiday,
      working_time: roster_object.working_time,
      holiday_type: roster_object.holiday_type,
      borrow_return_type: roster_object.borrow_return_type,
      working_hours_transaction_record_id: roster_object.working_hours_transaction_record_id,
    )

    holiday_record = HolidayRecord.where(user_id: roster_object.user_id)
                       .where("start_date <= ? AND end_date >= ?", roster_object.roster_date, roster_object.roster_date).first

    if holiday_record
      to_gh_count = holiday_record.change_to_general_holiday_count.to_i
      holiday_record.change_to_general_holiday_count = to_gh_count + 1
      holiday_record.days_count = holiday_record.days_count - 1
      holiday_record.save
    end

    response_json :ok
  end

  def fetch_roster_object
    roster_date = params[:roster_date] ? params[:roster_date].in_time_zone.to_date : nil
    public_and_sealed_list_ids = RosterList.where("status = ? OR status = ?", 1, 2).pluck(:id)

    roster_object = RosterObject
                      .where(roster_list_id: public_and_sealed_list_ids,
                             user_id: params[:user_id],
                             roster_date: roster_date).first
    result = roster_object ? roster_object.as_json(include: [:class_setting]) : nil
    response_json result.as_json
  end

  def fetch_roster_objects_of_week
    user = User.find_by(id: params[:user_id])
    day = params[:day].in_time_zone.to_date

    public_and_sealed_list_ids = RosterList.where("status = ? OR status = ?", 1, 2).pluck(:id).uniq
    user_roster_objects = RosterObject.where(user_id: user.id, roster_list_id: public_and_sealed_list_ids)
    roster_objects = format_objects_for_week(user_roster_objects.by_week(day.to_s), day)

    result = {
      roster_objects: roster_objects,
      class_settings: ClassSetting.where(id: user_roster_objects.pluck('class_setting_id').compact.uniq),
    }

    response_json result.as_json
  end


  def object_batch_update
    authorize RosterList
    ActiveRecord::Base.transaction do
      attendance_group_users = Role.find_by(key: 'attendance_group')&.users
      attendance_group_user_ids = attendance_group_users.empty? ? [] : attendance_group_users.pluck(:id).uniq

      ro_dates = []
      roster_objects_params[:roster_objects].each do |ro|
        roster_object = RosterObject.find_by(id: ro['id'])
        ro_class_setting_id = ro['class_setting_id'] == 'null' ? nil : ro['class_setting_id']
        if roster_object
          if (roster_object.is_active == nil || roster_object.is_active == 'active') &&
             roster_object.holiday_type == nil &&
             roster_object.borrow_return_type == nil &&
             roster_object.adjust_type == nil

            roster_object.update(class_setting_id: ro_class_setting_id,
                                 is_general_holiday: ro['is_general_holiday'],
                                 working_time: ro['working_time'])

            inactive_ro = RosterObject.where(user_id: roster_object.user_id, roster_date: roster_object.roster_date, is_active: 'inactive').first
            if inactive_ro
              inactive_ro.class_setting_id = ro_class_setting_id
              inactive_ro.is_general_holiday = ro['is_general_holiday']
              inactive_ro.working_time = ro['working_time']
              inactive_ro.save
            end
          else
            roster_object = nil
          end
        else
          roster_object = @roster_list.roster_objects.create(class_setting_id: ro_class_setting_id,
                                                             is_general_holiday: ro['is_general_holiday'],
                                                             working_time: ro['working_time'],
                                                             location_id: @roster_list.location_id,
                                                             department_id: @roster_list.department_id,
                                                             roster_date: ro['roster_date'] ? ro['roster_date'].in_time_zone.to_date : nil,
                                                             user_id: ro['user_id'])
        end

        if roster_object
          roster_object.roster_object_logs.create(modified_reason: 'modify_roster', approver_id: current_user.id, approval_time: Time.zone.now.to_datetime,
                                                  class_setting_id: roster_object.class_setting_id, is_general_holiday: roster_object.is_general_holiday, working_time: roster_object.working_time)


          if @roster_list.status == 'is_public'
            group_user_ids = (attendance_group_user_ids << roster_object.user_id)
            Message.add_notification(roster_object, "roster_object_updated", group_user_ids.uniq) unless group_user_ids.empty?
          end

          att = Attend.find_attend_by_user_and_date(roster_object.user_id, roster_object.roster_date)
          if att == nil
            d = roster_object.roster_date
            Attend.create(user_id: roster_object.user_id,
                          attend_date: d ? d.in_time_zone : '',
                          attend_weekday: d ? d.in_time_zone.wday : '',
                          roster_object_id: roster_object.id,
                         )
          else
            att.roster_object_id = roster_object.id
            att.save!
          end

          if roster_object.is_general_holiday || roster_object.working_time || (roster_object.class_setting_id && roster_object.class_setting_id > 0)
            RosterObject.update_attend_and_states(roster_object)
          else
            RosterObject.update_attend_and_states_for_nil(roster_object)
          end
          ro_dates << roster_object.roster_date
          TyphoonSetting.update_qualified_records_for_roster_object(roster_object, roster_object.holiday_type)
        end

        AttendMonthlyReport.update_calc_status(roster_object.user_id, roster_object.roster_date)
        AttendAnnualReport.update_calc_status(roster_object.user_id, roster_object.roster_date)
      end

      ro_dates.uniq.map { |r_d| r_d.strftime("%Y/%m") }.compact.uniq.map do |d_str|
        y = d_str.split("/").first.to_i
        m = d_str.split("/").second.to_i
        Time.zone.local(y, m, 1).to_date
      end.each { |ro_d| AttendMonthApproval.update_data(ro_d) }

      FillInRosterListDataJob.perform_later(@roster_list)

      response_json :ok
    end
  end

  def create
    authorize RosterList
    ActiveRecord::Base.transaction do
      rl = RosterList.create(roster_list_params)
      start_date, end_date = params[:date_range].split('~').map(& :in_time_zone).map(& :to_date)
      rl.start_date, rl.end_date = start_date, end_date
      rl.status = 'is_draft'
      rl.save

      RosterObject.initial_table(rl, params[:location_id].to_i, params[:department_id].to_i, start_date, end_date, current_user)
      rl.fill_in_data
      # RosterPreference.update_or_initial_preference(params[:creator], params[:location_id, params[:department_id]])
      response_json rl.id
    end
  end


  def destroy
    authorize RosterList
    ActiveRecord::Base.transaction do
      result = @roster_list.destroy

      RosterObject.where("roster_date >= ? AND roster_date <= ?", @roster_list.start_date, @roster_list.end_date)
        .where(location_id: @roster_list.location_id, department_id: @roster_list.department_id).each do |ro|
        ro.destroy
      end

      response_json result
    end
  end

  def to_draft
    authorize RosterList
    @roster_list.update(status: 0)
    response_json @roster_list
  end

  def to_public
    authorize RosterList
    # user_ids = []
    # all_users = User.all
    start_date = @roster_list.start_date.to_date
    end_date = @roster_list.end_date.to_date
    location_id = @roster_list.location_id
    department_id = @roster_list.department_id
    # (start_date .. end_date).each do |d|
    #   all_users.each do |u|
    #     if location_id == ProfileService.location(u, d.to_datetime)&.id &&
    #        department_id == ProfileService.department(u, d.to_datetime)&.id
    #       user_ids << u.id
    #     end
    #   end
    # end

    all_roster_objects = RosterObject.where(location_id: location_id, department_id: department_id).by_date(start_date, end_date)

    uniq_user_ids = all_roster_objects.pluck(:user_id).compact.uniq

    # uniq_user_ids = user_ids.compact.uniq

    # users = User.where(location_id: @roster_list.location_id, department_id: @roster_list.department_id)
    users = User.where(id: uniq_user_ids)
    not_nil_count_users = users.reduce(0) do |sum, u|
      sum = RosterObject.has_nil_roster_objects_of_user?(u, start_date, end_date, location_id, department_id) ? sum : (sum + 1)
      sum
    end
    if not_nil_count_users == users.count
      @roster_list.update(status: 1)
      response_json @roster_list.reload
    else
      response_json ({ error: true,  messages: "There are some nil roster_objects of users, nncu: #{not_nil_count_users}, uc: #{users.count}", users: users.as_json })
    end
  end

  def to_sealed
    authorize RosterList

    # user_ids = []
    # all_users = User.all
    start_date = @roster_list.start_date.to_date
    end_date = @roster_list.end_date.to_date
    location_id = @roster_list.location_id
    department_id = @roster_list.department_id
    # (start_date .. end_date).each do |d|
    #   all_users.each do |u|
    #     if location_id == ProfileService.location(u, d.to_datetime)&.id &&
    #        department_id == ProfileService.department(u, d.to_datetime)&.id
    #       user_ids << u.id
    #     end
    #   end
    # end

    # uniq_user_ids = user_ids.compact.uniq

    all_roster_objects = RosterObject.where(location_id: location_id, department_id: department_id).by_date(start_date, end_date)

    uniq_user_ids = all_roster_objects.pluck(:user_id).compact.uniq

    # users = User.where(location_id: @roster_list.location_id, department_id: @roster_list.department_id)
    users = User.where(id: uniq_user_ids)

    not_nil_count_users = users.reduce(0) do |sum, u|
      sum = RosterObject.has_nil_roster_objects_of_user?(u, @roster_list.start_date, @roster_list.end_date, @roster_list.location_id, @roster_list.department_id) ? sum : (sum + 1)
      sum
    end

    if not_nil_count_users == users.count
      @roster_list.update(status: 2)
      response_json @roster_list
    else
      response_json ({ error: true,  messages: 'There are some nil roster_objects of users' })
    end
  end

  def options
    result = {}

    result[:status_types] = status_type_table
    result[:roster_lists] = RosterList.all.map do |rl|
      {
        id: rl.id,
        chinese_name: rl.chinese_name,
        english_name: rl.english_name,
        simple_chinese_name: rl.simple_chinese_name,
      }
    end.as_json

    users = User.all

    result[:departments] = Department.where(id: users.pluck(:department_id).uniq).as_json
    result[:positions] = Position.where(id: users.pluck(:position_id).uniq).as_json

    result[:modified_reason] = RosterObjectLog.modified_reason_table

    response_json result.as_json
  end

  def filter_options
    result = {}

    # all_roster_objects = @roster_list.roster_objects
    users = User.where(location_id: @roster_list.location_id, department_id: @roster_list.department_id)



    result[:departments] = Department.where(id: users.pluck(:department_id).uniq).as_json
    result[:positions] = Position.where(id: users.pluck(:position_id).uniq).as_json

    response_json result.as_json
  end

  def is_able_apply
    start_date = params[:apply_start_date].in_time_zone.to_date
    end_date = params[:apply_end_date].in_time_zone.to_date
    roster_lists = RosterList.where(location_id: params[:location_id], department_id: params[:department_id])

    result = [*start_date .. end_date].map do |date|
      apply_count = roster_lists.where("start_date <= ? AND end_date >= ?", date, date).count
      date_be_able_apply = apply_count > 0 ? false : true
      [date, date_be_able_apply]
    end.to_h

    final_result = result.merge(
      {
        be_able_apply: result.values.select { |k| k == false }.count <= 0
      }
    )
    response_json final_result.as_json
  end

  private

  def roster_list_params
    params.require(:roster_list).permit(
      :region,
      :status,
      :chinese_name,
      :location_id,
      :department_id,
      :date_range,
      :start_date,
      :end_date
    )
  end

  def roster_objects_params
    params.permit(roster_objects: [:id, :region, :user_id, :roster_list_id, :class_setting_id, :is_general_holiday, :roster_date, :working_time])
  end

  def set_roster_list
    @roster_list = RosterList.find(params[:id])
  end

  def set_employee_preferences
    roster_list = RosterList.find(params[:id])
    roster_preference = RosterPreference.where(location_id: roster_list.location_id, department_id: roster_list.department_id).first
    EmployeePreference.setting_users(roster_preference) if roster_preference
  end

  def format_objects_for_week(roster_objects, day)
    if roster_objects.length == 7
      roster_objects
    # elsif rosters.length == 0
    #   []
    else
      # day = rosters[0]['date']
      date = roster_objects.length == 0 ? day : roster_objects[0]['roster_date']
      duration = [*date.beginning_of_week.to_date .. date.end_of_week.to_date]
      duration.map do |d|
        roster_object = roster_objects.find { |r| r['roster_date'] == d }
        roster_object != nil ? roster_object : {roster_date: d, class_setting_id: nil, is_general_holiday: nil}
      end
    end
  end

  def search_query
    tag = false
    region = params[:region] || 'macau'
    lang_key = params[:lang] || 'zh-TW'

    lang = if lang_key == 'zh-TW'
             'chinese_name'
           elsif lang_key == 'zh-US'
             'english_name'
           else
             'simple_chinese_name'
           end

    roster_lists = RosterList.where(region: region)
                     .by_location_id(params[:location_id])
                     .by_department_id(params[:department_id])
                     .by_name(params[:name], lang)
                     .by_date_range(params[:start_date], params[:end_date])
                     .by_status(params[:status])
                     .by_roster_list_ids(params[:roster_list_ids])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'
      if params[:sort_column] == 'departmentPosition'
        roster_lists = roster_lists.order("location_id #{params[:sort_direction]}", "department_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'time'
        roster_lists = roster_lists.order("start_date #{params[:sort_direction]}", "end_date #{params[:sort_direction]}")
      elsif params[:sort_column] == 'status_name'
        roster_lists = roster_lists.order("status #{params[:sort_direction]}")
      else
        roster_lists = roster_lists.order("#{params[:sort_column]} #{params[:sort_direction]}")
      end
      tag = true
    end

    roster_lists = roster_lists.order(created_at: :desc) if tag == false
    roster_lists
  end

  def format_result(json)
    json.map do |hash|
      location = hash['location_id'] ? Location.find(hash['location_id']) : nil
      hash['location'] = location ?
      {
        id: hash['location_id'],
        chinese_name: location['chinese_name'],
        english_name: location['english_name'],
        simple_chinese_name: location['simple_chinese_name'],
      } : nil

      department = hash['department_id'] ? Department.find(hash['department_id']) : nil
      hash['department'] = department ?
      {
        id: hash['department_id'],
        chinese_name: department['chinese_name'],
        english_name: department['english_name'],
        simple_chinese_name: department['simple_chinese_name'],
      } : nil

      hash['status_name'] = find_name_for(hash['status'], status_type_table)

      hash
    end
  end

  def find_name_for(type, table)
    table.select { |op| op[:key] == type }.first
  end

  def status_type_table
    [
      {
        key: 'is_draft',
        chinese_name: '草稿',
        english_name: 'Draft',
        simple_chinese_name: '草稿',
      },

      {
        key: 'is_public',
        chinese_name: '已公開',
        english_name: 'Public',
        simple_chinese_name: '已公开',
      },

      {
        key: 'is_sealed',
        chinese_name: '已封存',
        english_name: 'Sealed',
        simple_chinese_name: '已封存',
      },
    ]
  end

  def return_response_roster_objects(page, all_roster_objects, user_ids, start_date, end_date, o_location_id, o_department_id)
    page ||= 1
    meta = {}

    user_result = User.where(id: user_ids)

    if params[:filter_nil_roster_object] == true || params[:filter_nil_roster_object] == 'true'
      u_ids = []
      range_count = (end_date - start_date).to_i + 1
      user_result.each do |u|

        date_of_employment = u.profile.data['position_information']['field_values']['date_of_employment']
        entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

        position_resigned_date = u.profile.data['position_information']['field_values']['resigned_date']
        leave = position_resigned_date ? position_resigned_date.in_time_zone.to_date : nil

        ros = RosterObject.where(user_id: u.id, roster_date: start_date..end_date, location_id: o_location_id, department_id: o_department_id)
        not_nil_count = ros.reduce(0) do |sum, r|
          is_entry = r.roster_date >= entry
          is_leave = leave ? r.roster_date > leave : false
          is_active = r.is_active == 'active' || r.is_active == nil
          sum = (is_entry && !is_leave && is_active && r.class_setting_id == nil && r.is_general_holiday != true && r.working_time == nil && r.holiday_type == nil) ? sum : (sum + 1)
          sum
        end
        u_ids += [u.id] if not_nil_count < range_count
      end
      user_result = user_result.where(id: u_ids)
    end

    user_result = user_result.where(empoid: params["user.empoid".to_sym]) if params["user.empoid".to_sym]
    user_result = user_result.where("#{select_language.to_s} like ?", "%#{params[:user]}%") if params[:user]
    user_result = user_result.where(department_id: params[:department]) if params[:department]
    user_result = user_result.where(position_id: params[:position]) if params[:position]

    user_result = sort_result(user_result)

    meta['total_count'] = user_result.count
    result = user_result.page(page.to_i).per(20)
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    user_roster_map = all_roster_objects.group_by { |roster_object| roster_object.user_id }
    new_result = format_query_result(result, user_roster_map, start_date, end_date, o_location_id, o_department_id)

    return [new_result, meta]
  end

  def sort_result(user_result)
    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      if params[:sort_column] == 'department'
        user_result = user_result.order("department_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'position'
        user_result = user_result.order("position_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user'
        user_result = user_result.order("id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user.empoid'
        user_result = user_result.order("empoid #{params[:sort_direction]}")
      elsif params[:sort_column] == 'date_of_employment'
        user_result = user_result.includes(:profile).order("profiles.data -> 'position_information' -> 'field_values' -> 'date_of_employment' #{params[:sort_direction]}")
      else
        user_result = user_result.order("#{params[:sort_column]} #{params[:sort_direction]}")
      end
    else
      user_result = user_result.order(empoid: :asc)
    end

    user_result
  end

  def format_query_result(result, user_roster_map, start_date, end_date, o_location_id, o_department_id)
    range_count = (end_date - start_date).to_i + 1
    new_result = result.pluck(:id).map do |user_id|
      user = User.find(user_id)
      department = Department.find(user.department_id)
      position = Position.find(user.position_id)

      last_working_records = user.try(:profile).try(:resignation_records)
      last_working_date = last_working_records ? last_working_records.order(created_at: :desc).first.resigned_date : nil

      roster_objects = last_working_date == nil ?
                         user_roster_map[user.id] :
                         user_roster_map[user.id].map { |ro| ro.roster_date < last_working_date ? ro : { roster_date: ro.roster_date, is_empty: true} }

      if roster_objects && roster_objects.size < range_count && o_location_id && o_department_id
        (start_date..end_date).each do |d|
          ro = RosterObject.where(user_id: user_id, location_id: o_location_id, department_id: o_department_id, roster_date: d).first
          if ro == nil
            ro = RosterObject.create(user_id: user_id,
                                     location_id: o_location_id,
                                     department_id: o_department_id,
                                     roster_date: d,
                                     is_active: 'inactive',
                                    )
            active = RosterObject.where(user_id: user_id, location_id: user.location_id, department_id: user.department_id, roster_date: d, is_active: ['active', nil]).first

            if active
              ro.class_setting_id = active.class_setting_id
              ro.is_general_holiday = active.is_general_holiday
              ro.working_time = active.working_time
              ro.holiday_type = active.holiday_type
              ro.holiday_record_id = active.holiday_record_id
              ro.borrow_return_type = active.borrow_return_type
              ro.working_hours_transaction_record_id = active.working_hours_transaction_record_id
              ro.adjust_type = active.adjust_type
              ro.save
            end
          end
        end
      end

      date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
      entry = date_of_employment.in_time_zone.to_date rescue nil
      position_resigned_date = user.profile.data['position_information']['field_values']['resigned_date']
      leave = position_resigned_date ? position_resigned_date.in_time_zone.to_date : nil

      if user
        {
          user: user,
          date_of_employment: entry,
          position_resigned_date: leave,
          last_working_date: last_working_date,
          department: department,
          position: position,
          roster_objects: roster_objects.as_json(include: [:class_setting, :holiday_record, :working_hours_transaction_record])
        }
      end
    end

    new_result
  end

  def self.get_table_fields(days_begin, days_end, is_detail, display_type)
    days = Time.zone.parse(days_begin).to_date..(Time.zone.parse(days_end).to_date)
    empoid = {
      chinese_name: '員工編號',
      english_name: 'empoid',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        rst[:user][:empoid].rjust(8, '0')
      }
    }

    name = {
      chinese_name: '員工姓名',
      english_name: 'Name',
      simple_chinese_name: '员工姓名',
      get_value: -> (rst, options){
        rst[:user][options[:name_key]]
      }
    }

    department = {
      chinese_name: '部門',
      english_name: 'Department',
      simple_chinese_name: '部门',
      get_value: -> (rst, options){
        rst[:department] ? rst[:department][options[:name_key]] : ''
      }
    }

    position = {
      chinese_name: '職位',
      english_name: 'Position',
      simple_chinese_name: '职位',
      get_value: -> (rst, options){
        rst[:position] ? rst[:position][options[:name_key]] : ''
      }
    }

    date_of_employment = {
      chinese_name: '入職日期',
      english_name: 'Date Of Employment',
      simple_chinese_name: '入职日期',
      get_value: -> (rst, options){
        rst[:date_of_employment] ? rst[:date_of_employment] : ''
      }
    }

    completed_table_fields = [
      empoid, name, department, position, date_of_employment
    ].concat(days.map do |day|
               {
                 chinese_name: day,
                 english_name: day,
                 simple_chinese_name: day,
                 get_value: -> (rst, options) {
                   r_objects = rst[:roster_objects] ? rst[:roster_objects] : nil
                   d = day.strftime("%Y-%m-%d")

                   ans = ''
                   if r_objects
                     ro = r_objects.select { |o| o[:roster_date] == d }.first
                     if ro
                       if rst[:date_of_employment] && ro[:roster_date] < rst[:date_of_employment]
                         ans = '待職'
                       elsif rst[:position_resigned_date] && ro[:roster_date] >= rst[:resigned_date]
                         ans = '離職'
                       elsif ro[:holiday_type] != nil
                         holiday_type_table = HolidayRecord.holiday_type_table
                         ans = holiday_type_table.select { |t| t[:key] == ro[:holiday_type] }.first[options[:name_key]]
                       else
                         if ro[:is_general_holiday] == true
                           ans = '公休'
                         else
                           cs = ro[:class_setting]
                           if cs
                             case display_type
                             when 'class_name'
                               ans = "#{cs["display_name"]}"
                             when 'class_code'
                               ans = "\s#{cs["code"]}"
                             when 'class_time'
                               n_cs = ClassSetting.find_by(id: cs['id'].to_i)
                               start_time = n_cs.start_time ? n_cs.start_time.strftime("%H%M") : ''
                               end_time = n_cs.end_time ? n_cs.end_time.strftime("%H%M") : ''
                               is_start_next = n_cs.is_next_of_start ? '次日' : ''
                               is_end_next = n_cs.is_next_of_end ? '次日' : ''
                               if ro[:borrow_return_type]
                                 wht = WorkingHoursTransactionRecord.find_by(id: ro[:working_hours_transaction_record_id].to_i)

                                 wht_start_time = wht.start_time.strftime("%H%M")
                                 wht_end_time = wht.end_time.strftime("%H%M")
                                 wht_is_start_next = wht.is_start_next == true ? '次日 ' : ''
                                 wht_is_end_next = wht.is_end_next == true ? '次日 ' : ''
                                 wht_start_int = wht.is_start_next == true ? (10000 + wht_start_time.to_i) : wht_start_time.to_i
                                 wht_end_int = wht.is_end_next == true ? (10000 + wht_end_time.to_i) : wht_end_time.to_i

                                 c_start_int = n_cs.is_next_of_start ? (10000 + start_time.to_i) : start_time.to_i
                                 c_end_int = n_cs.is_next_of_end ? (10000 + end_time.to_i) : end_time.to_i

                                 if ro[:borrow_return_type] == 'borrow_as_a'
                                   if wht_start_int == c_start_int
                                     ans = "#{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                                   elsif wht_end_int == c_end_int
                                     ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time}"
                                   else
                                     ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time} #{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                                   end
                                 elsif ro[:borrow_return_type] == 'return_as_a'
                                   ans = "#{is_start_next}#{start_time} - #{is_end_next}#{end_time} #{wht_is_start_next}#{wht_start_time} - #{wht_is_end_next}#{wht_end_time}"
                                 elsif ro[:borrow_return_type] == 'borrow_as_b'
                                   ans = "#{is_start_next}#{start_time} - #{is_end_next}#{end_time} #{wht_is_start_next}#{wht_start_time} - #{wht_is_end_next}#{wht_end_time}"
                                 elsif ro[:borrow_return_type] == 'return_as_b'
                                   if wht_start_int == c_start_int
                                     ans = "#{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                                   elsif wht_end_int == c_end_int
                                     ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time}"
                                   else
                                     ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time} #{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                                   end
                                 end
                               else
                                 ans = "#{is_start_next} #{start_time} - #{is_end_next} #{end_time}"
                               end
                             else
                               ans = "#{cs["display_name"]}"
                             end
                           elsif ro[:working_time]
                             wk_time= ro[:working_time]
                             tmp_start_time = wk_time.split('-').first
                             tmp_start_hour = tmp_start_time.split(':').first.to_i
                             true_start_hour = (tmp_start_hour % 24).to_s.rjust(2, '0')
                             true_start_min = tmp_start_time.split(':').second.to_i.to_s.rjust(2, '0')
                             start_time = "#{true_start_hour}#{true_start_min}"
                             is_start_next = tmp_start_hour / 24 == 1 ? '次日 ' : ''

                             tmp_end_time = wk_time.split('-').last
                             tmp_end_hour = tmp_end_time.split(':').first.to_i
                             true_end_hour = (tmp_end_hour % 24).to_s.rjust(2, '0')
                             true_end_min = tmp_end_time.split(':').second.to_i.to_s.rjust(2, '0')
                             end_time = "#{true_end_hour}#{true_end_min}"
                             is_end_next = tmp_end_hour / 24 == 1 ? '次日 ' : ''

                             if ro[:borrow_return_type]
                               wht = WorkingHoursTransactionRecord.find_by(id: ro[:working_hours_transaction_record_id].to_i)

                               wht_start_time = wht.start_time.strftime("%H%M")
                               wht_end_time = wht.end_time.strftime("%H%M")
                               wht_is_start_next = wht.is_start_next == true ? '次日 ' : ''
                               wht_is_end_next = wht.is_end_next == true ? '次日 ' : ''
                               wht_start_int = wht.is_start_next == true ? (10000 + wht_start_time.to_i) : wht_start_time.to_i
                               wht_end_int = wht.is_end_next == true ? (10000 + wht_end_time.to_i) : wht_end_time.to_i

                               c_start_int = tmp_start_hour / 24 == 1 ? (10000 + start_time.to_i) : start_time.to_i
                               c_end_int = tmp_end_hour / 24 == 1 ? (10000 + end_time.to_i) : end_time.to_i

                               if ro[:borrow_return_type] == 'borrow_as_a'
                                 if wht_start_int == c_start_int
                                   ans = "#{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                                 elsif wht_end_int == c_end_int
                                   ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time}"
                                 else
                                   ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time} #{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                                 end
                               elsif ro[:borrow_return_type] == 'return_as_a'
                                 ans = "#{is_start_next}#{start_time} - #{is_end_next}#{end_time} #{wht_is_start_next}#{wht_start_time} - #{wht_is_end_next}#{wht_end_time}"
                               elsif ro[:borrow_return_type] == 'borrow_as_b'
                                 ans = "#{is_start_next}#{start_time} - #{is_end_next}#{end_time} #{wht_is_start_next}#{wht_start_time} - #{wht_is_end_next}#{wht_end_time}"
                               elsif ro[:borrow_return_type] == 'return_as_b'
                                 if wht_start_int == c_start_int
                                   ans = "#{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                                 elsif wht_end_int == c_end_int
                                   ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time}"
                                 else
                                   ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time} #{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                                 end
                               end
                             else
                               ans = "#{is_start_next}#{start_time}-#{is_end_next}#{end_time}"
                             end
                           end
                         end
                       end
                     end
                   end
                   ans
                 }
               }
             end)

    is_detail == true ? completed_table_fields.select { |field| field[:english_name] != "Date Of Employment" } : completed_table_fields
  end


  def export_roster_objects_title
    if select_language.to_s == 'chinese_name'
      '排班表'
    elsif select_language.to_s == 'english_name'
      'Roster List'
    else
      '排班表'
    end
  end

  def export_roster_objects_query_title
    if select_language.to_s == 'chinese_name'
      '排班查詢'
    elsif select_language.to_s == 'english_name'
      'Roster Query'
    else
      '排班查询'
    end
  end
end
