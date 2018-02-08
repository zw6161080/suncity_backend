# coding: utf-8
class HolidayRecordsController < ApplicationController
  include GenerateXlsxHelper
  include DownloadActionAble
  before_action :set_holiday_record, only: [:show, :update, :destroy, :histories, :add_approval, :add_attach]

  def index_for_report
    authorize HolidayRecord
    raw_index
  end

  def raw_index
    params[:page] ||= 1
    meta = {}
    all_result = search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    final_result = format_result(result.as_json(include: [:creator], methods: []))

    response_json final_result, meta: meta

  end

  def index
    authorize HolidayRecord
    raw_index
  end

  def show
    authorize HolidayRecord
    raw_show
  end

  def raw_show
    result = @holiday_record.as_json(
      include: {
        approval_items: {include: {user: {include: [:department, :location, :position ]}}},
        attend_attachments: {include: :creator},
        user: {include: [:department, :location, :position ], methods: [:date_of_employment]},
        holiday_record_histories: {include: [:user, :creator]},
        reserved_holiday_setting: {},
      }
    )

    response_json result

  end


  def raw_create

    ActiveRecord::Base.transaction do
      nr = nil
      if params[:holiday_record][:holiday_type].split('_').last.to_i == 0
        raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:holiday_record]
        raise LogicError, {id: 422, message: '时间不正确'}.to_json if params[:holiday_record][:start_date] > params[:holiday_record][:end_date]
        raise LogicError, {id: 422, message: '时间不正确'}.to_json if params[:holiday_record][:start_time] > params[:holiday_record][:end_time]
        nr = HolidayRecord.create(holiday_record_params)
      else
        raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:holiday_record]
        raise LogicError, {id: 422, message: '时间不正确'}.to_json if params[:holiday_record][:start_date] > params[:holiday_record][:end_date]
        raise LogicError, {id: 422, message: '时间不正确'}.to_json if params[:holiday_record][:start_time] > params[:holiday_record][:end_time]
        nr = HolidayRecord.create(holiday_record_params)

        reserved_holiday_setting_id = params[:holiday_record][:holiday_type].split('_').last.to_i
        reserved_holiday_setting = ReservedHolidaySetting.find_by(id: reserved_holiday_setting_id)
        raise LogicError, {id: 422, message: '找不到数据'}.to_json unless reserved_holiday_setting
        if reserved_holiday_setting
          nr.reserved_holiday_setting_id = reserved_holiday_setting.id
          nr.save
        end
      end

      nr.holiday_record_histories.create(nr.attributes.merge({ id: nil }))
      nr.input_date = nr.created_at.to_date
      nr.input_time = nr.created_at.to_datetime.strftime("%H:%M:%S")
      nr.days_count = nr.days_count.to_i - nr.change_to_general_holiday_count.to_i
      nr.save

      # attend state
      user_id = nr.user_id
      (nr.start_date .. nr.end_date).each do |date|
        ro = RosterObject.find_roster_object_by_user_and_date(user_id, date)
        if ro == nil
          ro = RosterObject.create(user_id: user_id,
                                   roster_date: date,
                                   holiday_type: nr.holiday_type,
                                   holiday_record_id: nr.id,
          )
        else
          if ro.change_to_general_holiday != true
            ro.holiday_type = nr.holiday_type
            ro.holiday_record_id = nr.id
            ro.save

            inactive_ro = RosterObject.where(user_id: ro.user_id, roster_date: ro.roster_date, is_active: 'inactive').first
            if inactive_ro
              inactive_ro.holiday_type = nr.holiday_type
              inactive_ro.holiday_record_id = nr.id
              inactive_ro.save
            end
          end
        end

        ro.roster_object_logs.create(modified_reason: nr.holiday_type,
                                     approver_id: current_user.id,
                                     approval_time: Time.zone.now.to_datetime,
                                     is_general_holiday: ro.is_general_holiday,
                                     class_setting_id: ro.class_setting_id,
                                     working_time: ro.working_time)

        TyphoonSetting.update_qualified_records_for_roster_object(ro, ro.holiday_type)

        att = Attend.find_attend_by_user_and_date(user_id, date)
        if att == nil
          att = Attend.create(user_id: user_id,
                              attend_date: date,
                              attend_weekday: date.wday,
          )
        end
        att.attend_states.create(state: nr.holiday_type,
                                 record_type: 'holiday_record',
                                 record_id: nr.id
        )

        overtime_records = OvertimeRecord
                             .where(user_id: att.user_id,
                                    source_id: nil,
                                    is_deleted: [false, nil])
                             .where("overtime_start_date <= ? AND overtime_end_date >= ?", att.attend_date, att.attend_date)
        has_overtime_records = overtime_records.count > 0

        user = User.find_by(id: att&.user_id)
        can_punch = user && user.punch_card_state_of_date(att&.attend_date)

        if (att.on_work_time != nil || att.off_work_time != nil) &&
          !has_overtime_records
          att.attend_states.find_or_create_by(auto_state: 'punching_card_on_holiday_exception') if can_punch
        end
        # attend log
        att.attend_logs.create(user_id: user_id,
                               apply_type: 'holiday',
                               type_id: nr.id,
                               logger_id: nr.creator_id,
        )
      end
      if nr.is_compensate == false
        AttendMonthlyReport.update_calc_status(nr.user_id, nr.start_date)
        AttendAnnualReport.update_calc_status(nr.user_id, nr.start_date)
      else
        CompensateReport.update_reports(nr)
      end
      AttendMonthApproval.update_data(nr.start_date)
      response_json nr.id
    end
  end

  def create
    authorize HolidayRecord
    raw_create
  end

  def update
    authorize HolidayRecord
    # 清除假期记录关联的已取假期
    @holiday_record.taken_holiday_records.destroy_all

    origin_start = @holiday_record.start_date
    origin_end = @holiday_record.end_date

    is_reserved = params[:holiday_type].split('_').last.to_i == 0 ? false : true

    updated_holiday_record = nil
    if is_reserved
      # @holiday_record.update(holiday_type: params[:holiday_type])
      raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:holiday_record]
      raise LogicError, {id: 422, message: '时间不正确'}.to_json if params[:holiday_record][:start_date] > params[:holiday_record][:end_date]
      raise LogicError, {id: 422, message: '时间不正确'}.to_json if params[:holiday_record][:start_time] > params[:holiday_record][:end_time]
      updated_holiday_record = @holiday_record.update(holiday_record_params)

      reserved_holiday_setting_id = params[:holiday_type].split('_').last.to_i
      reserved_holiday_setting = ReservedHolidaySetting.find_by(id: reserved_holiday_setting_id)
      raise LogicError, {id: 422, message: '找不到数据'}.to_json unless reserved_holiday_setting
      if reserved_holiday_setting
        @holiday_record.reserved_holiday_setting_id = reserved_holiday_setting.id
        @holiday_record.save
      end

    else
      # @holiday_record.update(holiday_type: 'reserved')
      raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:holiday_record]
      raise LogicError, {id: 422, message: '时间不正确'}.to_json if params[:holiday_record][:start_date] > params[:holiday_record][:end_date]
      raise LogicError, {id: 422, message: '时间不正确'}.to_json if params[:holiday_record][:start_time] > params[:holiday_record][:end_time]
      updated_holiday_record = @holiday_record.update(holiday_record_params)
    end

    if updated_holiday_record

      updated_record = HolidayRecord.find_by(id: @holiday_record.id)
      raise LogicError, {id: 422, message: '找不到数据'}.to_json unless updated_record
      raise LogicError, {id: 422, message: '时间不正确'}.to_json if params[:start_date]>params[:end_date]
      new_start = params[:start_date].in_time_zone.to_date
      new_end = params[:end_date].in_time_zone.to_date

      to_gh_count = 0

      (origin_start .. origin_end).each do |date|
        ro = RosterObject.where(user_id: @holiday_record.user_id, roster_date: date).first
        att = Attend.where(user_id: @holiday_record.user_id, attend_date: date).first
        if date < new_start || date > new_end
          # destroy
          state = att.attend_states.where(record_type: 'holiday_record', record_id: @holiday_record.id).first
          state.destroy if state

          holiday_exception_state = att.attend_states.where(auto_state: 'punching_card_on_holiday_exception').first
          holiday_exception_state.destroy if holiday_exception_state

          log = att.attend_logs.where(apply_type: 'holiday', type_id: @holiday_record.id).first
          log.destroy if log

          # roster_object
          ro.holiday_type = nil
          ro.holiday_record_id = nil
          ro.save

          inactive_ro = RosterObject.where(user_id: ro.user_id, roster_date: ro.roster_date, is_active: 'inactive').first
          if inactive_ro
            inactive_ro.holiday_type = nil
            inactive_ro.holiday_record_id = nil
            inactive_ro.save
          end

          TyphoonSetting.update_qualified_records_for_roster_object(ro, ro.holiday_type)
        else
          # update
          att_state = att.attend_states.where(record_type: 'holiday_record', record_id: @holiday_record.id).first
          att_state.state = updated_record.holiday_type
          att_state.save

          overtime_records = OvertimeRecord
                               .where(user_id: att.user_id,
                                      source_id: nil,
                                      is_deleted: [false, nil])
                               .where("overtime_start_date <= ? AND overtime_end_date >= ?", att.attend_date, att.attend_date)
          has_overtime_records = overtime_records.count > 0

          user = User.find_by(id: att&.user_id)
          can_punch = user && user.punch_card_state_of_date(att&.attend_date)

          if (att.on_work_time != nil || att.off_work_time != nil) &&
             !has_overtime_records
            att.attend_states.find_or_create_by(auto_state: 'punching_card_on_holiday_exception') if can_punch
          end

          if ro.change_to_general_holiday != true
            ro.holiday_type = updated_record.holiday_type
            ro.save

            inactive_ro = RosterObject.where(user_id: ro.user_id, roster_date: ro.roster_date, is_active: 'inactive').first
            if inactive_ro
              inactive_ro.holiday_type = updated_record.holiday_type
              inactive_ro.holiday_record_id = updated_record.id
              inactive_ro.save
            end
          else
            to_gh_count = to_gh_count + 1
          end

          ro.roster_object_logs.create(modified_reason: updated_record.holiday_type,
                                       approver_id: current_user.id,
                                       approval_time: Time.zone.now.to_datetime,
                                       is_general_holiday: ro.is_general_holiday,
                                       class_setting_id: ro.class_setting_id,
                                       working_time: ro.working_time)
          TyphoonSetting.update_qualified_records_for_roster_object(ro, ro.holiday_type)
        end
      end


      (new_start .. new_end).each do |date|
        if date < origin_start || date > origin_end
          # create
          user_id = updated_record.user_id
          ro = RosterObject.find_roster_object_by_user_and_date(user_id, date)
          if ro == nil
            ro = RosterObject.create(user_id: user_id,
                                     roster_date: date,
                                     holiday_type: updated_record.holiday_type,
                                    )
          else
            if ro.change_to_general_holiday != true
              ro.holiday_type = updated_record.holiday_type
              ro.holiday_record_id = updated_record.id
              ro.save

              inactive_ro = RosterObject.where(user_id: ro.user_id, roster_date: ro.roster_date, is_active: 'inactive').first
              if inactive_ro
                inactive_ro.holiday_type = updated_record.holiday_type
                inactive_ro.holiday_record_id = updated_record.id
                inactive_ro.save
              end

            else
              to_gh_count = to_gh_count + 1
            end
          end

          ro&.roster_object_logs&.create(modified_reason: updated_record.holiday_type,
                                       approver_id: current_user.id,
                                       approval_time: Time.zone.now.to_datetime,
                                       is_general_holiday: ro.is_general_holiday,
                                       class_setting_id: ro.class_setting_id,
                                       working_time: ro.working_time)

          TyphoonSetting.update_qualified_records_for_roster_object(ro, ro.holiday_type)
          att = Attend.find_attend_by_user_and_date(user_id, date)
          if att == nil
            att = Attend.create(user_id: user_id,
                                attend_date: date,
                                attend_weekday: date.wday,
                               )
          end
          att.attend_states.create(state: updated_record.holiday_type,
                                   record_type: 'holiday_record',
                                   record_id: updated_record.id
                                  )

          overtime_records = OvertimeRecord
                               .where(user_id: att.user_id,
                                      source_id: nil,
                                      is_deleted: [false, nil])
                               .where("overtime_start_date <= ? AND overtime_end_date >= ?", att.attend_date, att.attend_date)
          has_overtime_records = overtime_records.count > 0

          user = User.find_by(id: att&.user_id)
          can_punch = user && user.punch_card_state_of_date(att&.attend_date)

          if (att.on_work_time != nil || att.off_work_time != nil) &&
             !has_overtime_records
            att.attend_states.find_or_create_by(auto_state: 'punching_card_on_holiday_exception') if can_punch
          end

          # attend log
          att.attend_logs.create(user_id: user_id,
                                 apply_type: 'holiday',
                                 type_id: updated_record.id,
                                 logger_id: updated_record.creator_id,
                                )

        end
      end

      updated_record.change_to_general_holiday_count = to_gh_count
      updated_record.days_count = updated_record.days_count.to_i - to_gh_count
      updated_record.save


      if updated_record.is_compensate == false
        AttendMonthlyReport.update_calc_status(updated_record.user_id, updated_record.start_date)
        AttendAnnualReport.update_calc_status(updated_record.user_id, updated_record.start_date)
      else
        CompensateReport.update_reports(updated_record)
      end
      AttendMonthApproval.update_data(updated_record.start_date)

      updated_record.holiday_record_histories.create(
        updated_record.attributes.merge({ id: nil })
      )
    end

    response_json updated_holiday_record
  end

  def destroy
    authorize HolidayRecord
    ActiveRecord::Base.transaction do
      # 清除假期记录关联的已取假期
      @holiday_record.taken_holiday_records.destroy_all

      @holiday_record.update(is_deleted: true)
      updated_holiday_record = @holiday_record.reload
      if /reserved_holiday_\d+/.match(@holiday_record.holiday_type)

        rhp = ReservedHolidayParticipator.where(user_id: @holiday_record.user_id, reserved_holiday_setting_id: @holiday_record.reserved_holiday_setting_id).first
        rhp.destroy
      end
      att_states = AttendState.where(record_type: 'holiday_record', record_id: updated_holiday_record.id)
      att_states.each { |state| state.destroy if state }

      att_logs = AttendLog.where(apply_type: 'holiday', type_id: updated_holiday_record.id)
      att_logs.each { |log| log.destroy if log }

      start_date = updated_holiday_record.start_date
      end_date = updated_holiday_record.end_date
      (start_date .. end_date).each do |date|
        ro = RosterObject.find_roster_object_by_user_and_date(updated_holiday_record.user_id, date)
        if ro == nil
        else
          ro.holiday_type = nil
          ro.holiday_record_id = nil
          ro.save

          ro.roster_object_logs.create(modified_reason: "cancel_#{@holiday_record.holiday_type}",
                                       approver_id: current_user.id,
                                       approval_time: Time.zone.now.to_datetime,
                                       is_general_holiday: ro.is_general_holiday,
                                       class_setting_id: ro.class_setting_id,
                                       working_time: ro.working_time)

          inactive_ro = RosterObject.where(user_id: ro.user_id, roster_date: ro.roster_date, is_active: 'inactive').first
          if inactive_ro
            inactive_ro.holiday_type = nil
            inactive_ro.holiday_record_id = nil
            inactive_ro.save
          end

          TyphoonSetting.update_qualified_records_for_roster_object(ro, ro.holiday_type)
        end

        att = Attend.find_attend_by_user_and_date(updated_holiday_record.user_id, date)
        holiday_exception_state = att&.attend_states&.where(auto_state: 'punching_card_on_holiday_exception')&.first
        holiday_exception_state.destroy if holiday_exception_state
      end

      if @holiday_record.is_compensate == false
        AttendMonthlyReport.update_calc_status(@holiday_record.user_id, @holiday_record.start_date)
        AttendAnnualReport.update_calc_status(@holiday_record.user_id, @holiday_record.start_date)
      else
        CompensateReport.update_reports(@holiday_record)
      end
      AttendMonthApproval.update_data(@holiday_record.start_date)

      response_json updated_holiday_record
    end
  end

  def histories
    response_json @holiday_record.holiday_record_histories.as_json
  end

  def add_approval
    authorize HolidayRecord
    raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:approval_item][:user_id] && params[:approval_item][:datetime] && params[:approval_item][:comment]
    if params[:approval_item]
      na = @holiday_record.approval_items.create(params[:approval_item].permit(:user_id, :datetime, :comment))
      response_json na.as_json
    else
      response_json :ok
    end
  end

  def destroy_approval
    authorize HolidayRecord
    holiday_record = HolidayRecord.find(params[:holiday_record_id])
    raise LogicError, {id: 422, message: '找不到记录'}.to_json unless holiday_record
    app = holiday_record.approval_items.find(params[:id])
    raise LogicError, {id: 422, message: '找不到记录'}.to_json unless app
    app.destroy if app
    response_json :ok
  end

  def add_attach
    authorize HolidayRecord
    raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:attach_item][:file_name]
    if params[:attach_item]
      ai = @holiday_record.attend_attachments.create(params[:attach_item].permit(:file_name, :comment, :attachment_id, :creator_id))
      response_json ai.as_json
    else
      response_json :ok
    end
  end

  def destroy_attach
    authorize HolidayRecord
    holiday_record = HolidayRecord.find(params[:holiday_record_id])
    raise LogicError, {id: 422, message: '找不到记录'}.to_json unless holiday_record
    att = holiday_record.attend_attachments.find(params[:id])
    raise LogicError, {id: 422, message: '找不到记录'}.to_json unless att
    att.destroy if att
    response_json :ok
  end

  def options
    result = {}

    # reserve_holiday_settings = ReservedHolidaySetting.all.map do |setting|
    #   {
    #     key: "#{setting.id}",
    #     chinese_name: setting.chinese_name,
    #     english_name: setting.english_name,
    #     simple_chinese_name: setting.simple_chinese_name,
    #   }
    # end

    result[:holiday_types] = holiday_type_table

    response_json result.as_json
  end

  def be_able_apply
    start_date = params[:apply_start_date].in_time_zone.to_date rescue nil
    end_date = params[:apply_end_date].in_time_zone.to_date rescue nil
    raise LogicError, {id: 422, message: '时间不正确'}.to_json if params[:apply_start_date]>params[:apply_end_date]
    start_time = params[:apply_start_time].in_time_zone.to_datetime rescue nil
    end_time = params[:apply_end_time].in_time_zone.to_datetime rescue nil
    raise LogicError, {id: 422, message: '时间不正确'}.to_json if params[:apply_start_time]>params[:apply_end_time]
    user_id = params[:user_id]
    type = params[:holiday_type]
    apply_days = params[:apply_days].to_i
    apply_hours = params[:apply_hours].to_i
    record_id = params[:record_id]
    rm_modified_record = record_id ? HolidayRecord.where.not(id: record_id) : HolidayRecord.all
    true_records = rm_modified_record.where(is_deleted: false).or(rm_modified_record.where(is_deleted: nil))

    result = [*start_date .. end_date].map do |date|
      apply_count = true_records.where(user_id: params[:user_id], source_id: nil)
                      .where("start_date <= ? AND end_date >= ?", date, date)
                      .count
      be_able_apply = apply_count > 0 ? false : true
      [date, be_able_apply]
    end.to_h

    date_validator = result.values.select { |k| k == false }.count <= 0

    least_validator = HolidayRecord.least_validator(user_id, type, start_date, end_date)
    only_one_validator = HolidayRecord.only_one_validator(user_id, type, start_date, end_date, true_records)
    female_validator = HolidayRecord.female_validator(user_id, type, start_date, end_date)
    birthday_date_validator = HolidayRecord.birthday_date_validator(user_id, type, start_date, end_date)

    no_roster_validator = HolidayRecord.no_roster_validator(user_id, type, start_date, end_date)
    roster_range_validator = HolidayRecord.roster_range_validator(user_id, type, start_date, end_date, start_time, end_time)

    reserved_holiday_validator, is_inside = HolidayRecord.reserved_holiday_validator(user_id, type, start_date, end_date)

    one_day_validator = HolidayRecord.one_day_validator(user_id, type, start_date, end_date)
    entry_validator = HolidayRecord.entry_validator(user_id, type, start_date, end_date)
    one_year_of_entry_validator = HolidayRecord.one_year_of_entry_validator(user_id, type, start_date, end_date)
    pass_probation_validator = HolidayRecord.pass_probation_validator(user_id, type, start_date, end_date)

    front_one_year_validator = HolidayRecord.front_one_year_validator(user_id, type, start_date, end_date)
    back_probation_validator = HolidayRecord.back_probation_validator(user_id, type, start_date, end_date)

    surplus_validator, surplus_count = HolidayRecord.surplus_validator(user_id, type, start_date, end_date, apply_days, apply_hours, record_id)

    be_able_apply = date_validator && least_validator && only_one_validator && no_roster_validator && roster_range_validator &&
                    female_validator && birthday_date_validator && one_day_validator && reserved_holiday_validator && is_inside &&
                    entry_validator && one_year_of_entry_validator && pass_probation_validator &&
                    front_one_year_validator && back_probation_validator && surplus_validator

    final_result = result.merge(
      {
        date_validator: date_validator,
        least_validator: least_validator,
        only_one_validator: only_one_validator,
        female_validator: female_validator,
        birthday_date_validator: birthday_date_validator,
        no_roster_validator: no_roster_validator,
        roster_range_validator: roster_range_validator,
        reserved_holiday_validator: reserved_holiday_validator,
        is_inside: is_inside,
        one_day_validator: one_day_validator,
        entry_validator: entry_validator,
        one_year_of_entry_validator: one_year_of_entry_validator,
        pass_probation_validator: pass_probation_validator,
        front_one_year_validator: front_one_year_validator,
        back_probation_validator: back_probation_validator,
        surplus_validator: surplus_validator,
        surplus_count: surplus_count,
        be_able_apply: be_able_apply
      }
    )

    response_json final_result.as_json
  end

  def holiday_record_approval_for_employee
    authorize HolidayRecord
    params[:page] ||= 1
    meta = {}
    user_result = query_holiday_record_approval_for_employee

    meta['total_count'] = user_result.count
    result = user_result.page(params[:page].to_i).per(20)
    # meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    new_result = format_holiday_record_approval_for_employee(result)

    response_json new_result.as_json, meta: meta
  end

  def holiday_record_approval_for_employee_export_xlsx
    authorize HolidayRecord
    all_result = query_holiday_record_approval_for_employee
    final_result = format_holiday_record_approval_for_employee(all_result)
    language = select_language.to_s
    approval_for_employee_export_num = Rails.cache.fetch('approval_for_employee_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + approval_for_employee_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('approval_for_employee_export_number_tag', approval_for_employee_export_num+1)

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_approval_for_employee_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(
      result: JSON.parse(final_result.to_json),
      controller_name: 'HolidayRecordsController',
      table_fields_methods: 'get_approval_for_employee_table_fields',
      table_fields_args: [params[:holiday_start_date], params[:holiday_end_date]],
      my_attachment: my_attachment, sheet_name: 'ApprovalForEmployeeTable'
    )
    render json: my_attachment
  end

  def holiday_record_approval_for_type
    authorize HolidayRecord
    all_result = search_query
    type_record_map = all_result.group_by { |holiday_record| holiday_record.holiday_type }
    # types = type_record_map.keys

    result = result_of_holiday_record_approval_for_type

    # response_json typ_record_map.as_json
    response_json result.as_json
  end

  def holiday_record_approval_for_type_export_xlsx
    authorize HolidayRecord
    final_result = result_of_holiday_record_approval_for_type
    final_result_for_export = HolidayRecord.format_export(final_result)

    approval_for_type_export_num = Rails.cache.fetch('approval_for_type_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + approval_for_type_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('approval_for_type_export_number_tag', approval_for_type_export_num+1)


    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_approval_for_type_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result_for_export.to_json),controller_name: 'HolidayRecordsController', table_fields_methods: 'get_approval_for_type_table_fields', table_fields_args: [params[:holiday_start_date], params[:holiday_end_date]], my_attachment: my_attachment, sheet_name: 'ApprovalForTypeTable')
    render json: my_attachment

  end

  def holiday_surplus_query
    authorize HolidayRecord
    params[:page] ||= 1
    meta = {}

    new_result = query_surplus
    result = new_result.page(params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    fmt_result = format_surplus_result(result.as_json)

    response_json fmt_result.as_json, meta: meta
  end

  def clear_all_surplus_snapshot
    SurplusSnapshot.all.each { |ss| ss.destroy }
    response_json :ok
  end

  def remaining_holiday_until_date
    user = User.find_by(id: params[:user_id])
    date = params[:query_date].in_time_zone.to_date

    result = {}
    annual_leave_count = HolidayRecord.calc_remaining(user, 'annual_leave', date)
    sick_leave_count = HolidayRecord.calc_remaining(user, 'paid_sick_leave', date)
    paid_bonus_leave_count = HolidayRecord.calc_remaining(user, 'paid_bonus_leave', date)

    result[:annual_leave_count] = annual_leave_count
    result[:sick_leave_count] = sick_leave_count
    result[:paid_bonus_leave_count] = paid_bonus_leave_count

    response_json result.as_json
  end


  def export_xlsx_for_report
    authorize HolidayRecord
    raw_export_xlsx
  end

  def raw_export_xlsx
    all_result = search_query
    final_result = format_result(all_result.as_json(include: [], methods: []))
    holiday_record_export_num = Rails.cache.fetch('holiday_record_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + holiday_record_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('holiday_record_export_number_tag', holiday_record_export_num+1)

    is_report = params[:type] == 'report' ? true : false
    title = params[:type] == 'report' ? export_report_title : export_record_title

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'HolidayRecordsController', table_fields_methods: 'get_holiday_record_table_fields', table_fields_args: [is_report], my_attachment: my_attachment, sheet_name: 'HolidayRecordTable')
    render json: my_attachment
  end

  def export_xlsx
    authorize HolidayRecord
    raw_export_xlsx
  end

  def holiday_surplus_query_export_xlsx
    authorize HolidayRecord
    all_result = query_surplus
    final_result = format_surplus_result(all_result.as_json)
    language = select_language.to_s
    holiday_surplus_query_export_num = Rails.cache.fetch('holiday_surplus_query_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + holiday_surplus_query_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('holiday_surplus_query_export_number_tag', holiday_surplus_query_export_num+1)

    holiday_type =  HolidayRecord.fixed_holiday_type_table.concat(HolidayRecord.reserved_holiday_type_table).select{|hash| hash[:key] == params['holiday_type']}&.first&.send(:[], select_language)
    year = params[:year].to_i
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{year}_#{holiday_type}_#{export_surplus_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'HolidayRecordsController', table_fields_methods: 'get_holiday_surplus_query_table_fields', table_fields_args: [], my_attachment: my_attachment, sheet_name: 'HolidaySurplusReportTable')
    render json: my_attachment
  end

  private
  def holiday_record_params
    params.require(:holiday_record).permit(
      :region,
      :user_id,
      :is_compensate,
      :compensate_type,
      :start_date,
      :start_time,
      :end_date,
      :end_time,
      :days_count,
      :hours_count,
      :year,
      :is_deleted,
      :creator_id,
      :comment,
      :holiday_type,
    )
  end

  def set_holiday_record
    @holiday_record = HolidayRecord.find(params[:id])
  end

  def search_query
    tag = false
    all_users = User.all.joins(:profile)
    if params[:working_status] &&  params[:status_start_date] && params[:status_end_date]
      all_users = all_users.by_working_status(params[:working_status], params[:status_start_date], params[:status_end_date])
    end
    holiday_records = HolidayRecord
                        .where(source_id: nil, user_id: all_users.ids)
                        .by_location_id(params[:location_id])
                        .by_department_id(params[:department_id])
                        .by_user(params[:user_ids])
                        .by_holiday_date(params[:holiday_start_date], params[:holiday_end_date])
                        .by_holiday_type(params[:holiday_type])
                        .by_is_deleted(params[:is_deleted])
                        .by_year(params[:year])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      default_order = "created_at DESC"
      default_order_with_self = "holiday_records.created_at DESC"

      if params[:sort_column] == 'department' || params[:sort_column] == 'position'
        holiday_records = holiday_records.includes(:user).order("users.#{params[:sort_column]}_id #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'user.empoid'
        holiday_records = holiday_records.includes(:user).order("users.empoid #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'user'
        holiday_records = holiday_records.order("user_id #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'user.date_of_employment'
        holiday_records = holiday_records.includes(user: :profile).order("profiles.data -> 'position_information' -> 'field_values' -> 'date_of_employment' #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'holiday_types'
        holiday_records = holiday_records.order("holiday_type #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'enterDate'
        holiday_records = holiday_records.order("input_date #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'enterTime'
        holiday_records = holiday_records.order("input_time #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'creator'
        holiday_records = holiday_records.order("creator_id #{params[:sort_direction]}", default_order)
      else
        holiday_records = holiday_records.order("#{params[:sort_column]} #{params[:sort_direction]}", "created_at DESC")
      end
      tag = true
    end

    holiday_records = holiday_records.order(created_at: :desc) if tag == false
    holiday_records
  end

  def format_result(json)
    json.map do |hash|
      user = hash['user_id'] ? User.find(hash['user_id']) : nil
      hash['user'] = user ?
      {
        id: hash['user_id'],
        chinese_name: user['chinese_name'],
        english_name: user['english_name'],
        simple_chinese_name: user['chinese_name'],
        empoid: user['empoid'],
        date_of_employment: user.profile.data['position_information']['field_values']['date_of_employment']
      } : nil

      profile = user ? user.profile : nil

      hash['date_of_employment'] = profile ? profile['data']['position_information']['field_values']['date_of_employment'] : ''

      department = user ? user.department : nil
      hash['department'] = department ?
      {
        id: department['id'],
        chinese_name: department['chinese_name'],
        english_name: department['english_name'],
        simple_chinese_name: department['simple_chinese_name']
      } : nil

      position = user ? user.position : nil
      hash['position'] = position ?
      {
        id: position['id'],
        chinese_name: position['chinese_name'],
        english_name: position['english_name'],
        simple_chinese_name: position['simple_chinese_name']
      } : nil

      hash['holiday_name'] = find_name_for(hash['holiday_type'], holiday_type_table)

      hash
    end
  end

  def find_name_for(type, table)
    table.select { |op| op[:key] == type }.first
  end

  def find_holiday_type_name(type)
    type_options = holiday_type_table
    type_options.select { |op| op[:key] == type }.first
  end

  def holiday_type_table
    HolidayRecord.holiday_type_table
  end

  def self.get_holiday_record_table_fields(is_report)
    empoid = {
      chinese_name: '員工編號',
      english_name: 'empoid',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        # user = User.find(rst["user_id"])
        # user["empoid"].rjust(8, '0')
        rst["user"][:empoid]&.rjust(8, '0')
      }
    }

    name = {
      chinese_name: '員工姓名',
      english_name: 'Name',
      simple_chinese_name: '员工姓名',
      get_value: -> (rst, options){
        rst["user"][options[:name_key]]
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

    is_compensate = {
      chinese_name: '是否補薪',
      english_name: 'Is Compensate',
      simple_chinese_name: '是否补薪',
      get_value: -> (rst, options){
        rst['is_compensate'] ? '是' : '否'
      }
    }

    holiday_type = {
      chinese_name: '假期類型',
      english_name: 'Holiday Type',
      simple_chinese_name: '假期类型',
      get_value: -> (rst, options){
        rst['holiday_name'] ? rst['holiday_name'][options[:name_key]] : ''
      }
    }


    start_date = {
      chinese_name: '休假開始日期',
      english_name: 'Start date',
      simple_chinese_name: '休假开始日期',
      get_value: -> (rst, options){
        rst['start_date'] ? rst['start_date'] : ''
      }
    }

    start_time = {
      chinese_name: '休假開始時間',
      english_name: 'Start time',
      simple_chinese_name: '休假开始时间',
      get_value: -> (rst, options){
        rst['start_time'] ? Time.zone.parse(rst['start_time']).strftime("%H:%M:%S") : ''
      }
    }

    end_date = {
      chinese_name: '休假結束日期',
      english_name: 'End date',
      simple_chinese_name: '休假结束日期',
      get_value: -> (rst, options){
        rst['end_date'] ? rst['end_date'] : ''
      }
    }

    end_time = {
      chinese_name: '休假結束時間',
      english_name: 'End time',
      simple_chinese_name: '休假结束时间',
      get_value: -> (rst, options){
        rst['end_time'] ? Time.zone.parse(rst['end_time']).strftime("%H:%M:%S") : ''
      }
    }

    days_count = {
      chinese_name: '休假天數',
      english_name: 'Days',
      simple_chinese_name: '休假天数',
      get_value: -> (rst, options){
        rst['days_count'] ? rst['days_count'] : ''
      }
    }

    hours_count = {
      chinese_name: '休假小時數',
      english_name: 'Hours',
      simple_chinese_name: '休假小时数',
      get_value: -> (rst, options){
        rst['hours_count'] ? rst['hours_count'] : ''
      }
    }

    comment = {
      chinese_name: '備註',
      english_name: 'Remarks',
      simple_chinese_name: '备注',
      get_value: -> (rst, options){
        rst['comment'] ? rst["comment"] : ''
      }
    }

    year = {
      chinese_name: '休假年度',
      english_name: 'Year',
      simple_chinese_name: '休假年度',
      get_value: -> (rst, options){
        rst['year'] ? rst['year'] : ''
      }
    }

    input_date = {
      chinese_name: '錄入日期',
      english_name: 'Input Date',
      simple_chinese_name: '录入时间',
      get_value: -> (rst, options){
        rst['input_date'] ? rst["input_date"] : ''
      }
    }

    input_time = {
      chinese_name: '錄入時間',
      english_name: 'Input Time',
      simple_chinese_name: '录入时间',
      get_value: -> (rst, options){
        rst['input_time'] ? rst["input_time"] : ''
      }
    }

    creator = {
      chinese_name: '錄入人',
      english_name: 'Inputter',
      simple_chinese_name: '录入人',
      get_value: -> (rst, options){
        ans = ""
        if rst['creator_id']
          user = User.find_by(id: rst['creator_id'])
          name = user ? user[options[:name_key]] : ''
          empoid = user ? user.empoid : ''
          ans = "#{name} (#{empoid})"
        end
        ans
      }
    }

    tmp_table_fields = [empoid, name, department, position, entry_date, is_compensate,
                        holiday_type, start_date, start_time, end_date, end_time, days_count,
                    hours_count, comment, year]

    input_table_fields = [input_date, input_time, creator]
    table_fields = is_report ? tmp_table_fields + input_table_fields : tmp_table_fields

  end

  def export_record_title
    if select_language.to_s == 'chinese_name'
      '假期記錄'
    elsif select_language.to_s == 'english_name'
      'Holiday Records'
    else
      '假期记录'
    end
  end

  def export_report_title
    if select_language.to_s == 'chinese_name'
      '假期報表'
    elsif select_language.to_s == 'english_name'
      'Holiday Report'
    else
      '假期报表'
    end
  end

  def query_surplus
    query = User.all
    query_with_department = params[:department_id] ? query.where(department_id: params[:department_id]) : query
    user_result = params[:user_ids] ? query_with_department.where(id: params[:user_ids]) : query_with_department

    user_result.each do |u|
      hsr = HolidaySurplusReport.find_or_create_by(user_id: u.id)
      if params[:holiday_type] && params[:year]
        hsr.last_year_surplus = HolidayRecord.calc_last_year_surplus(u, params[:holiday_type], params[:year].to_i)
        hsr.total = HolidayRecord.calc_total(u, params[:holiday_type], params[:year].to_i)
        hsr.used =  HolidayRecord.calc_used(u, params[:holiday_type], params[:year].to_i)
        hsr.surplus = HolidayRecord.calc_surplus(u, params[:holiday_type], params[:year].to_i)
        hsr.save
      end
      hsr.save
    end

    new_result = HolidaySurplusReport.where(user_id: user_result.pluck(:id))

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'
      if params[:sort_column] == 'department' || params[:sort_column] == 'position'
        new_result = new_result.includes(:user).order("users.#{params[:sort_column]}_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user.empoid'
        new_result = new_result.includes(:user).order("users.empoid #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user.employment_status'
        new_result = new_result.includes(:user).order("users.employment_status #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user'
        new_result = new_result.order("user_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'date_of_employment'
        new_result = new_result.includes(user: :profile).order("profiles.data -> 'position_information' -> 'field_values' -> 'date_of_employment' #{params[:sort_direction]}")
      else
        new_result = new_result.order("#{params[:sort_column]} #{params[:sort_direction]}")
      end
    else
      new_result = new_result.includes(:user).order("users.empoid asc")
    end
    new_result
  end

  def format_surplus_result(json)
    json.map do |hash|
      user = hash['user_id'] ? User.find(hash['user_id']) : nil
      hash['user'] = user ? user : nil

      profile = user ? user.profile : nil
      hash['date_of_employment'] = profile ? profile['data']['position_information']['field_values']['date_of_employment'] : ''

      department = user ? user.department : nil
      hash['department'] = department ? department : nil
      position = user ? user.position : nil
      hash['position'] = position ? position : nil
      hash
    end
  end

  def self.get_holiday_surplus_query_table_fields
    empoid = {
      chinese_name: '員工編號',
      english_name: 'empoid',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        # user = User.find(rst["user_id"])
        # user["empoid"].rjust(8, '0')
        rst["user"][:empoid]&.rjust(8, '0')
      }
    }

    name = {
      chinese_name: '員工姓名',
      english_name: 'Name',
      simple_chinese_name: '员工姓名',
      get_value: -> (rst, options){
        rst["user"][options[:name_key]]
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

    employment_status = {
      chinese_name: '在職類別',
      english_name: 'Employment Status',
      simple_chinese_name: '在职类别',
      get_value: -> (rst, options){
        ans = ''
        if rst['user']
          ops = Config.get('selects')['employment_status']['options']
          op = ops.select { |o| o["key"] == rst['user']['employment_status'] }.first
          ans = op[options[:name_key].to_s]
        end
        ans
      }
    }

    last_year_surplus = {
      chinese_name: '上年結餘天數',
      english_name: 'Last Year Surplus',
      simple_chinese_name: '上年结余天数',
      get_value: -> (rst, options){
        rst['last_year_surplus'] ? rst["last_year_surplus"] : ''
      }
    }

    total = {
      chinese_name: '本年享有天數',
      english_name: 'Total',
      simple_chinese_name: '本年享有天数',
      get_value: -> (rst, options){
        rst['total'] ? rst["total"] : ''
      }
    }

    used = {
      chinese_name: '本年已休天數',
      english_name: 'Used',
      simple_chinese_name: '本年已休天数',
      get_value: -> (rst, options){
        rst['used'] ? rst["used"] : ''
      }
    }

    surplus = {
      chinese_name: '本年結餘天數',
      english_name: 'Surplus',
      simple_chinese_name: '本年结余天数',
      get_value: -> (rst, options){
        rst['surplus'] ? rst["surplus"] : ''
      }
    }

    table_fields = [empoid, name, department, position, employment_status,
                    last_year_surplus, total, used, surplus]


  end

  def export_surplus_title
    if select_language.to_s == 'chinese_name'
      '結餘查詢報表'
    elsif select_language.to_s == 'english_name'
      'Holiday Surplus Report'
    else
      '结余查询报表'
    end
  end

  def query_holiday_record_approval_for_employee
    user_query = User
    user_query_with_location = params[:location_id] ? user_query.where(location_id: params[:location_id]) : user_query
    user_query_with_department = params[:department_id] ? user_query_with_location.where(department_id: params[:department_id]) : user_query_with_location
    user_result = params[:user_ids] ? user_query_with_department.where(id: params[:user_ids]) : user_query_with_department

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      if params[:sort_column] == 'department'
        user_result = user_result.order("department_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'position'
        user_result = user_result.order("position_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user.empoid'
        user_result = user_result.order("empoid #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user'
        user_result = user_result.order("id #{params[:sort_direction]}")
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

  def format_holiday_record_approval_for_employee(result)
    all_result = HolidayRecord.where(source_id: nil)
    group_map = all_result.group_by { |holiday_record| holiday_record.user_id  }

    new_result = result.pluck(:id).map do |user_id|
      user = User.find(user_id)
      if user && params[:holiday_start_date] && params[:holiday_end_date]
        department = user.department_id ? Department.find(user.department_id) : nil
        position = user.position_id ? Position.find(user.position_id) : nil
        start_date = params[:holiday_start_date].in_time_zone.to_date
        end_date = params[:holiday_end_date].in_time_zone.to_date
        # holiday_object = {
        #   key: 'fake_key',
        #   chinese_name: 'fake_chinese_name',
        #   english_name: 'fake_english_name',
        #   simple_chinese_name: 'fake_simple_chinese_name',
        # }
        date_result = (start_date .. end_date).map do |date|
          type = HolidayRecord.find_holiday_type_in_date(user.id, date)
          holiday_object = find_name_for(type, holiday_type_table)
          [date, holiday_object]
        end.to_h

        date_result.merge({
                            user: user,
                            department: department,
                            position: position,
                            holidays: group_map[user.id]
                          })
      end
    end

    new_result
  end

  def self.get_approval_for_employee_table_fields(holiday_start_date, holiday_end_date)
    start_date = holiday_start_date.in_time_zone.to_date
    end_date = holiday_end_date.in_time_zone.to_date
    days = (start_date..end_date)
    empoid = {
      chinese_name: '員工編號',
      english_name: 'empoid',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        rst[:user][:empoid]&.rjust(8, '0')
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

    table_fields = [
      empoid, name, department, position
    ].concat(days.map do |day|
               {
                 chinese_name: day,
                 english_name: day,
                 simple_chinese_name: day,
                 get_value: -> (rst, options) {
                   rst[day.strftime("%Y-%m-%d")] ? rst[day.strftime("%Y-%m-%d")][options[:name_key]] : ''
                 }
               }
             end)


  end

  def export_approval_for_employee_title
    if select_language.to_s == 'chinese_name'
      '假期審批'
    elsif select_language.to_s == 'english_name'
      'Approval For Employee'
    else
      '假期审批'
    end
  end

  def result_of_holiday_record_approval_for_type
    start_date = params[:holiday_start_date] ? params[:holiday_start_date].in_time_zone.to_date : params[:holiday_start_date]
    end_date = params[:holiday_end_date] ? params[:holiday_end_date].in_time_zone.to_date : params[:holiday_end_date]

    all_types = holiday_type_table
    types = (params[:holiday_types] == nil || params[:holiday_types].to_a.empty?) ?
              all_types :
              params[:holiday_types].map { |type_key| all_types.select { |t| t[:key] == type_key }.first }

    result = types.map do |type|
      if start_date && end_date
        (start_date .. end_date).map { |date| [date, HolidayRecord.find_holiday_count_in_date(type, date)] }.to_h.merge({type: type})
      end
    end

    result
  end

  def self.get_approval_for_type_table_fields(holiday_start_date, holiday_end_date)
    start_date = holiday_start_date.in_time_zone.to_date
    end_date = holiday_end_date.in_time_zone.to_date
    days = (start_date..end_date)


    type = {
      chinese_name: '假期類別',
      english_name: 'Holiday Type',
      simple_chinese_name: '假期类别',
      get_value: -> (rst, options){
        rst[:type] && rst[:approval_type] ? "#{rst[:type][options[:name_key]]} (#{rst[:approval_type][options[:name_key]]})" : ''
      }
    }

    table_fields = [
      type
    ].concat(days.map do |day|
               {
                 chinese_name: day,
                 english_name: day,
                 simple_chinese_name: day,
                 get_value: -> (rst, options) {
                   rst[day.strftime("%Y-%m-%d")] && rst[:approval_type][:key] == 'approved' ? rst[day.strftime("%Y-%m-%d")] : '0'
                 }
               }
             end)


  end

  def export_approval_for_type_title
    if select_language.to_s == 'chinese_name'
      '假期審批按類別統計報表'
    elsif select_language.to_s == 'english_name'
      'Approval For Type'
    else
      '假期审批按类别统计报表'
    end
  end
end
