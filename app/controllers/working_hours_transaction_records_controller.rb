# coding: utf-8
class WorkingHoursTransactionRecordsController < ApplicationController
  include GenerateXlsxHelper
  include DownloadActionAble
  before_action :set_working_hours_transaction_record, only: [:show, :update, :destroy, :histories, :add_approval, :add_attach]

  def index
    authorize WorkingHoursTransactionRecord
    params[:page] ||= 1
    meta = {}
    all_result = search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    final_result = format_result(result.as_json(include: [], methods: []))

    response_json final_result, meta: meta
  end

  def raw_show
    result = @working_hours_transaction_record.as_json(
      include: {
        approval_items: {include: {user: {include: [:department, :location, :position ]}}},
        attend_attachments: {include: :creator},
        user_a: {include: [:department, :location, :position ], methods: [:date_of_employment]},
        user_b: {include: [:department, :location, :position ], methods: [:date_of_employment]},
        working_hours_transaction_record_histories: {include: [:user_a, :user_b, :creator]},
      }
    )

    response_json result

  end



  def show
    authorize WorkingHoursTransactionRecord
    raw_show
  end

  def create
    authorize WorkingHoursTransactionRecord
    ActiveRecord::Base.transaction do
      raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:working_hours_transaction_record][:user_a_id] && params[:working_hours_transaction_record][:user_b_id] && params[:working_hours_transaction_record][:is_compensate] && params[:working_hours_transaction_record][:apply_type] && params[:working_hours_transaction_record][:apply_date] && params[:working_hours_transaction_record][:start_time] && params[:working_hours_transaction_record][:end_time]
      raise LogicError, {id: 422, message: '甲方乙方员工不能相同'}.to_json if params[:working_hours_transaction_record][:user_a_id] && params[:working_hours_transaction_record][:user_b_id]
      raise LogicError, {id: 422, message: '日期内已借钟'}.to_json if WorkingHoursTransactionRecord.where(apply_date: params[:working_hours_transaction_record][:apply_date])
      wht = WorkingHoursTransactionRecord.create(working_hours_transaction_record_params)
      wht.working_hours_transaction_record_histories.create(wht.attributes.merge({ id: nil }))
      raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:borrow_id]
      if params[:borrow_id]
        borrow = WorkingHoursTransactionRecord.find_by(id: params[:borrow_id])
        raise LogicError, {id: 422, message: '数据不存在'}.to_json unless borrow
        if borrow
          borrow.can_be_return = false
          borrow.save
        end
      end

      roster_object_a = RosterObject.where(user_id: wht.user_a_id, roster_date: wht.apply_date, is_active: ['active', nil]).first
      type_a = wht.apply_type == 'borrow_hours' ? 'borrow_as_a' : 'return_as_a'
      if roster_object_a
        roster_object_a.working_hours_transaction_record_id = wht.id
        roster_object_a.borrow_return_type = type_a
        roster_object_a.save

        inactive_ro_a = RosterObject.where(user_id: roster_object_a.user_id, roster_date: roster_object_a.roster_date, is_active: 'inactive').first
        if inactive_ro_a
          inactive_ro_a.working_hours_transaction_record_id = wht.id
          inactive_ro_a.borrow_return_type = type_a
          inactive_ro_a.save
        end

      else
        u = User.find_by(id: wht.user_a_id)
        if u
          roster_object_a = RosterObject.create(user_id: u.id,
                                                roster_date: wht.apply_date,
                                                location_id: u.location_id,
                                                department_id: u.department_id,
                                                working_hours_transaction_record_id: wht.id,
                                                borrow_return_type: type_a
                                               )
        end
      end

      if roster_object_a
        roster_object_a.roster_object_logs.create(modified_reason: "add_#{type_a}",
                                                  approver_id: current_user.id,
                                                  approval_time: Time.zone.now.to_datetime,
                                                  is_general_holiday: roster_object_a.is_general_holiday,
                                                  class_setting_id: roster_object_a.class_setting_id,
                                                  working_time: roster_object_a.working_time,
                                                  borrow_return_type: type_a,
                                                  working_hours_transaction_record_id: wht.id)
      end



      roster_object_b = RosterObject.where(user_id: wht.user_b_id, roster_date: wht.apply_date, is_active: ['active', nil]).first
      type_b = wht.apply_type == 'borrow_hours' ? 'borrow_as_b' : 'return_as_b'
      if roster_object_b
        roster_object_b.working_hours_transaction_record_id = wht.id
        roster_object_b.borrow_return_type = type_b
        roster_object_b.save

        inactive_ro_b = RosterObject.where(user_id: roster_object_b.user_id, roster_date: roster_object_b.roster_date, is_active: 'inactive').first
        if inactive_ro_b
          inactive_ro_b.working_hours_transaction_record_id = wht.id
          inactive_ro_b.borrow_return_type = type_b
          inactive_ro_b.save
        end
      else
        u = User.find_by(id: wht.user_b_id)
        if u
          roster_object_b = RosterObject.create(user_id: u.id,
                                                roster_date: wht.apply_date,
                                                location_id: u.location_id,
                                                department_id: u.department_id,
                                                working_hours_transaction_record_id: wht.id,
                                                borrow_return_type: type_b
                                               )
        end
      end

      if roster_object_b
        roster_object_b.roster_object_logs.create(modified_reason: "add_#{type_b}",
                                                  approver_id: current_user.id,
                                                  approval_time: Time.zone.now.to_datetime,
                                                  is_general_holiday: roster_object_b.is_general_holiday,
                                                  class_setting_id: roster_object_b.class_setting_id,
                                                  working_time: roster_object_b.working_time,
                                                  borrow_return_type: type_b,
                                                  working_hours_transaction_record_id: wht.id)
      end

      if wht.user_a_id
        should_merge = wht.apply_type == 'borrow_hours' ? false : true
        RosterObject.update_attend_states_after_working_hours_transaction(roster_object_a, wht, should_merge)
      end

      if wht.user_b_id
        should_merge = wht.apply_type == 'borrow_hours' ? true : false
        RosterObject.update_attend_states_after_working_hours_transaction(roster_object_b, wht, should_merge)
      end


      # attend state
      if wht.user_a_id
        # user_id = wht.user_a_id ? wht.user_a_id : wht.user_b_id
        u_a_id = wht.user_a_id
        date = wht.apply_date
        att = Attend.find_attend_by_user_and_date(u_a_id, date)

        if att == nil
          att = Attend.create(user_id: u_a_id,
                              attend_date: date,
                              attend_weekday: date.wday,
                             )
        end
        att.attend_states.create(state: WorkingHoursTransactionRecord.return_attend_state_type(wht.id, u_a_id),
                                 record_type: 'working_hours_transaction_record',
                                 record_id: wht.id
                                )

        # attend log
        att.attend_logs.create(user_id: u_a_id,
                               apply_type: 'working_hours_transaction',
                               type_id: wht.id,
                               logger_id: wht.creator_id,
                              )
      end

      if wht.user_b_id
        # user_id = wht.user_a_id ? wht.user_a_id : wht.user_b_id
        u_b_id = wht.user_b_id
        date = wht.apply_date
        att = Attend.find_attend_by_user_and_date(u_b_id, date)

        if att == nil
          att = Attend.create(user_id: u_b_id,
                              attend_date: date,
                              attend_weekday: date.wday,
                             )
        end
        att.attend_states.create(state: WorkingHoursTransactionRecord.return_attend_state_type(wht.id, u_b_id),
                                 record_type: 'working_hours_transaction_record',
                                 record_id: wht.id
                                )

        # attend log
        att.attend_logs.create(user_id: u_b_id,
                               apply_type: 'working_hours_transaction',
                               type_id: wht.id,
                               logger_id: wht.creator_id,
                              )
      end


      if wht.is_compensate == false
        AttendMonthlyReport.update_calc_status(wht.user_a_id, wht.apply_date)
        AttendAnnualReport.update_calc_status(wht.user_a_id, wht.apply_date)
        AttendMonthlyReport.update_calc_status(wht.user_b_id, wht.apply_date)
        AttendAnnualReport.update_calc_status(wht.user_b_id, wht.apply_date)
      else
        CompensateReport.update_reports(wht)
      end
      AttendMonthApproval.update_data(wht.apply_date)
      response_json wht.id
    end
  end

  def update
    authorize WorkingHoursTransactionRecord
    origin_date = @working_hours_transaction_record.apply_date

    roster_object_a = RosterObject.where(user_id: @working_hours_transaction_record.user_a_id, roster_date: @working_hours_transaction_record.apply_date, is_active: ['active', nil]).first
    if roster_object_a
      roster_object_a.working_hours_transaction_record_id = nil
      roster_object_a.borrow_return_type = nil
      roster_object_a.save

      RosterObject.update_attend_and_states(roster_object_a)
    end

    roster_object_b = RosterObject.where(user_id: @working_hours_transaction_record.user_b_id, roster_date: @working_hours_transaction_record.apply_date, is_active: ['active', nil]).first
    if roster_object_b
      roster_object_b.working_hours_transaction_record_id = nil
      roster_object_b.borrow_return_type = nil
      roster_object_b.save

      RosterObject.update_attend_and_states(roster_object_b)
    end

    updated_working_hours_transaction_record = @working_hours_transaction_record.update(working_hours_transaction_record_params)
    if updated_working_hours_transaction_record
      updated_record = WorkingHoursTransactionRecord.find_by(id: @working_hours_transaction_record.id)

      roster_object_a = RosterObject.where(user_id: updated_record.user_a_id, roster_date: updated_record.apply_date, is_active: ['active', nil]).first
      if roster_object_a
        roster_object_a.working_hours_transaction_record_id = updated_record.id
        roster_object_a.borrow_return_type = updated_record.apply_type == 'borrow_hours' ? 'borrow_as_a' : 'return_as_a'
        roster_object_a.save

        RosterObject.update_attend_and_states(roster_object_a)

        inactive_ro_a = RosterObject.where(user_id: roster_object_a.user_id, roster_date: roster_object_a.roster_date, is_active: 'inactive').first
        if inactive_ro_a
          inactive_ro_a.working_hours_transaction_record_id = updated_record.id
          inactive_ro_a.borrow_return_type = updated_record.apply_type == 'borrow_hours' ? 'borrow_as_a' : 'return_as_a'
          inactive_ro_a.save
        end
      else
        u = User.find_by(id: updated_record.user_a_id)
        if u
          type = updated_record.apply_type == 'borrow_hours' ? 'borrow_as_a' : 'return_as_a'
          ro_a = RosterObject.create(user_id: u.id,
                                     roster_date: updated_record.apply_date,
                                     location_id: u.location_id,
                                     department_id: u.department_id,
                                     working_hours_transaction_record_id: updated_record.id,
                                     borrow_return_type: type
                                    )

          RosterObject.update_attend_and_states(ro_a)
        end
      end

      roster_object_b = RosterObject.where(user_id: updated_record.user_b_id, roster_date: updated_record.apply_date, is_active: ['active', nil]).first
      if roster_object_b
        roster_object_b.working_hours_transaction_record_id = updated_record.id
        roster_object_b.borrow_return_type = updated_record.apply_type == 'borrow_hours' ? 'borrow_as_b' : 'return_as_b'
        roster_object_b.save

        RosterObject.update_attend_and_states(roster_object_b)

        inactive_ro_b = RosterObject.where(user_id: roster_object_b.user_id, roster_date: roster_object_b.roster_date, is_active: 'inactive').first
        if inactive_ro_b
          inactive_ro_b.working_hours_transaction_record_id = updated_record.id
          inactive_ro_b.borrow_return_type = updated_record.apply_type == 'borrow_hours' ? 'borrow_as_b' : 'return_as_b'
          inactive_ro_b.save
        end
      else
        u = User.find_by(id: updated_record.user_b_id)
        if u
          type = updated_record.apply_type == 'borrow_hours' ? 'borrow_as_b' : 'return_as_b'
          ro_b = RosterObject.create(user_id: u.id,
                                     roster_date: updated_record.apply_date,
                                     location_id: u.location_id,
                                     department_id: u.department_id,
                                     working_hours_transaction_record_id: updated_record.id,
                                     borrow_return_type: type
                                    )

          RosterObject.update_attend_and_states(ro_b)
        end
      end


      new_date = params[:apply_date].in_time_zone.to_date

      if origin_date == new_date
        # update
        attend_state = AttendState.where(record_type: 'working_hours_transaction_record', record_id: updated_record.id).first
        att = Attend.find_by(id: attend_state.attend_id)
        state_type = WorkingHoursTransactionRecord.return_attend_state_type(updated_record.id, att&.user_id)
        attend_state.state = state_type
        attend_state.save
      else
        # destroy
        attend_state = AttendState.where(record_type: 'working_hours_transaction_record', record_id: @working_hours_transaction_record.id).first
        attend_state.destroy if attend_state

        attend_log = AttendLog.where(apply_type: 'working_hours_transaction', type_id: @working_hours_transaction_record.id).first
        attend_log.destroy if attend_log

        # create
        # user_id = updated_record.user_a_id ? updated_record.user_a_id : updated_record.user_b_id
        if updated_record.user_a_id
          u_a_id = updated_record.user_a_id

          att = Attend.find_attend_by_user_and_date(u_a_id, new_date)

          if att == nil
            att = Attend.create(user_id: u_a_id,
                                attend_date: new_date,
                                attend_weekday: new_date.wday,
                               )
          end
          att.attend_states.create(state: WorkingHoursTransactionRecord.return_attend_state_type(updated_record.id, u_a_id),
                                   record_type: 'working_hours_transaction_record',
                                   record_id: updated_record.id
                                  )

          # attend log
          att.attend_logs.create(user_id: u_a_id,
                                 apply_type: 'working_hours_transaction',
                                 type_id: updated_record.id,
                                 logger_id: updated_record.creator_id,
                                )
        end

        if updated_record.user_b_id
          u_b_id = updated_record.user_b_id

          att = Attend.find_attend_by_user_and_date(u_b_id, new_date)

          if att == nil
            att = Attend.create(user_id: u_b_id,
                                attend_date: new_date,
                                attend_weekday: new_date.wday,
                               )
          end
          att.attend_states.create(state: WorkingHoursTransactionRecord.return_attend_state_type(updated_record.id, u_b_id),
                                   record_type: 'working_hours_transaction_record',
                                   record_id: updated_record.id
                                  )

          # attend log
          att.attend_logs.create(user_id: u_b_id,
                                 apply_type: 'working_hours_transaction',
                                 type_id: updated_record.id,
                                 logger_id: updated_record.creator_id,
                                )
        end
      end

      updated_record.working_hours_transaction_record_histories.create(
        updated_record.attributes.merge({ id: nil })
      )

      if updated_record.is_compensate == false
        AttendMonthlyReport.update_calc_status(updated_record.user_a_id, updated_record.apply_date)
        AttendAnnualReport.update_calc_status(updated_record.user_a_id, updated_record.apply_date)
        AttendMonthlyReport.update_calc_status(updated_record.user_b_id, updated_record.apply_date)
        AttendAnnualReport.update_calc_status(updated_record.user_b_id, updated_record.apply_date)
      else
        CompensateReport.update_reports(updated_record)
      end
      AttendMonthApproval.update_data(updated_record.apply_date)
    end
    response_json updated_working_hours_transaction_record
  end

  def destroy
    authorize WorkingHoursTransactionRecord
    ActiveRecord::Base.transaction do
      updated_working_hours_transaction_record = @working_hours_transaction_record.update(is_deleted: true)

      if @working_hours_transaction_record.borrow_id != nil
        borrow = WorkingHoursTransactionRecord.find_by(id: @working_hours_transaction_record.borrow_id)
        if borrow
          borrow.can_be_return = true
          borrow.save
        end
      end

      roster_object_a = RosterObject.where(user_id: @working_hours_transaction_record.user_a_id, roster_date: @working_hours_transaction_record.apply_date, is_active: ['active', nil]).first
      type_a = @working_hours_transaction_record.apply_type == 'borrow_hours' ? 'borrow_as_a' : 'return_as_a'
      if roster_object_a
        roster_object_a.working_hours_transaction_record_id = nil
        roster_object_a.borrow_return_type = nil
        roster_object_a.save

        roster_object_a.roster_object_logs.create(modified_reason: "cancel_#{type_a}",
                                                  approver_id: current_user.id,
                                                  approval_time: Time.zone.now.to_datetime,
                                                  is_general_holiday: roster_object_a.is_general_holiday,
                                                  class_setting_id: roster_object_a.class_setting_id,
                                                  working_time: roster_object_a.working_time)


        RosterObject.update_attend_and_states(roster_object_a)

        inactive_ro_a = RosterObject.where(user_id: roster_object_a.user_id, roster_date: roster_object_a.roster_date, is_active: 'inactive').first
        if inactive_ro_a
          inactive_ro_a.working_hours_transaction_record_id = nil
          inactive_ro_a.borrow_return_type = nil
          inactive_ro_a.save
        end
      end

      type_b = @working_hours_transaction_record.apply_type == 'borrow_hours' ? 'borrow_as_b' : 'return_as_b'
      roster_object_b = RosterObject.where(user_id: @working_hours_transaction_record.user_b_id, roster_date: @working_hours_transaction_record.apply_date, is_active: ['active', nil]).first
      if roster_object_b
        roster_object_b.working_hours_transaction_record_id = nil
        roster_object_b.borrow_return_type = nil
        roster_object_b.save

        roster_object_b.roster_object_logs.create(modified_reason: "cancel_#{type_b}",
                                                  approver_id: current_user.id,
                                                  approval_time: Time.zone.now.to_datetime,
                                                  is_general_holiday: roster_object_b.is_general_holiday,
                                                  class_setting_id: roster_object_b.class_setting_id,
                                                  working_time: roster_object_b.working_time)

        RosterObject.update_attend_and_states(roster_object_b)

        inactive_ro_b = RosterObject.where(user_id: roster_object_b.user_id, roster_date: roster_object_b.roster_date, is_active: 'inactive').first
        if inactive_ro_b
          inactive_ro_b.working_hours_transaction_record_id = nil
          inactive_ro_b.borrow_return_type = nil
          inactive_ro_b.save
        end
      end

      att_states = AttendState.where(record_type: 'working_hours_transaction_record', record_id: @working_hours_transaction_record.id)
      att_states.each { |state| state.destroy if state }
      att_logs = AttendLog.where(apply_type: 'working_hours_transaction', type_id: @working_hours_transaction_record.id)
      att_logs.each { |log| log.destroy if log }


      if @working_hours_transaction_record.is_compensate == false
        AttendMonthlyReport.update_calc_status(@working_hours_transaction_record.user_a_id, @working_hours_transaction_record.apply_date)
        AttendAnnualReport.update_calc_status(@working_hours_transaction_record.user_a_id, @working_hours_transaction_record.apply_date)
        AttendMonthlyReport.update_calc_status(@working_hours_transaction_record.user_b_id, @working_hours_transaction_record.apply_date)
        AttendAnnualReport.update_calc_status(@working_hours_transaction_record.user_b_id, @working_hours_transaction_record.apply_date)
      else
        CompensateReport.update_reports(@working_hours_transaction_record)
      end
      AttendMonthApproval.update_data(@working_hours_transaction_record.apply_date)

      response_json updated_working_hours_transaction_record
    end
  end

  def histories
    response_json @working_hours_transaction_record.working_hours_transaction_record_histories.as_json
  end

  def add_approval
    authorize WorkingHoursTransactionRecord
    raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:approval_item][:user_id] && params[:approval_item][:datetime] && params[:approval_item][:comment]
    if params[:approval_item]
      app = @working_hours_transaction_record.approval_items.create(params[:approval_item].permit(:user_id, :datetime, :comment))
      response_json app.as_json
    else
      response_json :ok
    end
  end

  def destroy_approval
    authorize WorkingHoursTransactionRecord
    working_hours_transaction_record = WorkingHoursTransactionRecord.find(params[:working_hours_transaction_record_id])
    raise LogicError, {id: 422, message: '找不到数据'}.to_json unless working_hours_transaction_record
    app = working_hours_transaction_record.approval_items.find(params[:id])
    raise LogicError, {id: 422, message: '找不到数据'}.to_json unless app
    app.destroy if app
    response_json :ok
  end

  def add_attach
    authorize WorkingHoursTransactionRecord
    raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:attach_item][:file_name]
    if params[:attach_item]
      att = @working_hours_transaction_record.attend_attachments.create(params[:attach_item].permit(:file_name, :comment, :attachment_id, :creator_id))
      response_json att.as_json
    else
      response_json :ok
    end
  end

  def destroy_attach
    authorize WorkingHoursTransactionRecord
    working_hours_transaction_record = WorkingHoursTransactionRecord.find(params[:working_hours_transaction_record_id])
    raise LogicError, {id: 422, message: '找不到数据'}.to_json unless working_hours_transaction_record
    att = working_hours_transaction_record.attend_attachments.find(params[:id])
    raise LogicError, {id: 422, message: '找不到数据'}.to_json unless att
    att.destroy if att
    response_json :ok
  end

  def be_able_apply
    # params: apply_date, apply_range, apply_type(borrow_hours, return_hours), is_next_of_start, is_next_of_end, user_a_id, user_b_id

    result = {}
    apply_date = params[:apply_date].in_time_zone.to_date rescue nil

    # 08:00-15:00
    apply_range = params[:apply_range]
    apply_st = apply_range.split('-').first.split(":").join("").to_i rescue nil
    apply_end = apply_range.split('-').second.split(":").join("").to_i rescue nil
    is_st_next = params[:is_next_of_start] == 'true' ? 10000 : 0
    is_end_next = params[:is_next_of_end] == 'true' ? 10000 : 0

    apply_st_int = apply_st + is_st_next rescue nil
    apply_end_int = apply_end + is_end_next rescue nil

    user_a_ro = RosterObject.where(user_id: params[:user_a_id], roster_date: params[:apply_date]).first
    user_b_ro = RosterObject.where(user_id: params[:user_b_id], roster_date: params[:apply_date]).first
    a_class = ClassSetting.find_by(id: user_a_ro&.class_setting_id)
    b_class = ClassSetting.find_by(id: user_b_ro&.class_setting_id)

    if params[:apply_type] == 'borrow_hours'
      raise LogicError, {id: 422, message: '找不到数据'}.to_json unless params[:user_a_id]
      if params[:user_a_id]
        if a_class
          st_to_int = a_class.start_time.strftime("%H%M").to_i + (a_class&.is_next_of_start ? 1 : 0) * 10000
          end_to_int = a_class.end_time.strftime("%H%M").to_i + (a_class&.is_next_of_end ? 1 : 0) * 10000

          borrow_user_a_in = (apply_st_int >= st_to_int && apply_end_int <= end_to_int) ? true : false rescue nil
          borrow_user_a_has_roster = true
        elsif user_a_ro&.working_time # "xx:xx-xx:xx "
          tmp_st_to_int = user_a_ro&.working_time.split('-').first.split(":").join("").to_i
          tmp_end_to_int = user_a_ro&.working_time.split('-').second.split(":").join("").to_i
          st_to_int = (tmp_st_to_int / 2400) * 10000 + (tmp_st_to_int % 2400)
          end_to_int = (tmp_end_to_int / 2400) * 10000 + (tmp_end_to_int % 2400)

          borrow_user_a_in = (apply_st_int >= st_to_int && apply_end_int <= end_to_int) ? true : false rescue nil
          borrow_user_a_has_roster = true
        else
          borrow_user_a_in = true
          borrow_user_a_has_roster = false
        end
      else
        borrow_user_a_in = true
        borrow_user_a_has_roster = true
      end
      raise LogicError, {id: 422, message: '找不到数据'}.to_json unless params[:user_b_id]
      if params[:user_b_id]
        if b_class
          st_to_int = b_class.start_time.strftime("%H%M").to_i + (b_class&.is_next_of_start ? 1 : 0) * 10000
          end_to_int = b_class.end_time.strftime("%H%M").to_i + (b_class&.is_next_of_end ? 1 : 0) * 10000

          borrow_user_b_out = (apply_st_int >= end_to_int || apply_end_int <= st_to_int) ? true : false rescue nil
          borrow_user_b_has_roster = true
        elsif user_b_ro&.working_time # "xx:xx-xx:xx "
          tmp_st_to_int = user_b_ro&.working_time.split('-').first.split(":").join("").to_i
          tmp_end_to_int = user_b_ro&.working_time.split('-').second.split(":").join("").to_i
          st_to_int = (tmp_st_to_int / 2400) * 10000 + (tmp_st_to_int % 2400)
          end_to_int = (tmp_end_to_int / 2400) * 10000 + (tmp_end_to_int % 2400)

          borrow_user_b_out = (apply_st_int >= end_to_int || apply_end_int <= st_to_int) ? true : false rescue nil
          borrow_user_b_has_roster = true
        else
          borrow_user_b_out = true
          borrow_user_b_has_roster = false
        end
      else
        borrow_user_b_out = true
        borrow_user_b_has_roster = true
      end

      return_user_a_out = true
      return_user_a_has_roster = true
      return_user_b_in = true
      return_user_b_has_roster = true

    elsif params[:apply_type] == 'return_hours'
      raise LogicError, {id: 422, message: '找不到数据'}.to_json unless params[:user_a_id]
      if params[:user_a_id]
        if a_class
          st_to_int = a_class.start_time.strftime("%H%M").to_i + (a_class&.is_next_of_start ? 1 : 0) * 10000
          end_to_int = a_class.end_time.strftime("%H%M").to_i + (a_class&.is_next_of_end ? 1 : 0) * 10000

          return_user_a_out = (apply_st_int >= end_to_int || apply_end_int <= st_to_int) ? true : false rescue nil
          return_user_a_has_roster = true

        elsif user_a_ro&.working_time # "xx:xx-xx:xx "
          tmp_st_to_int = user_a_ro&.working_time.split('-').first.split(":").join("").to_i
          tmp_end_to_int = user_a_ro&.working_time.split('-').second.split(":").join("").to_i
          st_to_int = (tmp_st_to_int / 2400) * 10000 + (tmp_st_to_int % 2400)
          end_to_int = (tmp_end_to_int / 2400) * 10000 + (tmp_end_to_int % 2400)

          return_user_a_out = (apply_st_int >= end_to_int || apply_end_int <= st_to_int) ? true : false rescue nil
          return_user_a_has_roster = true
        else
          return_user_a_out = true
          return_user_a_has_roster = false
        end
      else
        return_user_a_out = true
        return_user_a_has_roster = true
      end
      raise LogicError, {id: 422, message: '找不到数据'}.to_json unless params[:user_b_id]
      if params[:user_b_id]
        if b_class
          st_to_int = b_class.start_time.strftime("%H%M").to_i + (b_class&.is_next_of_start ? 1 : 0) * 10000
          end_to_int = b_class.end_time.strftime("%H%M").to_i + (b_class&.is_next_of_end ? 1 : 0) * 10000

          return_user_b_in = (apply_st_int >= st_to_int && apply_end_int <= end_to_int) ? true : false rescue nil
          return_user_b_has_roster = true
        elsif user_b_ro&.working_time # "xx:xx-xx:xx "
          tmp_st_to_int = user_b_ro&.working_time.split('-').first.split(":").join("").to_i
          tmp_end_to_int = user_b_ro&.working_time.split('-').second.split(":").join("").to_i
          st_to_int = (tmp_st_to_int / 2400) * 10000 + (tmp_st_to_int % 2400)
          end_to_int = (tmp_end_to_int / 2400) * 10000 + (tmp_end_to_int % 2400)

          return_user_b_in = (apply_st_int >= st_to_int && apply_end_int <= end_to_int) ? true : false rescue nil
          return_user_b_has_roster = true
        else
          return_user_b_in = true
          return_user_b_has_roster = false
        end
      else
        return_user_b_in = true
        return_user_b_has_roster = true
      end

      borrow_user_a_in = true
      borrow_user_a_has_roster = true
      borrow_user_b_out = true
      borrow_user_b_has_roster = true
    end

    true_records = WorkingHoursTransactionRecord.where(is_deleted: false).or(WorkingHoursTransactionRecord.where(is_deleted: nil))
    apply_count = true_records.where(user_a_id: params[:user_a_id],
                                     source_id: nil,
                                     apply_type: 'borrow_hours',
                                     apply_date: apply_date
                                    ).count
    total_count = true_records.where(user_a_id: params[:user_a_id],
                                     source_id: nil,
                                     apply_date: apply_date.beginning_of_month .. apply_date.end_of_month
                                    ).count rescue 0
    date_be_able_apply = apply_count > 0 ? false : true
    total_be_able_apply = total_count >= 1 ? false : true

    result[:borrow_user_a_in] = borrow_user_a_in
    result[:borrow_user_a_has_roster] = borrow_user_a_has_roster
    result[:borrow_user_b_out] = borrow_user_b_out
    result[:borrow_user_b_has_roster] = borrow_user_b_has_roster
    result[:return_user_a_out] = return_user_a_out
    result[:return_user_a_has_roster] = return_user_a_has_roster
    result[:return_user_b_in] = return_user_b_in
    result[:return_user_b_has_roster] = return_user_b_has_roster

    result[:date_be_able_apply] = date_be_able_apply
    result[:total_be_able_apply] = total_be_able_apply
    result[:be_able_apply] = date_be_able_apply && total_be_able_apply && borrow_user_a_in && borrow_user_b_out && return_user_a_out && return_user_b_in &&
                             borrow_user_a_has_roster && borrow_user_b_has_roster && return_user_a_has_roster && return_user_b_has_roster

    response_json result.as_json
  end

  def options
    result = {}

    result[:apply_types] = apply_type_table

    response_json result.as_json
  end

  def export_xlsx
    authorize WorkingHoursTransactionRecord
    all_result = search_query
    final_result = format_result(all_result.as_json(include: [], methods: []))
    working_hours_transaction_record_export_num = Rails.cache.fetch('working_hours_transaction_record_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + working_hours_transaction_record_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('working_hours_transaction_record_export_number_tag', working_hours_transaction_record_export_num+1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'WorkingHoursTransactionRecordsController', table_fields_methods: 'get_table_fields', table_fields_args: [], my_attachment: my_attachment, sheet_name: 'WHTRecordTable')
    render json: my_attachment
  end

  private

  def working_hours_transaction_record_params
    params.require(:working_hours_transaction_record).permit(
      :region,
      :user_a_id,
      :user_b_id,
      :is_compensate,
      :apply_type,
      :apply_date,
      :start_time,
      :end_time,
      :hours_count,
      :is_deleted,
      :creator_id,
      :can_be_return,
      :borrow_id,
      :is_start_next,
      :is_end_next,
      :comment
    )
  end

  def set_working_hours_transaction_record
    @working_hours_transaction_record = WorkingHoursTransactionRecord.find(params[:id])
  end

  def search_query
    tag = false
    # region = params[:region] || 'macau'
    lang_key = params[:lang] || 'zh-TW'

    lang = if lang_key == 'zh-TW'
             'chinese_name'
           elsif lang_key == 'zh-US'
             'english_name'
           else
             'simple_chinese_name'
           end

    working_hours_transaction_records = WorkingHoursTransactionRecord
                                            .where(source_id: nil)
                                            .by_location_id(params[:location_id])
                                            .by_department_id(params[:department_id])
                                            .by_user(params[:user_ids])
                                            .by_apply_type(params[:apply_type])
                                            .by_can_be_return(params[:can_be_return])
                                            .by_is_deleted(params[:is_deleted])
                                            .by_apply_date(params[:apply_date])
    # .by_apply_date(params[:working_hours_transaction_start_date], params[:working_hours_transaction_end_date])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      default_order = "created_at DESC"
      default_order_with_self = "working_hours_transaction_records.created_at DESC"

      if params[:sort_column] == 'empoid' || params[:sort_column] == 'department_id' || params[:sort_column] == 'position_id'
      # working_hours_transaction_records = working_hours_transaction_records.includes(:user).order("users.#{params[:sort_column]} #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user_a'
        working_hours_transaction_records = working_hours_transaction_records.order("user_a_id #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'user_b'
        working_hours_transaction_records = working_hours_transaction_records.order("user_b_id #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'user_a.empoid'
        working_hours_transaction_records = working_hours_transaction_records.includes(:user_a).order("users.empoid #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'user_b.empoid'
        working_hours_transaction_records = working_hours_transaction_records.includes(:user_b).order("users.empoid #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'department_a' || params[:sort_column] == 'position_a'
        field = "#{params[:sort_column].split('_').first}_id"
        working_hours_transaction_records = working_hours_transaction_records.includes(:user_a).order("users.#{field} #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'department_b' || params[:sort_column] == 'position_b'
        field = "#{params[:sort_column].split('_').first}_id"
        working_hours_transaction_records = working_hours_transaction_records.includes(:user_b).order("users.#{field} #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'status'
        working_hours_transaction_records = working_hours_transaction_records.order("start_time #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'apply_type_name'
        working_hours_transaction_records = working_hours_transaction_records.order("apply_type #{params[:sort_direction]}", default_order)
      else
        working_hours_transaction_records = working_hours_transaction_records.order("#{params[:sort_column]} #{params[:sort_direction]}", default_order)
      end
      tag = true
    end

    working_hours_transaction_records = working_hours_transaction_records.order(created_at: :desc) if tag == false

    working_hours_transaction_records
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

      hash['apply_type_name'] = find_name_for(hash['apply_type'], apply_type_table)

      hash
    end
  end

  def find_name_for(type, table)
    table.select { |op| op[:key] == type }.first
  end

  def find_working_hours_transaction_type_name(type)
    type_options = working_hours_transaction_type_table
    type_options.select { |op| op[:key] == type }.first
  end

  def apply_type_table
    [
      {
        key: 'borrow_hours',
        chinese_name: '借鐘',
        english_name: 'Borrow Hours',
        simple_chinese_name: '借钟',
      },

      {
        key: 'return_hours',
        chinese_name: '還鐘',
        english_name: 'Return Hours',
        simple_chinese_name: '还钟',
      },
    ]
  end

  def self.get_table_fields
    is_compensate = {
      chinese_name: '是否補薪',
      english_name: 'Is Compensate',
      simple_chinese_name: '是否补薪',
      get_value: -> (rst, options){
        rst['is_compensate'] ? '是' : '否'
      }
    }

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

    empoid_b = {
      chinese_name: '員工編號（乙方）',
      english_name: 'Empoid B',
      simple_chinese_name: '员工编号（乙方）',
      get_value: -> (rst, options){
        # user = User.find(rst["user_id"])
        # user["empoid"].rjust(8, '0')
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


    apply_date = {
      chinese_name: '申請日期',
      english_name: 'Apply date',
      simple_chinese_name: '申请日期',
      get_value: -> (rst, options){
        rst['apply_date'] ? rst['apply_date'] : ''
      }
    }

    apply_time = {
      chinese_name: '申請時段',
      english_name: 'Apply time',
      simple_chinese_name: '申请时段',
      get_value: -> (rst, options){
        start_time = rst['start_time'] ? Time.zone.parse(rst['start_time']).strftime("%H:%M:%S") : ''
        end_time = rst['end_time'] ? Time.zone.parse(rst['end_time']).strftime("%H:%M:%S") : ''
        is_start_next = rst['is_start_next'] ? '次日' : ''
        is_end_next = rst['is_end_next'] ? '次日' : ''
        "#{is_start_next} #{start_time} - #{is_end_next} #{end_time}"
      }
    }

    hours_count = {
      chinese_name: '借鐘/還鐘時數',
      english_name: 'Hours',
      simple_chinese_name: '借钟/还钟时数',
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

    can_be_return = {
      chinese_name: '是否還鐘',
      english_name: 'If Return',
      simple_chinese_name: '是否还钟',
      get_value: -> (rst, options){
        ans = ''
        if rst['apply_type'] == 'borrow_hours'
          ans = rst['can_be_return'] == true ? '未還鐘' : '已還鐘'
        end
        ans
      }
    }

    table_fields = [is_compensate, empoid_a, name_a, department_a, position_a,
                    empoid_b, name_b, department_b, position_b, apply_type,
                    apply_date, apply_time, hours_count, comment, can_be_return]


  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '借鐘還鐘記錄'
    elsif select_language.to_s == 'english_name'
      'Working Hours Transaction Records'
    else
      '借钟还钟记录'
    end
  end
end
