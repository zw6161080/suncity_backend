# coding: utf-8
# == Schema Information
#
# Table name: roster_objects
#
#  id                                  :integer          not null, primary key
#  region                              :string
#  user_id                             :integer
#  location_id                         :integer
#  department_id                       :integer
#  roster_date                         :date
#  roster_list_id                      :integer
#  class_setting_id                    :integer
#  is_general_holiday                  :boolean
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#  working_time                        :string
#  holiday_type                        :string
#  special_type                        :integer
#  is_active                           :integer
#  holiday_record_id                   :integer
#  working_hours_transaction_record_id :integer
#  borrow_return_type                  :string
#  adjust_type                         :string
#  change_to_general_holiday           :boolean
#
# Indexes
#
#  index_roster_objects_on_class_setting_id                     (class_setting_id)
#  index_roster_objects_on_department_id                        (department_id)
#  index_roster_objects_on_holiday_record_id                    (holiday_record_id)
#  index_roster_objects_on_location_id                          (location_id)
#  index_roster_objects_on_roster_list_id                       (roster_list_id)
#  index_roster_objects_on_user_id                              (user_id)
#  index_roster_objects_on_working_hours_transaction_record_id  (working_hours_transaction_record_id)
#

class RosterObject < ApplicationRecord
  belongs_to :user
  belongs_to :roster_list
  belongs_to :class_setting
  belongs_to :location
  belongs_to :department
  belongs_to :holiday_record
  belongs_to :working_hours_transaction_record
  # has_one :class_setting

  after_save :update_reports

  has_many :roster_object_logs

  enum special_type: { transfer_location: 0, lent_temporarily: 1, transfer_position: 2, special_roster: 3 }
  enum is_active: { active: 0, inactive: 1 }

  scope :by_location_id, lambda { |location_id|
    where(location_id: location_id) if location_id
  }

  scope :by_department_id, lambda { |department_id|
    where(department_id: department_id) if department_id
  }

  # scope :by_user, lambda { |name, lang|
  #   where("#{lang} like ?", "%#{name}%") if name
  # }

  scope :by_users, lambda { |user_ids|
    where(user_id: user_ids) if user_ids
  }

  scope :by_date, lambda { |start_date, end_date|
    if start_date && end_date
      where("roster_date >= ? AND roster_date <= ?", start_date, end_date)
    elsif start_date && !end_date
      where("roster_date >= ?", start_date)
    elsif !start_date && end_date
      where("roster_date <= ?", end_date)
    end
  }

  scope :by_week, lambda { |date|
    if date
      tmp_date = date.split('-').map(&:to_i)
      format_date = Date.new(tmp_date[0], tmp_date[1], tmp_date[2])
      where(roster_date: format_date.beginning_of_week .. format_date.end_of_week)
    end
  }

  def self.initial_table(roster_list, location_id, department_id, start_date, end_date, current_user)
    # user_ids = User.where(location_id: location_id, department_id: department_id).pluck(:id)

    user_ids = []
    all_users = User.all
    (start_date .. end_date).each do |d|
      all_users.each do |u|
        # date_of_employment = u.profile.data['position_information']['field_values']['date_of_employment']
        # entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

        # position_resigned_date = u.profile.data['position_information']['field_values']['position_resigned_date']
        # leave = position_resigned_date ? position_resigned_date.in_time_zone.to_date : nil

        # is_entry = (entry && (d >= entry))
        # not_leave = (leave == nil || (d <= leave))

        if location_id == ProfileService.location(u, d.to_datetime)&.id &&
           department_id == ProfileService.department(u, d.to_datetime)&.id
          user_ids << u.id
        end
      end
    end

    uniq_user_ids = user_ids.compact.uniq

    uniq_user_ids.each do |user_id|
      (start_date .. end_date).each do |d|
        user = User.find_by(id: user_id)
        d_location = ProfileService.location(user, d.to_datetime)
        d_department = ProfileService.department(user, d.to_datetime)

        ro = nil

        if d_location == nil || d_department == nil

        elsif d_location.id == location_id && d_department.id == department_id
          ro = RosterObject.where(user_id: user_id,
                                  location_id: location_id,
                                  department_id: department_id,
                                  roster_date: d,
                                  is_active: ['active', nil]).first

          if ro == nil
            ro = roster_list.roster_objects.create(location_id: location_id,
                                                   department_id: department_id,
                                                   user_id: user_id,
                                                   roster_date: d,
                                                   roster_list_id: roster_list.id,
                                                  )
          else
            ro.roster_list_id = roster_list.id
            ro.save
          end
        else
          ros = RosterObject.where(user_id: user_id,
                                   location_id: location_id,
                                   department_id: department_id,
                                   roster_date: d)
          ro = ros.where(is_active: 'inactive').first
          a_ro = ros.where(is_active: ['active', nil]).first

          if a_ro
            ro = a_ro
          end

          if ro == nil
            ro = roster_list.roster_objects.create(location_id: location_id,
                                                   department_id: department_id,
                                                   user_id: user_id,
                                                   roster_date: d,
                                                   roster_list_id: roster_list.id,
                                                   is_active: 'inactive',
                                                  )
          else
            ro.roster_list_id = roster_list.id
            ro.save
          end

          active_ro = RosterObject.where(user_id: user_id,
                                         location_id: d_location.id,
                                         department_id: d_department.id,
                                         roster_date: d,
                                         is_active: ['active', nil]).first

          if active_ro
            ro.copy_from_active(active_ro)
          end
        end


        # ro = RosterObject.where(user_id: user_id,
        #                         location_id: location_id,
        #                         department_id: department_id,
        #                         roster_date: d).first
        # if ro == nil
        #   ro = roster_list.roster_objects.create(location_id: location_id,
        #                                          department_id: department_id,
        #                                          user_id: user_id,
        #                                          roster_date: d,
        #                                          roster_list_id: roster_list.id,
        #                                         )
        # else
        #   # ro.location_id = location_id
        #   # ro.department_id = department_id
        #   ro.roster_list_id = roster_list.id
        #   ro.save
        # end

        # if hrf = HolidayRecord.where(user_id: user_id).where("start_date <= ? AND end_date >= ?", ro.roster_date, ro.roster_date).first
        #   time_string_array = hrf.input_time.split(':').map(& :to_i)
        #   date = hrf.input_date
        #   approval_time = DateTime.new(date.year, date.month, date.day, time_string_array[0], time_string_array[1], time_string_array[2])
        #   ro.roster_object_logs.create(modified_reason: hrf.holiday_type, approver_id: hrf.creator_id, approval_time: approval_time)
        # end

        if ro
          if ro.roster_object_logs.empty?
            ro.roster_object_logs.create(approver_id: current_user.id,
                                         approval_time: Time.zone.now.to_datetime,
                                         class_setting_id: ro.class_setting_id,
                                         is_general_holiday: ro.is_general_holiday,
                                         working_time: ro.working_time,
                                         holiday_type: ro.holiday_type,
                                         borrow_return_type: ro.borrow_return_type,
                                         working_hours_transaction_record_id: ro.working_hours_transaction_record_id,
                                        )
          end


          att = Attend.find_attend_by_user_and_date(user_id, d)
          if att == nil
            Attend.create(user_id: user_id,
                          attend_date: d.in_time_zone,
                          attend_weekday: d.in_time_zone.wday,
                          roster_object_id: ro.id,
                         )
          else
            att.roster_object_id = ro.id
            att.save!
          end
        end
      end
    end
  end

  def self.has_nil_roster_objects_of_user?(user, start_date, end_date, location_id, department_id)
    range_count = (end_date - start_date).to_i + 1

    date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

    position_resigned_date = user.profile.data['position_information']['field_values']['resigned_date']
    leave = position_resigned_date ? position_resigned_date.in_time_zone.to_date : nil

    ros = RosterObject.where(user_id: user.id, roster_date: start_date..end_date, location_id: location_id, department_id: department_id)
    not_nil_count = ros.reduce(0) do |sum, r|
      is_entry = r.roster_date >= entry
      is_leave = leave ? r.roster_date > leave : false
      is_active = r.is_active == 'active' || r.is_active == nil
      sum = (is_entry && !is_leave && is_active && r.class_setting_id == nil && r.is_general_holiday != true && r.working_time == nil && r.holiday_type == nil) ? sum : (sum + 1)
      sum
    end

    not_nil_count < range_count ? true : false
  end

  def self.find_roster_object_by_user_and_date(user_id, date)
    RosterObject.where(user_id: user_id, roster_date: date).first
  end

  def self.object_for_special_type(user_id, current_user, type, target_location_id, target_department_id, start_date, end_date)
    user = User.find_by(id: user_id)

    (start_date .. end_date).each do |d|
      ro = RosterObject.where(user_id: user.id, is_active: ['active', nil], roster_date: d).first
      if ro
        RosterObject.create(ro.attributes.merge({
                                                  id: nil,
                                                  is_active: 'inactive',
                                                  special_type: type,
                                                  created_at: nil,
                                                  updated_at: nil
                                                }))
        ro.is_active = 'active'
        ro.special_type = type
        ro.class_setting_id = ro.borrow_return_type || ro.adjust_type ? ro.class_setting_id : nil
        ro.location_id = target_location_id ? target_location_id : user.location_id
        ro.department_id = target_department_id ? target_department_id : user.department_id
        # ro.roster_list_id = nil
        ro.roster_list_id = RosterList.find_list(ro.roster_date, ro.location_id, ro.department_id)&.id
        ro.save

        ro.roster_object_logs.create(modified_reason: type,
                                     approver_id: current_user.id,
                                     approval_time: Time.zone.now.to_datetime,
                                     class_setting_id: ro.class_setting_id,
                                     is_general_holiday: ro.is_general_holiday,
                                     working_time: ro.working_time,
                                     holiday_type: ro.holiday_type,
                                     borrow_return_type: ro.borrow_return_type,
                                     working_hours_transaction_record_id: ro.working_hours_transaction_record_id,
                                    )
      else
        d_time = Time.zone.local(d.year, d.month, d.day).to_datetime.beginning_of_day
        o_location = ProfileService.location(user, d_time)
        o_department = ProfileService.department(user, d_time)

        inactive_ro = RosterObject.create(user_id: user.id,
                                          roster_date: d,
                                          location_id: o_location.id,
                                          department_id: o_department.id,
                                          is_active: 'inactive',
                                          special_type: type)

        # inactive_ro.roster_object_logs.create(approver_id: current_user.id,
        #                                       approval_time: Time.zone.now.to_datetime,
        #                                       class_setting_id: inactive_ro.class_setting_id,
        #                                       is_general_holiday: inactive_ro.is_general_holiday,
        #                                       working_time: inactive_ro.working_time
        #                                      )

        active_ro = RosterObject.create(user_id: user.id,
                                        roster_date: d,
                                        location_id: target_location_id,
                                        department_id: target_department_id,
                                        is_active: 'active',
                                        special_type: type)

        active_ro.roster_object_logs.create(modified_reason: type,
                                            approver_id: current_user.id,
                                            approval_time: Time.zone.now.to_datetime,
                                            class_setting_id: active_ro.class_setting_id,
                                            is_general_holiday: active_ro.is_general_holiday,
                                            working_time: active_ro.working_time,
                                            holiday_type: active_ro.holiday_type,
                                            borrow_return_type: active_ro.borrow_return_type,
                                            working_hours_transaction_record_id: active_ro.working_hours_transaction_record_id,
                                           )


      end

    end
  end

  def self.update_object_for_special_type(old_special_schedule_setting, new_special_schedule_setting, current_user)
    user = User.find_by(id: old_special_schedule_setting.user_id)

    # old
    (old_special_schedule_setting.date_begin.to_datetime .. old_special_schedule_setting.date_end.to_datetime).each do |d|
      d_time = Time.zone.local(d.year, d.month, d.day).to_datetime.beginning_of_day
      o_location = ProfileService.location(user, d_time)
      o_department = ProfileService.department(user, d_time)

      ro = RosterObject.where(user_id: user.id, roster_date: d, location_id: o_location.id, department_id: o_department.id, is_active: 'inactive', special_type: 'special_roster').first
      ro.destroy if ro
    end

    (old_special_schedule_setting.date_begin.to_datetime .. old_special_schedule_setting.date_end.to_datetime).each do |d|
      ro = RosterObject.where(user_id: user.id, roster_date: d, location_id: old_special_schedule_setting.target_location_id, department_id: old_special_schedule_setting.target_department_id, is_active: 'active', special_type: 'special_roster').first
      if ro
        ro.class_setting_id = nil
        ro.is_general_holiday = nil
        ro.working_time = nil
        ro.holiday_type = nil
        ro.location_id = user.location_id
        ro.department_id = user.department_id
        ro.is_active = 'active'
        ro.special_type = nil
        ro.save
      end
    end

    # new
    (old_special_schedule_setting.date_begin.to_datetime .. old_special_schedule_setting.date_end.to_datetime).each do |d|
      d_time = Time.zone.local(d.year, d.month, d.day).to_datetime.beginning_of_day
      o_location = ProfileService.location(user, d_time)
      o_department = ProfileService.department(user, d_time)

      ro = RosterObject.where(user_id: user.id, roster_date: d, location_id: o_location.id, department_id: o_department).first
      if ro
        RosterObject.create(ro.attributes.merge({
                                                  id: nil,
                                                  is_active: 'inactive',
                                                  special_type: 'special_roster',
                                                  created_at: nil,
                                                  updated_at: nil
                                                }))
        ro.is_active = 'active'
        ro.special_type = 'special_roster'
        ro.class_setting_id = ro.borrow_return_type || ro.adjust_type ? ro.class_setting_id : nil
        ro.location_id = new_special_schedule_setting.target_location_id
        ro.department_id = new_special_schedule_setting.target_department_id
        # ro.roster_list_id = nil
        ro.roster_list_id = RosterList.find_list(ro.roster_date, ro.location_id, ro.department_id)&.id
        ro.save

        ro.roster_object_logs.create(modified_reason: 'special_roster',
                                     approver_id: current_user.id,
                                     approval_time: Time.zone.now.to_datetime,
                                     class_setting_id: ro.class_setting_id,
                                     is_general_holiday: ro.is_general_holiday,
                                     working_time: ro.working_time,
                                     holiday_type: ro.holiday_type,
                                     borrow_return_type: ro.borrow_return_type,
                                     working_hours_transaction_record_id: ro.working_hours_transaction_record_id,
                                    )
      else
        d_time = Time.zone.local(d.year, d.month, d.day).to_datetime.beginning_of_day
        o_location = ProfileService.location(user, d_time)
        o_department = ProfileService.department(user, d_time)

        inactive_ro = RosterObject.create(user_id: user.id,
                                          roster_date: d,
                                          location_id: o_location.id,
                                          department_id: o_department.id,
                                          is_active: 'inactive',
                                          special_type: 'special_roster')

        # inactive_ro.roster_object_logs.create(approver_id: current_user.id,
        #                                       approval_time: Time.zone.now.to_datetime,
        #                                       class_setting_id: inactive_ro.class_setting_id,
        #                                       is_general_holiday: inactive_ro.is_general_holiday,
        #                                       working_time: inactive_ro.working_time
        #                                      )

        active_ro = RosterObject.create(user_id: user.id,
                                        roster_date: d,
                                        location_id: new_special_schedule_setting.target_location_id,
                                        department_id: new_special_schedule_setting.target_department_id,
                                        is_active: 'active',
                                        special_type: 'special_roster')

        active_ro.roster_object_logs.create(modified_reason: 'special_roster',
                                            approver_id: current_user.id,
                                            approval_time: Time.zone.now.to_datetime,
                                            class_setting_id: active_ro.class_setting_id,
                                            is_general_holiday: active_ro.is_general_holiday,
                                            working_time: active_ro.working_time,
                                            holiday_type: active_ro.holiday_type,
                                            borrow_return_type: active_ro.borrow_return_type,
                                            working_hours_transaction_record_id: active_ro.working_hours_transaction_record_id,
                                           )


      end
    end
  end

  def self.update_attend_and_states(roster_object)
    user_id = roster_object.user_id
    date = roster_object.roster_date
    att = Attend.find_attend_by_user_and_date(user_id, date)

    if att == nil
      att = Attend.create(user_id: user_id,
                          attend_date: date,
                          attend_weekday: date.wday,
                         )
    end

    user = User.find_by(id: user_id)
    can_punch = user && user.punch_card_state_of_date(roster_object.roster_date)

    if user
      if roster_object.is_general_holiday
        # initial all
        att.attend_states.where.not(auto_state: nil).each { |state| state.destroy if state }

        att_on_work_time = att.on_work_time
        att_off_work_time = att.off_work_time

        overtime_records = OvertimeRecord
                             .where(user_id: att.user_id,
                                    source_id: nil,
                                    is_deleted: [false, nil])
                             .where("overtime_start_date <= ? AND overtime_end_date >= ?", att.attend_date, att.attend_date)

        sign_card_records = SignCardRecord
                              .where(user_id: att.user_id,
                                     source_id: nil,
                                     is_deleted: [false, nil])
                              .where(sign_card_date: att.attend_date)

        if (att_on_work_time != nil || att_off_work_time != nil || sign_card_records.count > 0) && overtime_records.count <= 0
          att.attend_states.find_or_create_by(auto_state: 'punching_card_on_holiday_exception') if can_punch
        end

      elsif roster_object.class_setting_id || roster_object.working_time
        # initial all
        att.attend_states.where.not(auto_state: nil).each { |state| state.destroy if state }

        true_records = WorkingHoursTransactionRecord.where(source_id: nil, is_deleted: [false, nil])

        whts = true_records.where(user_a_id: roster_object.user_id, apply_date: roster_object.roster_date)
                 .or(true_records.where(user_b_id: roster_object.user_id, apply_date: roster_object.roster_date))

        wht = whts.first

        plan_start_time = nil
        plan_end_time = nil
        tmp_plan_start_time = nil
        tmp_plan_end_time = nil
        ro_date = roster_object.roster_date
        class_setting = roster_object.class_setting

        if roster_object.class_setting_id
          tmp_plan_start_time, tmp_plan_end_time = att.compute_time(ro_date, class_setting)
        elsif roster_object.working_time
          tmp_plan_start_time, tmp_plan_end_time = att.transform_working_time(ro_date, roster_object.working_time)
        end

        if wht
          wht_start_time, wht_end_time = wht.fmt_final_time

          should_merge = (wht.apply_type == 'borrow_hours' && wht.user_a_id == roster_object.user_id) || (wht.apply_type == 'return_hours' && wht.user_b_id == roster_object.user_id) ? false : true

          if should_merge
            plan_start_time = tmp_plan_start_time < wht_start_time ? tmp_plan_start_time : wht_start_time
            plan_end_time = tmp_plan_end_time > wht_end_time ? tmp_plan_end_time : wht_end_time
          else
            if tmp_plan_start_time == wht_start_time
              plan_start_time = wht_end_time < tmp_plan_end_time ? wht_end_time : tmp_plan_end_time
            else
              plan_start_time = tmp_plan_start_time < wht_start_time ? tmp_plan_start_time : wht_start_time
            end

            if tmp_plan_end_time == wht_end_time
              plan_end_time = wht_start_time > tmp_plan_start_time ? wht_start_time : tmp_plan_start_time
            else
              plan_end_time = tmp_plan_end_time > wht_end_time ? tmp_plan_end_time : wht_end_time
            end
          end
        end

        plan_start_time = plan_start_time ? plan_start_time : tmp_plan_start_time
        plan_end_time = plan_end_time ? plan_end_time : tmp_plan_end_time

        # 迟到时间点
        late_be_allowed_minutes = class_setting ? class_setting&.late_be_allowed&.to_i : 0
        late_time = plan_start_time + late_be_allowed_minutes.minute
        # 早退时间点

        leave_be_allowed_minutes = class_setting ? class_setting&.leave_be_allowed&.to_i : 0
        leave_early_time = plan_end_time - leave_be_allowed_minutes.minute
        # 中间时间点
        mid_time = Time.zone.at((plan_start_time.to_i + plan_end_time.to_i) / 2).to_datetime

        # 最晚上班时间点、最早下班时间点
        latest_start_punch = earliest_end_punch = mid_time
        # 最早上班时间点
        # earliest_start_punch = plan_start_time - 480.minute
        # 最晚下班时间点
        # latest_end_punch = plan_end_time + 480.minute

        att_on_work_time = att.on_work_time
        att_off_work_time = att.off_work_time
        now = Time.zone.now.to_date

        if att_on_work_time == nil && att.attend_date < now
          att.attend_states.find_or_create_by(auto_state: 'on_work_punching_exception') if can_punch
        end

        if att_off_work_time == nil && att.attend_date < now
          att.attend_states.find_or_create_by(auto_state: 'off_work_punching_exception') if can_punch
        end

        if att_on_work_time
          if att_on_work_time > late_time
            att.attend_states.find_or_create_by(auto_state: 'late') if can_punch
          end
        end

        if att_off_work_time
          if att_off_work_time < leave_early_time
            att.attend_states.find_or_create_by(auto_state: 'leave_early_by_auto') if can_punch
          end
        end

        overtime_records = OvertimeRecord
                             .where(user_id: att.user_id,
                                    source_id: nil,
                                    is_deleted: [false, nil])
                             .where("overtime_start_date <= ? AND overtime_end_date >= ?", att.attend_date, att.attend_date)
        has_overtime_records = overtime_records.count > 0

        holiday_records = HolidayRecord
                            .where(user_id: att.user_id,
                                   source_id: nil,
                                   is_deleted: [false, nil])
                            .where("start_date <= ? AND end_date >= ?", att.attend_date, att.attend_date)

        has_holiday_records = holiday_records.count > 0

        sign_card_records = SignCardRecord
                              .where(user_id: att.user_id,
                                     source_id: nil,
                                     is_deleted: [false, nil])
                              .where(sign_card_date: att.attend_date)
        has_sign_card_records = sign_card_records.count > 0

        if (att_on_work_time != nil || att_off_work_time != nil || has_sign_card_records) &&
           has_holiday_records &&
           !has_overtime_records
          att.attend_states.find_or_create_by(auto_state: 'punching_card_on_holiday_exception') if can_punch
        end
      end
    end
  end

  def self.update_attend_and_states_for_nil(roster_object)
    user_id = roster_object.user_id
    date = roster_object.roster_date
    att = Attend.find_attend_by_user_and_date(user_id, date)

    if att == nil
      att = Attend.create(user_id: user_id,
                          attend_date: date,
                          attend_weekday: date.wday,
                         )
    end

    # user = User.find_by(id: user_id)
    # can_punch = user && user.punch_card_state_of_date(roster_object.roster_date)

    att.attend_states.where.not(auto_state: nil).each { |state| state.destroy if state }
  end

  def self.update_attend_states_after_working_hours_transaction(roster_object, wht, should_merge)
    user_id = roster_object.user_id
    date = roster_object.roster_date

    att = Attend.find_attend_by_user_and_date(user_id, date)

    if att == nil
      att = Attend.create(user_id: user_id,
                          attend_date: date,
                          attend_weekday: date.wday,
                         )
    end

    user = User.find_by(id: user_id)
    can_punch = user && user.punch_card_state_of_date(roster_object.roster_date)

    if roster_object.class_setting_id || roster_object.working_time
      # initial all
      att.attend_states.where.not(auto_state: nil).each { |state| state.destroy if state }

      plan_start_time = nil
      plan_end_time = nil
      tmp_plan_start_time = nil
      tmp_plan_end_time = nil
      ro_date = roster_object.roster_date
      class_setting = roster_object.class_setting

      if roster_object.class_setting_id
        tmp_plan_start_time, tmp_plan_end_time = att.compute_time(ro_date, class_setting)
      elsif roster_object.working_time
        tmp_plan_start_time, tmp_plan_end_time = att.transform_working_time(ro_date, roster_object.working_time)
      end

      wht_start_time, wht_end_time = wht.fmt_final_time

      if should_merge
        plan_start_time = tmp_plan_start_time < wht_start_time ? tmp_plan_start_time : wht_start_time
        plan_end_time = tmp_plan_end_time > wht_end_time ? tmp_plan_end_time : wht_end_time
      else
        if tmp_plan_start_time == wht_start_time
          plan_start_time = wht_end_time < tmp_plan_end_time ? wht_end_time : tmp_plan_end_time
        else
          plan_start_time = tmp_plan_start_time < wht_start_time ? tmp_plan_start_time : wht_start_time
        end

        if tmp_plan_end_time == wht_end_time
          plan_end_time = wht_start_time > tmp_plan_start_time ? wht_start_time : tmp_plan_start_time
        else
          plan_end_time = tmp_plan_end_time > wht_end_time ? tmp_plan_end_time : wht_end_time
        end
      end

      # 迟到时间点
      late_be_allowed_minutes = class_setting ? class_setting&.late_be_allowed&.to_i : 0
      late_time = plan_start_time + late_be_allowed_minutes.minute
      # 早退时间点

      leave_be_allowed_minutes = class_setting ? class_setting&.leave_be_allowed&.to_i : 0
      leave_early_time = plan_end_time - leave_be_allowed_minutes.minute
      # 中间时间点
      mid_time = Time.zone.at((plan_start_time.to_i + plan_end_time.to_i) / 2).to_datetime

      # 最晚上班时间点、最早下班时间点
      latest_start_punch = earliest_end_punch = mid_time

      att_on_work_time = att.on_work_time
      att_off_work_time = att.off_work_time
      now = Time.zone.now.to_date

      if att_on_work_time == nil && att.attend_date < now
        att.attend_states.find_or_create_by(auto_state: 'on_work_punching_exception') if can_punch
      end

      if att_off_work_time == nil && att.attend_date < now
        att.attend_states.find_or_create_by(auto_state: 'off_work_punching_exception') if can_punch
      end

      if att_on_work_time
        if att_on_work_time > late_time && att_on_work_time < latest_start_punch
          att.attend_states.find_or_create_by(auto_state: 'late') if can_punch
        end
      end

      if att_off_work_time
        if att_off_work_time > earliest_end_punch && att_off_work_time < leave_early_time
          att.attend_states.find_or_create_by(auto_state: 'leave_early_by_auto') if can_punch
        end
      end

      overtime_records = OvertimeRecord
                           .where(user_id: att.user_id,
                                  source_id: nil,
                                  is_deleted: [false, nil])
                           .where("overtime_start_date <= ? AND overtime_end_date >= ?", att.attend_date, att.attend_date)
      has_overtime_records = overtime_records.count > 0

      holiday_records = HolidayRecord
                          .where(user_id: att.user_id,
                                 source_id: nil,
                                 is_deleted: [false, nil])
                          .where("start_date <= ? AND end_date >= ?", att.attend_date, att.attend_date)

      has_holiday_records = holiday_records.count > 0

      if (att_on_work_time != nil || att_off_work_time != nil) &&
         has_holiday_records &&
         !has_overtime_records

        att.attend_states.find_or_create_by(auto_state: 'punching_card_on_holiday_exception') if can_punch
      end

    end

  end

  def self.fmt_colon(t)
    time_regexp = /\d{4}/
    if match_data = time_regexp.match(t)
      match_t = match_data[0]
      h = match_t[0, 2]
      m = match_t[2, 2]
      return [h, m].join(':')
    end
  end

  def self.fmt_time_with_next(t)
    time_regexp = /\d{4}/
    if match_data = time_regexp.match(t)
      match_t = match_data[0]
      # h = match_t[0, 2]
      h = match_t[0, 2].to_i
      real_h = "#{h + 24}"
      m = match_t[2, 2]

      return [real_h, m].join(':')
    end
  end

  def copy_from_active(template_ro)
    self.class_setting_id = template_ro.class_setting_id
    self.is_general_holiday = template_ro.is_general_holiday
    self.working_time = template_ro.working_time
    self.holiday_type = template_ro.holiday_type
    self.holiday_record_id = template_ro.holiday_record_id
    self.borrow_return_type = template_ro.borrow_return_type
    self.working_hours_transaction_record_id = template_ro.working_hours_transaction_record_id
    self.adjust_type = template_ro.adjust_type
    self.save
  end

  def self.update_open_time(user, date, current_user, transfer_location_id, type, transfer_department_id)

    should_change_roster_objects = RosterObject
                                     .where(user_id: user.id, is_active: ['active', nil])
                                     .where("roster_date >= ?", date)

    should_change_roster_objects.each do |ro|
      RosterObject.create(ro.attributes.merge({
                                                id: nil,
                                                is_active: 'inactive',
                                                special_type: type,
                                                created_at: nil,
                                                updated_at: nil
                                              }))
      ro.is_active = 'active'
      ro.special_type = type
      ro.class_setting_id = ro.borrow_return_type || ro.adjust_type ? ro.class_setting_id : nil
      ro.location_id = transfer_location_id ? transfer_location_id : ro.location_id
      ro.department_id = transfer_department_id ? transfer_department_id : ro.department_id
      # ro.roster_list_id = nil
      ro.roster_list_id = RosterList.find_list(ro.roster_date, ro.location_id, ro.department_id)&.id
      ro.save

      ro.roster_object_logs.create(modified_reason: type,
                                   approver_id: current_user.id,
                                   approval_time: Time.zone.now.to_datetime,
                                   class_setting_id: ro.class_setting_id,
                                   is_general_holiday: ro.is_general_holiday,
                                   working_time: ro.working_time,
                                   holiday_type: ro.holiday_type,
                                   borrow_return_type: ro.borrow_return_type,
                                   working_hours_transaction_record_id: ro.working_hours_transaction_record_id,
                                  )
    end
  end

  def self.update_close_time(user, start_date, end_date, current_user, transfer_location_id, type, transfer_department_id)
    before_date = start_date - 1.day
    d_time = before_date.to_datetime.beginning_of_day
    o_location = ProfileService.location(user, d_time)
    o_department = ProfileService.department(user, d_time)

    (start_date .. end_date).each do |d|
      ro = RosterObject.where(user_id: user.id, is_active: ['active', nil], roster_date: d, location_id: o_location&.id).first
      if ro
        RosterObject.create(ro.attributes.merge({
                                                  id: nil,
                                                  is_active: 'inactive',
                                                  special_type: type,
                                                  created_at: nil,
                                                  updated_at: nil
                                                }))

        ro.is_active = 'active'
        ro.special_type = type
        ro.class_setting_id = ro.borrow_return_type || ro.adjust_type ? ro.class_setting_id : nil
        ro.location_id = transfer_location_id ? transfer_location_id : ro.location_id
        ro.department_id = transfer_department_id ? transfer_department_id : ro.department_id
        # ro.roster_list_id = nil
        ro.roster_list_id = RosterList.find_list(ro.roster_date, ro.location_id, ro.department_id)&.id
        ro.save

        ro.roster_object_logs.create(modified_reason: type,
                                     approver_id: current_user.id,
                                     approval_time: Time.zone.now.to_datetime,
                                     class_setting_id: ro.class_setting_id,
                                     is_general_holiday: ro.is_general_holiday,
                                     working_time: ro.working_time,
                                     holiday_type: ro.holiday_type,
                                     borrow_return_type: ro.borrow_return_type,
                                     working_hours_transaction_record_id: ro.working_hours_transaction_record_id,
                                    )
      else
        # d_time = Time.zone.local(d.year, d.month, d.day).to_datetime.beginning_of_day
        # d_time = before_date.to_datetime.beginning_of_day
        # o_location = ProfileService.location(user, d_time)
        # o_department = ProfileService.department(user, d_time)

        inactive_ro = RosterObject.create(user_id: user.id,
                                          roster_date: d,
                                          location_id: o_location&.id,
                                          department_id: o_department&.id,
                                          is_active: 'inactive',
                                          special_type: type)

        active_ro = RosterObject.create(user_id: user.id,
                                        roster_date: d,
                                        location_id: transfer_location_id,
                                        department_id: o_department&.id,
                                        is_active: 'active',
                                        special_type: type)

        active_ro.roster_object_logs.create(modified_reason: type,
                                            approver_id: current_user.id,
                                            approval_time: Time.zone.now.to_datetime,
                                            class_setting_id: active_ro.class_setting_id,
                                            is_general_holiday: active_ro.is_general_holiday,
                                            working_time: active_ro.working_time,
                                            holiday_type: active_ro.holiday_type,
                                            borrow_return_type: active_ro.borrow_return_type,
                                            working_hours_transaction_record_id: active_ro.working_hours_transaction_record_id,
                                           )
      end
    end
  end

  def self.destroy_open_time(user, date, transfer_location_id, type, transfer_department_id)
    before_date = date - 1.day
    d_time = before_date.to_datetime.beginning_of_day
    o_location = ProfileService.location(user, d_time)
    o_department = ProfileService.department(user, d_time)

    should_change_roster_objects = RosterObject
                                     .where(user_id: user.id, is_active: ['active', nil])
                                     .where("roster_date >= ?", date)


    should_change_roster_objects.each do |ro|
      should_destroy_ro = RosterObject.where(user_id: user.id, roster_date: ro.roster_date, location_id: o_location&.id, department_id: o_department&.id, is_active: 'inactive', special_type: type).first
      ro.destroy if should_destroy_ro
    end

    should_change_roster_objects.each do |ro|
      dept_id = transfer_department_id || o_department&.id

      should_change_ro = RosterObject.where(user_id: user.id, roster_date: ro.roster_date, location_id: transfer_location_id, department_id: dept_id, is_active: ['active', nil], special_type: type).first
      if should_change_ro
        should_change_ro.is_active = 'active'
        should_change_ro.special_type = nil
        should_change_ro.class_setting_id = ro.borrow_return_type || ro.adjust_type ? ro.class_setting_id : nil
        should_change_ro.location_id = o_location&.id
        should_change_ro.department_id = o_department&.id
        # should_change_ro.roster_list_id = nil
        should_change_ro.roster_list_id = RosterList.find_list(should_change_ro.roster_date, should_change_ro.location_id, should_change_ro.department_id)&.id
        should_change_ro.save
      end
    end
  end

  def self.destroy_close_time(user, start_date, end_date, transfer_location_id, type, transfer_department_id)
    before_date = start_date - 1.day
    d_time = before_date.to_datetime.beginning_of_day
    o_location = ProfileService.location(user, d_time)
    o_department = ProfileService.department(user, d_time)

    (start_date .. end_date).each do |d|
      ro = RosterObject.where(user_id: user.id, roster_date: d, location_id: o_location&.id, department_id: o_department&.id, is_active: 'inactive', special_type: type).first
      ro.destroy if ro
    end

    (start_date .. end_date).each do |d|
      dept_id = transfer_department_id || o_department&.id
      ro = RosterObject.where(user_id: user.id, roster_date: d, location_id: transfer_location_id, department_id: dept_id, is_active: 'active', special_type: type).first
      if ro
        ro.class_setting_id = nil
        ro.is_general_holiday = nil
        ro.working_time = nil
        ro.holiday_type = nil
        ro.location_id = o_location&.id,
        ro.department_id = o_department&.id
        ro.is_active = 'active'
        ro.special_type = nil
        ro.save
      end
    end
  end

  def update_reports
    AttendMonthlyReport.update_calc_status(self.user_id, self.roster_date)
    AttendAnnualReport.update_calc_status(self.user_id, self.roster_date)
  end
end
