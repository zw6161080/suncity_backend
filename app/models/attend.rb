# coding: utf-8
# == Schema Information
#
# Table name: attends
#
#  id               :integer          not null, primary key
#  region           :string
#  user_id          :integer
#  attend_date      :date
#  attend_weekday   :integer
#  roster_object_id :integer
#  on_work_time     :datetime
#  off_work_time    :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_attends_on_roster_object_id  (roster_object_id)
#  index_attends_on_user_id           (user_id)
#

class Attend < ApplicationRecord
  belongs_to :user
  belongs_to :roster_object
  has_many :attend_logs, dependent: :destroy
  has_many :attend_states, dependent: :destroy

  scope :by_location_ids, lambda { |location_ids, start_d, end_d|
    if location_ids && start_d && end_d
      # joins(:user).where(users: { location_id: location_ids })
      int_location_ids = location_ids.map(& :to_i)

      u_ids = []
      start_ymd = Time.zone.parse(start_d).to_date
      end_ymd = Time.zone.parse(end_d).to_date
      # start_end_month = (start_ym .. end_ym).map { |d| d.end_of_month }.compact.uniq
      all_users = User.all
      (start_ymd .. end_ymd).each do |d|
        all_users.each do |u|
          location = ProfileService.location(u, d)
          u_ids << u.id if (location && int_location_ids.include?(location.id))
        end
      end

      where(user_id: u_ids)
    end
  }

  scope :by_department_ids, lambda { |department_ids, start_d, end_d|
    if department_ids && start_d && end_d
      # joins(:user).where(users: { department_id: department_ids })
      int_department_ids = department_ids.map(& :to_i)

      u_ids = []
      start_ymd = Time.zone.parse(start_d).to_date
      end_ymd = Time.zone.parse(end_d).to_date
      # start_end_month = (start_ym .. end_ym).map { |d| d.end_of_month }.compact.uniq
      all_users = User.all
      (start_ymd .. end_ymd).each do |d|
        all_users.each do |u|
          department = ProfileService.department(u, d)
          u_ids << u.id if (department && int_department_ids.include?(department.id))
        end
      end

      where(user_id: u_ids)
    end
  }

  scope :by_users, lambda { |user_ids|
    where(user_id: user_ids) if user_ids
  }

  scope :by_no_admin, lambda {
    where.not(user_id: [2, 120])
  }

  # scope :by_user, lambda { |user_name, lang|
  #   if user_name
  #     user_ids = User.where("#{lang} like ?", "%#{user_name}%")
  #     where(user_id: user_ids)
  #   end
  # }

  scope :by_attend_date, lambda { |start_date, end_date|
    if start_date && end_date
      # where("attend_date >= ? AND attend_date <= ?", start_date, end_date)
      where(attend_date:  start_date..end_date)
    elsif start_date && !end_date
      where("attend_date >= ?", start_date)
    elsif !start_date && end_date
      where("attend_date <= ?", end_date)
    end
  }

  scope :by_attend_states, lambda { |states|
    if states
      ids = []
      true_states = states.select { |s| s != 'all' }
      query = self
      if true_states.empty?
      # query
      else
        query.all.each do |att|
          # if states.select { |s| s == 'all'}.count > 0
          #   ids << att.id if att.attend_states.where.not(auto_state: nil).count > 0
          # else
          #   ids << att.id if att.attend_states.where(auto_state: states).count > 0
          # end
          if true_states.select { |s| s == 'punching_card_on_holiday_exception' }.count > 0 && att.attend_states.where(auto_state: 'punching_card_on_holiday_exception').count > 0
            if att.attend_states.where.not(auto_state: ['late', 'leave_early_by_auto', 'on_work_punching_exception', 'off_work_punching_exception'])
                 .where(auto_state: true_states).count > 0
              ids << att.id
            end
          end

          if true_states.select { |s| s == 'late' }.count > 0 && att.attend_states.where(auto_state: 'late').count > 0
            on_signcard_records = SignCardRecord.where(user_id: att.user_id,
                                                       source_id: nil,
                                                       is_get_to_work: true,
                                                       is_deleted: [false, nil],
                                                       sign_card_date: att.attend_date.to_date)

            hr = HolidayRecord.where(user_id: att.user_id, source_id: nil, is_deleted: [false, nil])
                   .where("start_date <= ? AND end_date >= ?", att.attend_date, att.attend_date)

            ids << att.id if (on_signcard_records.count <= 0 && hr.count <= 0)
          end

          if true_states.select { |s| s == 'leave_early_by_auto' }.count > 0 && att.attend_states.where(auto_state: 'leave_early_by_auto').count > 0
            off_signcard_records = SignCardRecord.where(user_id: att.user_id,
                                                        source_id: nil,
                                                        is_get_to_work: false,
                                                        is_deleted: [false, nil],
                                                        sign_card_date: att.attend_date.to_date)
            hr = HolidayRecord.where(user_id: att.user_id, source_id: nil, is_deleted: [false, nil])
                   .where("start_date <= ? AND end_date >= ?", att.attend_date, att.attend_date)

            ids << att.id if (off_signcard_records.count <= 0 && hr.count <= 0)
          end

          if true_states.select { |s| s == 'on_work_punching_exception' }.count > 0 && att.attend_states.where(auto_state: 'on_work_punching_exception').count > 0
            on_signcard_records = SignCardRecord.where(user_id: att.user_id,
                                                       source_id: nil,
                                                       is_get_to_work: true,
                                                       is_deleted: [false, nil],
                                                       sign_card_date: att.attend_date.to_date)
            hr = HolidayRecord.where(user_id: att.user_id, source_id: nil, is_deleted: [false, nil])
                   .where("start_date <= ? AND end_date >= ?", att.attend_date, att.attend_date)

            ids << att.id if (on_signcard_records.count <= 0 && hr.count <= 0)
          end

          if true_states.select { |s| s == 'off_work_punching_exception' }.count > 0 && att.attend_states.where(auto_state: 'off_work_punching_exception').count > 0
            off_signcard_records = SignCardRecord.where(user_id: att.user_id,
                                                        source_id: nil,
                                                        is_get_to_work: false,
                                                        is_deleted: [false, nil],
                                                        sign_card_date: att.attend_date.to_date)

            hr = HolidayRecord.where(user_id: att.user_id, source_id: nil, is_deleted: [false, nil])
                   .where("start_date <= ? AND end_date >= ?", att.attend_date, att.attend_date)

            ids << att.id if (off_signcard_records.count <= 0 && hr.count <= 0)
          end
          # else
          # if att.attend_states.where(auto_state: true_states).count > 0
          #   ids << att.id
          # end
          # end
        end
        query = query.where(id: ids.compact.uniq)
        query
      end
    end
  }

  def self.find_attend_by_user_and_date(user_id, date)
    Attend.where(user_id: user_id, attend_date: date).first
  end

  def self.find_attend_by_user_and_date_and_object(user_id, date, roster_object_id)
    Attend.where(user_id: user_id, attend_date: date, roster_object_id: roster_object_id).first
  end

  def self.complete_attend_table_for(location_ids, department_ids, user_ids, attend_start_date, attend_end_date)
    # start_date = attend_start_date ? attend_start_date : Time.zone.now.to_date
    # end_date = attend_end_date ? attend_end_date : Time.zone.now.to_date

    users_query = User.all
    users_with_locations = location_ids ? users_query.where(location_id: location_ids) : users_query
    users_with_departments = department_ids ? users_with_locations.where(department_id: department_ids) : users_with_locations
    users_with_ids = user_ids ? users_with_departments.where(id: user_ids) : users_with_departments

    all_user_ids = users_with_ids.pluck(:id)
    all_user_ids.each do |u_id|
      [*attend_start_date .. attend_end_date].each do |d|
        date = d.in_time_zone
        if Attend.find_attend_by_user_and_date(u_id, date) == nil
          Attend.create(user_id: u_id, attend_date: date, attend_weekday: date.wday)
        end
      end
    end
  end

  def self.update_working_time(datetime = Time.zone.now.to_datetime)
    # logs = RosterEventLogV2.of_ymd(2017, 11, 1).map(&:attributes).reduce({}) do |coll, log|
    #   coll[log['nUserID']] = Array(coll[log['nUserID']]).push(log['convertDatetime']) if log['convertDatetime'] && log['nUserID']
    #   coll
    # end

    logs = RosterEventLogV2.of_ymd(datetime.year, datetime.month, datetime.day).map(&:attributes).reduce({}) do |coll, log|
      coll[log['nUserID']] = Array(coll[log['nUserID']]).push(Time.zone.parse(log['convertDatetime'])) if log['convertDatetime'] && log['nUserID']
      coll
    end

    log_empoids = logs.keys.uniq.map { |empoid| empoid.to_s.rjust(8, '0') }
    # user_ids = User.where(empoid: log_empoids).pluck(:id, :empoid).to_h
    user_ids = User.where(empoid: log_empoids).pluck(:id)
    start_date = datetime.to_date - 1.day
    end_date = datetime.to_date

    # user_ids.each do |u_id|
    #   [*start_date .. end_date].each do |date|
    #     # date = d.in_time_zone
    #     if Attend.find_attend_by_user_and_date(u_id, date) == nil
    #       Attend.create(user_id: u_id, attend_date: date, attend_weekday: date.wday)
    #     end
    #   end
    # end

    all_attends = Attend.where(attend_date: start_date..end_date).includes(:roster_object)

    all_attends.each do |att|

      user_logs = logs[att.user.empoid.to_i.to_s]
      roster_object = att.roster_object
      can_punch = att&.user.punch_card_state_of_date(att&.attend_date)

      if user_logs == nil
        if roster_object &&
           roster_object.holiday_type == nil &&
           (roster_object.is_general_holiday == nil || roster_object.is_general_holiday == false) &&
           (roster_object.class_setting_id != nil || roster_object.working_time != nil)

          att.attend_states.where.not(auto_state: nil).each { |state| state.destroy if state }
          if can_punch
            att.attend_states.find_or_create_by(auto_state: 'on_work_punching_exception')
            att.attend_states.find_or_create_by(auto_state: 'off_work_punching_exception')
          end
        end
      elsif user_logs && roster_object != nil
         is_general_holiday = roster_object.is_general_holiday
        class_setting = roster_object.class_setting
        roster_date = roster_object.roster_date

        if (is_general_holiday == nil || is_general_holiday == false) && (!class_setting.nil? || roster_object.working_time != nil)
          true_records = WorkingHoursTransactionRecord.where(source_id: nil, is_deleted: [false, nil])

          whts = true_records.where(user_a_id: roster_object.user_id, apply_date: roster_object.roster_date)
                   .or(true_records.where(user_b_id: roster_object.user_id, apply_date: roster_object.roster_date))

          wht = whts.first

          plan_start_time = nil
          plan_end_time = nil
          tmp_plan_start_time = nil
          tmp_plan_end_time = nil

          if class_setting
            # 正常开始、结束时间
            tmp_plan_start_time, tmp_plan_end_time = att.compute_time(roster_date, class_setting)
          elsif roster_object.working_time
            tmp_plan_start_time, tmp_plan_end_time = att.transform_working_time(roster_date, roster_object.working_time)
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
          earliest_start_punch = plan_start_time - 480.minute
          # 最晚下班时间点
          latest_end_punch = plan_end_time + 480.minute

          # initial all states
          att.attend_states.where.not(auto_state: nil).each { |state| state.destroy if state }
          att.on_work_time = nil
          att.off_work_time = nil

          # 处理上班
          on_punching_card_records = user_logs.select { |log| log >= earliest_start_punch && log <= latest_start_punch }
          if on_punching_card_records.count == 0 && att.on_work_time == nil
            # 上班时间区间内没有打卡记录，就不要记录时间了
            # att.on_work_time = user_logs.sort.first
            att.attend_states.find_or_create_by(auto_state: 'on_work_punching_exception') if can_punch
          # if datetime > latest_start_punch && latest_end_punch > datetime.beginning_of_day  # 只给同一天的考勤增加异常状态
          #   # 过了上班时间合理区间之后，再判断是打卡异常了
          #   att.attend_states.find_or_create_by(auto_state: 'on_work_punching_exception')
          # end

          else
            # 最早的時間為上班時間
            swt = on_punching_card_records.sort.first
            true_swt = swt ? swt : att.on_work_time
            att.on_work_time = true_swt
            if true_swt > late_time
              att.attend_states.find_or_create_by(auto_state: 'late') if can_punch
            end
          end

          # 处理下班
          off_punching_card_records = user_logs.select { |log| log > earliest_end_punch && log <= latest_end_punch }
          if off_punching_card_records.count == 0 && att.off_work_time == nil
            # 下班时间区间内没有打卡记录，就不要记录时间了
            # att.off_work_time = user_logs.sort.last
            att.attend_states.find_or_create_by(auto_state: 'off_work_punching_exception') if can_punch
          # if datetime > latest_end_punch && latest_end_punch > datetime.beginning_of_day  # 只给同一天的考勤增加异常状态
          #   # 过了下班时间合理区间之后，再判断是打卡异常
          #   att.attend_states.find_or_create_by(auto_state: 'off_work_punching_exception')
          # end
          else
            # 应下班 - 最迟下班
            pcr = off_punching_card_records.select { |log| log >= plan_end_time && log <= latest_end_punch }

            # 最晚時間為下班時間
            ewt = pcr.count > 0 ? pcr.sort.last : off_punching_card_records.select { |log| log >= earliest_end_punch && log <= plan_end_time }.sort.last
            att_off_work_time = att.off_work_time
            true_ewt = ewt ? ewt : att_off_work_time
            att.off_work_time = true_ewt

            if  true_ewt < leave_early_time
              att.attend_states.find_or_create_by(auto_state: 'leave_early_by_auto') if can_punch
            end
          end

          att.save!

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

          if (att.on_work_time != nil || att.off_work_time != nil || has_sign_card_records) &&
             has_holiday_records &&
             !has_overtime_records

            att.attend_states.find_or_create_by(auto_state: 'punching_card_on_holiday_exception') if can_punch
          end

        elsif is_general_holiday == true || roster_object.holiday_type != nil
          sign_card_records = SignCardRecord
                                .where(user_id: att.user_id,
                                       source_id: nil,
                                       is_deleted: [false, nil])
                                .where(sign_card_date: att.attend_date)
          has_sign_card_records = sign_card_records.count > 0

          overtime_records = OvertimeRecord
                               .where(user_id: att.user_id,
                                      source_id: nil,
                                      is_deleted: [false, nil])
                               .where("overtime_start_date <= ? AND overtime_end_date >= ?", att.attend_date, att.attend_date)
          has_overtime_records = overtime_records.count > 0

          if user_logs
            logs_in_date = user_logs.select { |log| log >= (att.attend_date.beginning_of_day + 9.hour) && log <= att.attend_date.end_of_day }.sort
            att.on_work_time = logs_in_date.first
            att.off_work_time = logs_in_date.count > 1 ? logs_in_date.last : nil
            att.save!
          end

          if (att.on_work_time != nil || att.off_work_time != nil || has_sign_card_records) &&
             !has_overtime_records
            att.attend_states.find_or_create_by(auto_state: 'punching_card_on_holiday_exception') if can_punch
          end
        end
      end
    end
  end

  def self.update_attend_and_states(att)
    user_id = att.user_id
    date = att.attend_date
    roster_object = RosterObject.find_by(id: att.roster_object_id)

    user = User.find_by(id: user_id)
    can_punch = user && user.punch_card_state_of_date(roster_object.roster_date)

    if roster_object && user
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

  def compute_time(roster_date, class_setting)
    date_of_start_time = class_setting.is_next_of_start ? roster_date + 1.day : roster_date
    date_of_end_time = class_setting.is_next_of_end ? roster_date + 1.day : roster_date

    start_time = class_setting.start_time
    end_time = class_setting.end_time

    t_start = Time.zone.local(
      date_of_start_time.year,
      date_of_start_time.month,
      date_of_start_time.day,
      start_time.hour,
      start_time.min,
      59
    ).to_datetime

    t_end = Time.zone.local(
      date_of_end_time.year,
      date_of_end_time.month,
      date_of_end_time.day,
      end_time.hour,
      end_time.min,
      0
    ).to_datetime

    [t_start, t_end]
  end

  def transform_working_time(roster_date, working_time)
    tmp_start_time = working_time.split('-').first
    tmp_end_time = working_time.split('-').last

    tmp_start_hour = tmp_start_time[0, 2].to_i
    true_start_hour = tmp_start_hour % 24
    true_start_date = roster_date + (tmp_start_hour / 24).days

    true_start_min = tmp_start_time[3, 2].to_i

    tmp_end_hour = tmp_end_time[0, 2].to_i
    true_end_hour = tmp_end_hour % 24
    true_end_date = roster_date + (tmp_end_hour / 24).days

    true_end_min = tmp_end_time[3, 2].to_i

    plan_start_time = Time.zone.local(
      true_start_date.year,
      true_start_date.month,
      true_start_date.day,
      true_start_hour,
      true_start_min,
      59
    ).to_datetime

    plan_end_time = Time.zone.local(
      true_end_date.year,
      true_end_date.month,
      true_end_date.day,
      true_end_hour,
      true_end_min,
      0
    ).to_datetime

    [plan_start_time, plan_end_time]
  end

end
