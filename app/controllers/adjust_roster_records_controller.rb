# coding: utf-8
class AdjustRosterRecordsController < ApplicationController
  include GenerateXlsxHelper
  include DownloadActionAble
  before_action :set_adjust_roster_record, only: [:show, :destroy]

  def index
    authorize AdjustRosterRecord
    params[:page] ||= 1
    meta = {}
    all_result = search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    final_result = format_result(result.as_json(include: {
                                                  roster_a: {include: [:class_setting]},
                                                  roster_b: {include: [:class_setting]},
                                                }, methods: []))

    response_json final_result, meta: meta
  end

  def raw_show
    result = @adjust_roster_record.as_json(
      include: {
        approval_items: {include: {user: {include: [:department, :location, :position ]}}},
        attend_attachments: {include: :creator},
        creator: {include: [:department, :location, :position ], methods: [:date_of_employment]},
        user_a: {include: [:department, :location, :position ], methods: [:date_of_employment]},
        user_b: {include: [:department, :location, :position ], methods: [:date_of_employment]},
        roster_a: {include: [:class_setting]},
        roster_b: {include: [:class_setting]},
      }
    )

    response_json result
  end

  def show
    authorize AdjustRosterRecord
    raw_show
  end

  def create
    authorize AdjustRosterRecord
    ActiveRecord::Base.transaction do
      raise LogicError, {id: 422, message: '参数不完整'}.to_json unless adjust_roster_record_params
      if params[:adjust_items]
        result = []
        params[:adjust_items].each do |item|
          ar = AdjustRosterRecord.create(item.permit(
                                           :region,
                                           :user_a_id,
                                           :user_b_id,
                                           :user_a_adjust_date,
                                           :user_b_adjust_date,
                                           :user_a_roster_id,
                                           :user_b_roster_id,
                                           :apply_type,
                                           :is_director_special_approval,
                                           :special_approver,
                                           :is_deleted,
                                           :comment,
                                           :creator_id,
                                         ))

          roster_object_a = RosterObject.find_by(id: item['user_a_roster_id'])
          raise LogicError, {id: 422, message: '找不到数据'}.to_json unless roster_object_a
          roster_object_b = RosterObject.find_by(id: item['user_b_roster_id'])
          raise LogicError, {id: 422, message: '找不到数据'}.to_json unless roster_object_b

          if roster_object_a && roster_object_b
            roster_object_a.class_setting_id, roster_object_b.class_setting_id = roster_object_b.class_setting_id, roster_object_a.class_setting_id
            roster_object_a.is_general_holiday, roster_object_b.is_general_holiday = roster_object_b.is_general_holiday, roster_object_a.is_general_holiday
            roster_object_a.working_time, roster_object_b.working_time = roster_object_b.working_time, roster_object_a.working_time

            roster_object_a.adjust_type = ar.apply_type
            roster_object_b.adjust_type = ar.apply_type
            roster_object_a.save
            roster_object_b.save

            roster_object_a.roster_object_logs.create(modified_reason: "adjust_#{ar.apply_type}",
                                                      approver_id: current_user.id,
                                                      approval_time: Time.zone.now.to_datetime,
                                                      is_general_holiday: roster_object_a.is_general_holiday,
                                                      class_setting_id: roster_object_a.class_setting_id,
                                                      working_time: roster_object_a.working_time)

            roster_object_b.roster_object_logs.create(modified_reason: "adjust_#{ar.apply_type}",
                                                      approver_id: current_user.id,
                                                      approval_time: Time.zone.now.to_datetime,
                                                      is_general_holiday: roster_object_b.is_general_holiday,
                                                      class_setting_id: roster_object_b.class_setting_id,
                                                      working_time: roster_object_b.working_time)

            inactive_ro_a = RosterObject.where(user_id: roster_object_a.user_id, roster_date: roster_object_a.roster_date, is_active: 'inactive').first
            if inactive_ro_a
              inactive_ro_a.class_setting_id = roster_object_a.class_setting_id
              inactive_ro_a.is_general_holiday = roster_object_a.is_general_holiday
              inactive_ro_a.working_time = roster_object_a.working_time
              inactive_ro_a.adjust_type = ar.apply_type
              inactive_ro_a.save
            end

            inactive_ro_b = RosterObject.where(user_id: roster_object_b.user_id, roster_date: roster_object_b.roster_date, is_active: 'inactive').first
            if inactive_ro_b
              inactive_ro_b.class_setting_id = roster_object_b.class_setting_id
              inactive_ro_b.is_general_holiday = roster_object_b.is_general_holiday
              inactive_ro_b.working_time = roster_object_b.working_time
              inactive_ro_b.adjust_type = ar.apply_type
              inactive_ro_b.save
            end

            # ar.user_a_roster_id, ar.user_b_roster_id = ar.user_b_roster_id, ar.user_a_roster_id
            # ar.save
          end

          # attend state
          att_a = Attend.find_attend_by_user_and_date(ar.user_a_id, ar.user_a_adjust_date)
          att_b = Attend.find_attend_by_user_and_date(ar.user_b_id, ar.user_b_adjust_date)

          [att_a, att_b].each.with_index do |att, index|
            user_id = index == 0 ? ar.user_a_id : ar.user_b_id
            date = index == 0 ? ar.user_a_adjust_date : ar.user_b_adjust_date

            if att == nil
              att = Attend.create(user_id: user_id,
                                  attend_date: date,
                                  attend_weekday: date.wday
                                 )
            end

            att.attend_states.create(state: AdjustRosterRecord.return_attend_state_type(ar.id),
                                     record_type: 'adjust_roster_record',
                                     record_id: ar.id
                                    )

            # attend log
            att.attend_logs.create(user_id: user_id,
                                   apply_type: 'adjust_roster',
                                   type_id: ar.id,
                                   logger_id: current_user.id
                                  )
            if user_id == ar.user_a_id
              RosterObject.update_attend_and_states(roster_object_a)
            elsif user_id == ar.user_b_id
              RosterObject.update_attend_and_states(roster_object_b)
            end
          end
          raise LogicError, {id: 422, message: '参数不完整'}.to_json if params[:approval_items][:user_id] && params[:approval_items][:datetime] && params[:approval_items][:comment]
          if params[:approval_items]

            params[:approval_items].each do |approval_item|
              ar.approval_items.create(approval_item.permit(:user_id, :datetime, :comment))
            end
          end
          raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:attend_attachments][:file_name]
          if params[:attend_attachments]

            params[:attend_attachments].each do |attend_attachment|
              ar.attend_attachments.create(attend_attachment.permit(:file_name, :comment, :attachment_id, :creator_id))
            end
          end

          AttendMonthlyReport.update_calc_status(ar.user_a_id, ar.user_a_adjust_date)
          AttendAnnualReport.update_calc_status(ar.user_a_id, ar.user_a_adjust_date)

          AttendMonthlyReport.update_calc_status(ar.user_b_id, ar.user_b_adjust_date)
          AttendAnnualReport.update_calc_status(ar.user_b_id, ar.user_b_adjust_date)

          [ar.user_a_adjust_date, ar.user_b_adjust_date].compact.uniq.map { |r_d| r_d.strftime("%Y/%m") }.compact.uniq.map do |d_str|
            y = d_str.split("/").first.to_i
            m = d_str.split("/").second.to_i
            Time.zone.local(y, m, 1).to_date
          end.each { |ro_d| AttendMonthApproval.update_data(ro_d) }

          result << ar.id
        end
      end

      if result.empty?
        response_json :ok
      else
        response_json result.first
      end
    end
  end

  def destroy
    authorize AdjustRosterRecord
    ActiveRecord::Base.transaction do
      updated_adjust_roster_record = @adjust_roster_record.update(is_deleted: true)

      @adjust_roster_record.user_a_roster_id, @adjust_roster_record.user_b_roster_id = @adjust_roster_record.user_b_roster_id, @adjust_roster_record.user_a_roster_id
      @adjust_roster_record.save

      roster_object_a = RosterObject.find_by(id: @adjust_roster_record.user_a_roster_id)
      roster_object_b = RosterObject.find_by(id: @adjust_roster_record.user_b_roster_id)

      if roster_object_a && roster_object_b
        roster_object_a.class_setting_id, roster_object_b.class_setting_id = roster_object_b.class_setting_id, roster_object_a.class_setting_id
        roster_object_a.is_general_holiday, roster_object_b.is_general_holiday = roster_object_b.is_general_holiday, roster_object_a.is_general_holiday
        roster_object_a.working_time, roster_object_b.working_time = roster_object_b.working_time, roster_object_a.working_time

        roster_object_a.adjust_type = nil
        roster_object_b.adjust_type = nil
        roster_object_a.save
        roster_object_b.save

        roster_object_a.roster_object_logs.create(modified_reason: "cancel_adjust_#{@adjust_roster_record.apply_type}",
                                                  approver_id: current_user.id,
                                                  approval_time: Time.zone.now.to_datetime,
                                                  is_general_holiday: roster_object_a.is_general_holiday,
                                                  class_setting_id: roster_object_a.class_setting_id,
                                                  working_time: roster_object_a.working_time)

        roster_object_b.roster_object_logs.create(modified_reason: "cancel_adjust_#{@adjust_roster_record.apply_type}",
                                                  approver_id: current_user.id,
                                                  approval_time: Time.zone.now.to_datetime,
                                                  is_general_holiday: roster_object_b.is_general_holiday,
                                                  class_setting_id: roster_object_b.class_setting_id,
                                                  working_time: roster_object_b.working_time)

        inactive_ro_a = RosterObject.where(user_id: roster_object_a.user_id, roster_date: roster_object_a.roster_date, is_active: 'inactive').first
        if inactive_ro_a
          inactive_ro_a.class_setting_id = roster_object_a.class_setting_id
          inactive_ro_a.is_general_holiday = roster_object_a.is_general_holiday
          inactive_ro_a.working_time = roster_object_a.working_time
          inactive_ro_a.adjust_type = nil
          inactive_ro_a.save
        end

        inactive_ro_b = RosterObject.where(user_id: roster_object_b.user_id, roster_date: roster_object_b.roster_date, is_active: 'inactive').first
        if inactive_ro_b
          inactive_ro_b.class_setting_id = roster_object_b.class_setting_id
          inactive_ro_b.is_general_holiday = roster_object_b.is_general_holiday
          inactive_ro_b.working_time = roster_object_b.working_time
          inactive_ro_b.adjust_type = nil
          inactive_ro_b.save
        end
      end

      att_states = AttendState.where(record_type: 'adjust_roster_record', record_id: @adjust_roster_record.id)
      att_states.each { |state| state.destroy if state }
      att_logs = AttendLog.where(apply_type: 'adjust_roster', type_id: @adjust_roster_record.id)
      att_logs.each { |log| log.destroy if log }

      AttendMonthlyReport.update_calc_status(@adjust_roster_record.user_a_id, @adjust_roster_record.user_a_adjust_date)
      AttendAnnualReport.update_calc_status(@adjust_roster_record.user_a_id, @adjust_roster_record.user_a_adjust_date)

      AttendMonthlyReport.update_calc_status(@adjust_roster_record.user_b_id, @adjust_roster_record.user_b_adjust_date)
      AttendAnnualReport.update_calc_status(@adjust_roster_record.user_b_id, @adjust_roster_record.user_b_adjust_date)

      [@adjust_roster_record.user_a_adjust_date, @adjust_roster_record.user_b_adjust_date].compact.uniq.map { |r_d| r_d.strftime("%Y/%m") }.compact.uniq.map do |d_str|
        y = d_str.split("/").first.to_i
        m = d_str.split("/").second.to_i
        Time.zone.local(y, m, 1).to_date
      end.each { |ro_d| AttendMonthApproval.update_data(ro_d) }

      response_json updated_adjust_roster_record
    end
  end

  def report
    authorize AdjustRosterRecord
    params[:page] ||= 1
    meta = {}

    new_result = query_report

    result = new_result.page(params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    fmt_result = format_report_result(result.as_json)
    response_json fmt_result.as_json, meta: meta
  end

  def report_export_xlsx
    authorize AdjustRosterRecord
    all_result = query_report
    final_result = format_report_result(all_result.as_json)
    adjust_roster_report_export_num = Rails.cache.fetch('adjust_roster_report_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + adjust_roster_report_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('adjust_roster_report_export_number_tag', adjust_roster_report_export_num+1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_report_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json), controller_name: 'AdjustRosterRecordsController', table_fields_methods: 'get_adjust_roster_report_table_fields', table_fields_args: [], my_attachment: my_attachment)
    render json: my_attachment
  end

  def be_able_apply
    user_a_adjust_date = params[:user_a_adjust_date].in_time_zone.to_date
    user_b_adjust_date = params[:user_b_adjust_date].in_time_zone.to_date

    a_start_date = user_a_adjust_date.beginning_of_month
    a_end_date = user_a_adjust_date.end_of_month

    b_start_date = user_b_adjust_date.beginning_of_month
    b_end_date = user_b_adjust_date.end_of_month

    true_records = AdjustRosterRecord.where(is_deleted: false).or(AdjustRosterRecord.where(is_deleted: nil))

    apply_count_a_as_a = true_records.where(user_a_id: params[:user_a_id], user_a_adjust_date: user_a_adjust_date).count
    apply_count_a_as_b = true_records.where(user_b_id: params[:user_a_id], user_a_adjust_date: user_a_adjust_date).count

    apply_count_b_as_a = true_records.where(user_a_id: params[:user_b_id], user_b_adjust_date: user_b_adjust_date).count
    apply_count_b_as_b = true_records.where(user_b_id: params[:user_b_id], user_b_adjust_date: user_b_adjust_date).count

    is_special = params[:is_special]

    is_for_class = params[:is_for_class]
    for_class_count = (is_for_class == true || is_for_class == 'true') ? 1 : 0
    for_holiday_count = (is_for_class == false || is_for_class == 'false') ? 1 : 0

    a_date_be_able_apply = apply_count_a_as_a + apply_count_a_as_b > 0 ? false : true
    b_date_be_able_apply = apply_count_b_as_a + apply_count_b_as_b > 0 ? false : true

    adjust_roster_records = true_records.where.not(is_director_special_approval: true)

    user_a_adjust_class_count = adjust_roster_records.where(user_a_id: params[:user_a_id], apply_type: 'for_class', user_a_adjust_date: a_start_date..a_end_date).count
    user_a_adjust_holiday_count = adjust_roster_records.where(user_a_id: params[:user_a_id], apply_type: 'for_holiday', user_a_adjust_date: a_start_date..a_end_date).count

    a_class_count_be_able_apply = user_a_adjust_class_count + for_class_count > 4 ? false : true
    a_holiday_count_be_able_apply = user_a_adjust_holiday_count + for_holiday_count > 2 ? false : true
    a_total_count_be_able_apply = user_a_adjust_class_count + user_a_adjust_holiday_count + for_class_count + for_holiday_count > 4 ? false : true

    user_b_adjust_class_count = adjust_roster_records.where(user_b_id: params[:user_b_id], apply_type: 'for_class', user_b_adjust_date: b_start_date..b_end_date).count
    user_b_adjust_holiday_count = adjust_roster_records.where(user_b_id: params[:user_b_id], apply_type: 'for_holiday', user_b_adjust_date: b_start_date..b_end_date).count

    b_class_count_be_able_apply = user_b_adjust_class_count + for_class_count > 4 ? false : true
    b_holiday_count_be_able_apply = user_b_adjust_holiday_count + for_holiday_count > 2 ? false : true
    b_total_count_be_able_apply = user_b_adjust_class_count + user_b_adjust_holiday_count + for_class_count + for_holiday_count > 4 ? false : true

    result = {
      "#{user_a_adjust_date}" => a_date_be_able_apply && b_date_be_able_apply,
      "#{user_b_adjust_date}" => b_date_be_able_apply && a_date_be_able_apply,
      a_class_count: a_class_count_be_able_apply || is_special,
      a_holiday_count: a_holiday_count_be_able_apply || is_special,
      a_total_count: a_total_count_be_able_apply || is_special,
      b_class_count: b_class_count_be_able_apply || is_special,
      b_holiday_count: b_holiday_count_be_able_apply || is_special,
      b_total_count: b_total_count_be_able_apply || is_special,
    }

    final_result = result.merge(
      {
        be_able_apply: result.values.select { |k| k == false || k == "false" }.count <= 0
      }
    )
    response_json final_result.as_json
  end

  def options
    result = {}

    result[:apply_types] = apply_type_table

    response_json result.as_json
  end

  def export_xlsx
    authorize AdjustRosterRecord
    all_result = search_query
    final_result = format_result(all_result.as_json(include: [], methods: []))
    adjust_roster_record_export_num = Rails.cache.fetch('adjust_roster_record_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + adjust_roster_record_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('adjust_roster_record_export_number_tag', adjust_roster_record_export_num+1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json), controller_name: 'AdjustRosterRecordsController', table_fields_methods: 'get_adjust_roster_record_table_fields', table_fields_args: [], my_attachment: my_attachment)
    render json: my_attachment
  end

  private

  def adjust_roster_record_params
    params.require(:adjust_roster_record).permit(
      :region,
      :user_a_id,
      :user_b_id,
      :user_a_adjust_date,
      :user_b_adjust_date,
      :user_a_roster_id,
      :user_b_roster_id,
      :apply_type,
      :is_director_special_approval,
      :is_deleted,
      :comment,
      :creator_id,
    )
  end

  def set_adjust_roster_record
    @adjust_roster_record = AdjustRosterRecord.find(params[:id])
  end

  def search_query
    tag = false
    # region = params[:region] || 'macau'

    adjust_roster_records = AdjustRosterRecord
                              .by_location_id(params[:location_id])
                              .by_department_id(params[:department_id])
                              .by_user(params[:user_ids])
                              .by_apply_type(params[:apply_type])
                              .by_is_deleted(params[:is_deleted])
                              .by_adjust_date(params[:adjust_date])
    # .by_adjust_date(params[:adjust_start_date], params[:adjust_end_date])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      if params[:sort_column] == 'empoid' || params[:sort_column] == 'department_id' || params[:sort_column] == 'position_id'
      # adjust_roster_records = adjust_roster_records.includes(:user).order("users.#{params[:sort_column]} #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user_a'
        adjust_roster_records = adjust_roster_records.order("user_a_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user_b'
        adjust_roster_records = adjust_roster_records.order("user_b_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user_a.empoid'
        adjust_roster_records = adjust_roster_records.includes(:user_a).order("users.empoid #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user_b.empoid'
        adjust_roster_records = adjust_roster_records.includes(:user_b).order("users.empoid #{params[:sort_direction]}")
      elsif params[:sort_column] == 'department_a' || params[:sort_column] == 'position_a'
        field = "#{params[:sort_column].split('_').first}_id"
        adjust_roster_records = adjust_roster_records.includes(:user_a).order("users.#{field} #{params[:sort_direction]}")
      elsif params[:sort_column] == 'department_b' || params[:sort_column] == 'position_b'
        field = "#{params[:sort_column].split('_').first}_id"
        adjust_roster_records = adjust_roster_records.includes(:user_b).order("users.#{field} #{params[:sort_direction]}")
      elsif params[:sort_column] == 'apply_type_name'
        adjust_roster_records = adjust_roster_records.order("apply_type #{params[:sort_direction]}")

      elsif params[:sort_column] == 'roster_a.class_setting.display_name'
        adjust_roster_records = adjust_roster_records.includes(:roster_a).order("roster_objects.class_setting_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'roster_b.class_setting.display_name'
        adjust_roster_records = adjust_roster_records.includes(:roster_b).order("roster_objects.class_setting_id #{params[:sort_direction]}")

      elsif params[:sort_column] == 'roster_a.class_setting.start_time'
        adjust_roster_records = adjust_roster_records.includes(:roster_a).order("roster_objects.class_setting_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'roster_b.class_setting.start_time'
        adjust_roster_records = adjust_roster_records.includes(:roster_b).order("roster_objects.class_setting_id #{params[:sort_direction]}")

      elsif params[:sort_column] == 'status'
      else
        adjust_roster_records = adjust_roster_records.order("#{params[:sort_column]} #{params[:sort_direction]}")
      end
      tag = true
    end

    adjust_roster_records = adjust_roster_records.order(created_at: :desc) if tag == false
    adjust_roster_records
  end

  def format_result(json)
    json.map do |hash|
      user_a = hash['user_a_id'] ? User.find(hash['user_a_id']) : nil
      hash['user_a'] = user_a ?
      {
        id: hash['user_a_id'],
        chinese_name: user_a['chinese_name'],
        english_name: user_a['english_name'],
        simple_chinese_name: user_a['chinese_name'],
        empoid: user_a['empoid'],
      } : nil

      department_a = user_a ? user_a.department : nil
      hash['department_a'] = department_a ?
      {
        id: department_a['id'],
        chinese_name: department_a['chinese_name'],
        english_name: department_a['english_name'],
        simple_chinese_name: department_a['chinese_name']
      } : nil

      position_a = user_a ? user_a.position : nil
      hash['position_a'] = position_a ?
      {
        id: position_a['id'],
        chinese_name: position_a['chinese_name'],
        english_name: position_a['english_name'],
        simple_chinese_name: position_a['chinese_name']
      } : nil


      user_b = hash['user_b_id'] ? User.find(hash['user_b_id']) : nil
      hash['user_b'] = user_b ?
      {
        id: hash['user_b_id'],
        chinese_name: user_b['chinese_name'],
        english_name: user_b['english_name'],
        simple_chinese_name: user_b['chinese_name'],
        empoid: user_b['empoid'],
      } : nil

      department_b = user_b ? user_b.department : nil
      hash['department_b'] = department_b ?
      {
        id: department_b['id'],
        chinese_name: department_b['chinese_name'],
        english_name: department_b['english_name'],
        simple_chinese_name: department_b['chinese_name']
      } : nil

      position_b = user_b ? user_b.position : nil
      hash['position_b'] = position_b ?
      {
        id: position_b['id'],
        chinese_name: position_b['chinese_name'],
        english_name: position_b['english_name'],
        simple_chinese_name: position_b['chinese_name']
      } : nil


      # general_holiday = {
      #   name: '公休',
      #   display_name: '公休',
      # }

      # roster_a = RosterObject.find_by(id: hash['user_a_roster_id'])
      # if roster_a
      #   hash['roster_a'] = roster_a.is_general_holiday ? general_holiday : ClassSetting.find(roster_a.class_setting_id)
      # else
      #   hash['roster_a'] = nil
      # end

      # roster_b = RosterObject.find_by(id: hash['user_b_roster_id'])
      # if roster_b
      #   hash['roster_b'] = roster_b.is_general_holiday ? general_holiday : ClassSetting.find(roster_b.class_setting_id)
      # else
      #   hash['roster_b'] = nil
      # end

      hash['apply_type_name'] = find_name_for(hash['apply_type'], apply_type_table)

      hash
    end
  end

  def query_report
    user_query = User.all
    user_query_with_department = params[:department_id] ? user_query.where(department_id: params[:department_id]) : user_query
    user_result = params[:user_ids] ? user_query_with_department.where(id: params[:user_ids]) : user_query_with_department
    user_result.each do |u|
      arr = AdjustRosterReport.find_or_create_by(user_id: u.id)
      if params[:start_date] && params[:end_date]
        now = Time.zone.now.to_datetime
        if ((now - arr.updated_at.to_datetime) * 24 * 60) >= 1
          start_date = params[:start_date].in_time_zone.to_date
          end_date = params[:end_date].in_time_zone.to_date
          rst = AdjustRosterRecord.return_statistics_for(u.id, start_date, end_date)

          ["not_special", "not_special_for_class", "not_special_for_holiday",
           "special", "special_for_class", "special_for_holiday"].each do |k|
            arr.send("#{k}=".to_sym, rst[k.to_sym])
          end
          arr.save
        end
      end
      arr.save
    end

    new_result = AdjustRosterReport.where(user_id: user_result.pluck(:id))

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'
      if params[:sort_column] == 'department' || params[:sort_column] == 'position'
        new_result = new_result.includes(:user).order("users.#{params[:sort_column]}_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user.empoid'
        new_result = new_result.includes(:user).order("users.empoid #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user'
        new_result = new_result.order("user_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'date_of_employment'
        new_result = new_result.includes(user: :profile).order("profiles.data -> 'position_information' -> 'field_values' -> 'date_of_employment' #{params[:sort_direction]}")
      else
        new_result = new_result.order("#{params[:sort_column]} #{params[:sort_direction]}")
      end
    else
      # new_result = new_result.order(created_at: :desc)
      new_result = new_result.includes(:user).order("users.empoid asc")
    end

    new_result
  end

  def format_report_result(json)
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

  def find_name_for(type, table)
    table.select { |op| op[:key] == type }.first
  end

  def find_apply_type_name(type)
    type_options = apply_type_table
    type_options.select { |op| op[:key] == type }.first
  end

  def apply_type_table
    [
      {
        key: 'for_class',
        chinese_name: '調更',
        english_name: 'For Class',
        simple_chinese_name: '调更',
      },

      {
        key: 'for_holiday',
        chinese_name: '調假',
        english_name: 'For Holiday',
        simple_chinese_name: '调假',
      },
    ]
  end

  def self.get_adjust_roster_record_table_fields
    empoid_a = {
      chinese_name: '員工編號（甲方）',
      english_name: 'Empoid A',
      simple_chinese_name: '员工编号（甲方）',
      get_value: -> (rst, options){
        # rst["user_a"][:empoid].rjust(8, '0')
        rst["user_a"] ? "\s#{rst["user_a"][:empoid].rjust(8, '0')}" : ''
      }
    }

    name_a = {
      chinese_name: '姓名（甲方）',
      english_name: 'Name A',
      simple_chinese_name: '姓名（甲方）',
      get_value: -> (rst, options){
        # rst["user_a"][options[:name_key]]
        rst["user_a"] ? rst["user_a"][options[:name_key]] : ''
      }
    }

    department_a = {
      chinese_name: '部門（甲方）',
      english_name: 'Department A',
      simple_chinese_name: '部门（甲方）',
      get_value: -> (rst, options){
        rst['department_a'] ? rst['department_a'][options[:name_key]] : ''
      }
    }

    position_a = {
      chinese_name: '職位（甲方）',
      english_name: 'Position A',
      simple_chinese_name: '职位（甲方）',
      get_value: -> (rst, options){
        rst['position_a'] ? rst['position_a'][options[:name_key]] : ''
      }
    }


    adjust_date_a = {
      chinese_name: '調動日期（甲方）',
      english_name: 'Adjust Date A',
      simple_chinese_name: '调动日期（甲方）',
      get_value: -> (rst, options){
        rst['user_a_adjust_date'] ? rst['user_a_adjust_date'] : ''
      }
    }

    class_a = {
      chinese_name: '原更別（甲方）',
      english_name: 'Original Class A',
      simple_chinese_name: '原更别（甲方）',
      get_value: -> (rst, options){
        roster_a = RosterObject.find_by(id: rst['user_a_roster_id'])
        ans = ''
        if roster_a
          if roster_a.is_general_holiday == true
            ans = '公休'
          else
            cs = ClassSetting.find_by(id: roster_a.class_setting_id)
            ans = cs ?  cs.display_name : ''
          end
        end
        ans
      }
    }

    time_a = {
      chinese_name: '原時段（甲方）',
      english_name: 'Original Time A',
      simple_chinese_name: '原时段（甲方）',
      get_value: -> (rst, options){
        roster_a = RosterObject.find_by(id: rst['user_a_roster_id'])
        ans = ''
        if roster_a
          if roster_a.is_general_holiday == true
            ans = ''
          else
            cs = ClassSetting.find_by(id: roster_a.class_setting_id)
            if cs
              start_time = cs.start_time ? cs.start_time.strftime("%H:%M:%S") : ''
              end_time = cs.end_time ? cs.end_time.strftime("%H:%M:%S") : ''
              is_start_next = cs.is_next_of_start ? '次日' : ''
              is_end_next = cs.is_next_of_end ? '次日' : ''
              ans = "#{is_start_next} #{start_time} - #{is_end_next} #{end_time}"
            end
          end
        end
        ans
      }
    }

    adjust_date_b = {
      chinese_name: '調動日期（乙方）',
      english_name: 'Adjust Date B',
      simple_chinese_name: '调动日期（乙方）',
      get_value: -> (rst, options){
        rst['user_b_adjust_date'] ? rst['user_b_adjust_date'] : ''
      }
    }

    class_b = {
      chinese_name: '原更別（乙方）',
      english_name: 'Original Class B',
      simple_chinese_name: '原更别（乙方）',
      get_value: -> (rst, options){
        roster_b = RosterObject.find_by(id: rst['user_b_roster_id'])
        ans = ''
        if roster_b
          if roster_b.is_general_holiday == true
            ans = '公休'
          else
            cs = ClassSetting.find_by(id: roster_b.class_setting_id)
            ans = cs ?  cs.display_name : ''
          end
        end
        ans
      }
    }

    time_b = {
      chinese_name: '原時段（乙方）',
      english_name: 'Original Time B',
      simple_chinese_name: '原时段（乙方方）',
      get_value: -> (rst, options){
        roster_b = RosterObject.find_by(id: rst['user_b_roster_id'])
        ans = ''
        if roster_b
          if roster_b.is_general_holiday == true
            ans = ''
          else
            cs = ClassSetting.find_by(id: roster_b.class_setting_id)
            if cs
              start_time = cs.start_time ? cs.start_time.strftime("%H:%M:%S") : ''
              end_time = cs.end_time ? cs.end_time.strftime("%H:%M:%S") : ''
              is_start_next = cs.is_next_of_start ? '次日' : ''
              is_end_next = cs.is_next_of_end ? '次日' : ''
              ans = "#{is_start_next} #{start_time} - #{is_end_next} #{end_time}"
            end
          end
        end
        ans
      }
    }

    empoid_b = {
      chinese_name: '員工編號（乙方）',
      english_name: 'Empoid B',
      simple_chinese_name: '员工编号（乙方）',
      get_value: -> (rst, options){
        # rst["user_b"][:empoid].rjust(8, '0')
        rst["user_b"] ? "\s#{rst["user_b"][:empoid].rjust(8, '0')}" : ''
      }
    }

    name_b = {
      chinese_name: '姓名（乙方）',
      english_name: 'Name B',
      simple_chinese_name: '姓名（乙方）',
      get_value: -> (rst, options){
        rst["user_b"] ? rst["user_b"][options[:name_key]] : ''
      }
    }

    department_b = {
      chinese_name: '部門（乙方）',
      english_name: 'Department B',
      simple_chinese_name: '部门（乙方）',
      get_value: -> (rst, options){
        rst['department_b'] ? rst['department_b'][options[:name_key]] : ''
      }
    }

    position_b = {
      chinese_name: '職位（乙方）',
      english_name: 'Position B',
      simple_chinese_name: '职位（乙方）',
      get_value: -> (rst, options){
        rst['position_b'] ? rst['position_b'][options[:name_key]] : ''
      }
    }


    apply_type = {
      chinese_name: '申請類型',
      english_name: 'Apply Type',
      simple_chinese_name: '申请类型',
      get_value: -> (rst, options){
        rst['apply_type_name'] ? rst['apply_type_name'][options[:name_key]] : ''
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

    [empoid_a, name_a, department_a, position_a,
                    adjust_date_a, class_a, time_a, adjust_date_b, class_b, time_b,
                    empoid_b, name_b, department_b, position_b, apply_type, comment]


  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '調更調假記錄'
    elsif select_language.to_s == 'english_name'
      'Adjust Roster Records'
    else
      '调更调假记录'
    end
  end

  def get_adjust_roster_report_table_fields
    empoid = {
      chinese_name: '員工編號',
      english_name: 'empoid',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        # user = User.find(rst["user_id"])
        # user["empoid"].rjust(8, '0')
        "\s#{rst["user"][:empoid].rjust(8, '0')}"
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

    not_special = {
      chinese_name: '調更調假次數',
      english_name: 'Times (not special)',
      simple_chinese_name: '调更调假次数',
      get_value: -> (rst, options){
        rst['not_special'] ? rst["not_special"] : ''
      }
    }

    not_special_for_class = {
      chinese_name: '調更次數',
      english_name: 'Times of adjusting class (not special)',
      simple_chinese_name: '调更次数',
      get_value: -> (rst, options){
        rst['not_special_for_class'] ? rst["not_special_for_class"] : ''
      }
    }

    not_special_for_holiday = {
      chinese_name: '調假次數',
      english_name: 'Times of adjusting holiday (not special)',
      simple_chinese_name: '调假次数',
      get_value: -> (rst, options){
        rst['not_special_for_holiday'] ? rst["not_special_for_holiday"] : ''
      }
    }

    special = {
      chinese_name: '調更調假次數（總監特批）',
      english_name: 'Times',
      simple_chinese_name: '调更调假次数（总监特批）',
      get_value: -> (rst, options){
        rst['special'] ? rst["special"] : ''
      }
    }

    special_for_class = {
      chinese_name: '調更次數（總監特批）',
      english_name: 'Times of adjusting class',
      simple_chinese_name: '调更次数（总监特批）',
      get_value: -> (rst, options){
        rst['special_for_class'] ? rst["special_for_class"] : ''
      }
    }

    special_for_holiday = {
      chinese_name: '調假次數（總監特批）',
      english_name: 'Times of adjusting holiday',
      simple_chinese_name: '调假次数（总监特批）',
      get_value: -> (rst, options){
        rst['special_for_holiday'] ? rst["special_for_holiday"] : ''
      }
    }

    [empoid, name, department, position, entry_date,
                    not_special, not_special_for_class, not_special_for_holiday,
                    special, special_for_class, special_for_holiday]

  end

  def export_report_title
    if select_language.to_s == 'chinese_name'
      '調更調假報表'
    elsif select_language.to_s == 'english_name'
      'Adjust Roster Report'
    else
      '调更调假报表'
    end
  end
end
