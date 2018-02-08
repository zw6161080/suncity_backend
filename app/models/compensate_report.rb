# coding: utf-8
# == Schema Information
#
# Table name: compensate_reports
#
#  id                                     :integer          not null, primary key
#  department_id                          :integer
#  user_id                                :integer
#  year                                   :integer
#  month                                  :integer
#  year_month                             :integer
#  record_type                            :integer
#  force_holiday_counts                   :integer
#  force_holiday_for_leave_counts         :integer
#  force_holiday_for_money_counts         :integer
#  public_holiday_counts                  :integer
#  public_holiday_for_leave_counts        :integer
#  public_holiday_for_money_counts        :integer
#  working_day_counts                     :integer
#  general_holiday_counts                 :integer
#  late_mins                              :integer
#  late_counts                            :integer
#  late_mins_less_than_10                 :integer
#  late_mins_less_than_20                 :integer
#  late_mins_less_than_30                 :integer
#  late_mins_more_than_30                 :integer
#  late_mins_more_than_120                :integer
#  leave_early_mins                       :integer
#  leave_early_counts                     :integer
#  leave_early_mins_not_include_allowable :integer
#  sick_leave_counts_link_off             :integer
#  sick_leave_counts_not_link_off         :integer
#  annual_leave_counts                    :integer
#  birthday_leave_counts                  :integer
#  paid_bonus_leave_counts                :integer
#  compensatory_leave_counts              :integer
#  paid_sick_leave_counts                 :integer
#  unpaid_sick_leave_counts               :integer
#  unpaid_leave_counts                    :integer
#  paid_marriage_leave_counts             :integer
#  unpaid_marriage_leave_counts           :integer
#  paid_compassionate_leave_counts        :integer
#  unpaid_compassionate_leave_counts      :integer
#  maternity_leave_counts                 :integer
#  paid_maternity_leave_counts            :integer
#  unpaid_maternity_leave_counts          :integer
#  immediate_leave_counts                 :integer
#  absenteeism_counts                     :integer
#  work_injury_before_7_counts            :integer
#  work_injury_after_7_counts             :integer
#  unpaid_but_maintain_position_counts    :integer
#  overtime_leave_counts                  :integer
#  absenteeism_from_exception_counts      :integer
#  signcard_forget_to_punch_in_counts     :integer
#  signcard_forget_to_punch_out_counts    :integer
#  signcard_leave_early_counts            :integer
#  signcard_work_out_counts               :integer
#  signcard_others_counts                 :integer
#  signcard_typhoon_counts                :integer
#  weekdays_overtime_hours                :integer
#  general_holiday_overtime_hours         :integer
#  force_holiday_overtime_hours           :integer
#  public_holiday_overtime_hours          :integer
#  vehicle_department_overtime_mins       :integer
#  as_a_in_borrow_hours_counts            :integer
#  as_b_in_borrow_hours_counts            :integer
#  as_a_in_return_hours_counts            :integer
#  as_b_in_return_hours_counts            :integer
#  typhoon_allowance_counts               :integer
#  created_at                             :datetime         not null
#  updated_at                             :datetime         not null
#  pregnant_sick_leave_counts             :integer
#  pair_sort_key                          :string
#  real_working_hours                     :float
#
# Indexes
#
#  index_compensate_reports_on_department_id  (department_id)
#  index_compensate_reports_on_user_id        (user_id)
#

class CompensateReport < ApplicationRecord
  belongs_to :user
  belongs_to :department

  enum record_type: { original: 0, compensate: 1 }

  scope :by_company, lambda { |company|
    if company
      joins(:user).where(users: { company_name: company })
    end
  }

  scope :by_department_ids, lambda { |department_ids, start_d, end_d|
    # joins(:user).where(users: { department_id: department_ids })

    if department_ids && start_d && end_d
      int_department_ids = department_ids.map(& :to_i)
      u_ids = []
      start_ym = Time.zone.parse(start_d).to_datetime
      end_ym = Time.zone.parse(end_d).to_datetime
      start_end_month = (start_ym .. end_ym).map { |d| d.end_of_month }.compact.uniq
      all_users = User.all
      start_end_month.each do |d|
        all_users.each do |u|
          department = ProfileService.department(u, d)
          u_ids << u.id if (department && int_department_ids.include?(department.id))
        end
      end

      where(user_id: u_ids)
    end

  }

  scope :by_position_ids, lambda { |position_ids, start_d, end_d|
    # joins(:user).where(users: { position_id: position_ids }) if position_ids

    if position_ids && start_d && end_d
      int_position_ids = position_ids.map(& :to_i)
      u_ids = []
      start_ym = Time.zone.parse(start_d).to_datetime
      end_ym = Time.zone.parse(end_d).to_datetime
      start_end_month = (start_ym .. end_ym).map { |d| d.end_of_month }.compact.uniq
      all_users = User.all
      start_end_month.each do |d|
        all_users.each do |u|
          position= ProfileService.position(u, d)
          u_ids << u.id if (position && int_position_ids.include?(position.id))
        end
      end

      where(user_id: u_ids)
    end
  }

  scope :by_users, lambda { |user_ids|
    where(user_id: user_ids) if user_ids
  }

  scope :by_year_month, lambda { |start_time, end_time|
    if start_time && end_time
      # fmt: 2017/01
      # start_ym = start_time.split('/').join('').to_i
      # end_ym = end_time.split('/').join('').to_i
      # start_ym = Time.zone.parse(start_time).strftime('%Y%m').to_i
      # end_ym = Time.zone.parse(end_time).strftime('%Y%m').to_i
      # where(year_month: start_ym .. end_ym)

      start_y = Time.zone.parse(start_time).to_date.year
      start_m = Time.zone.parse(start_time).to_date.month
      end_y = Time.zone.parse(end_time).to_date.year
      end_m = Time.zone.parse(end_time).to_date.month

      if start_y < end_y
        where("(year = ? AND  month >= ?) OR (year > ? AND year < ?) OR (year = ? AND month <= ?)", start_y, start_m, start_y, end_y, end_y, end_m)
      elsif start_y == end_y
        where("year = ? AND  month >= ? AND month <= ?", start_y, start_m, end_m)
      end
    end
  }

  def self.generate_reports(year, month)
    ama = AttendMonthApproval.where(month: "#{year}/#{month.to_s.rjust(2, "0")}", status: 'approval').first
    older_amas = AttendMonthApproval.where("approval_time < ?", ama.approval_time)
    order_older_amas = older_amas.order(approval_time: :desc)
    last_ama = order_older_amas.first

    start_date = last_ama ? last_ama.approval_time : Time.zone.local(1970, 1, 1).to_datetime
    end_date = ama ? ama.approval_time : Time.zone.now.to_datetime

    # start_date = Time.zone.local(year, month, 1).to_date.beginning_of_month
    # end_date = Time.zone.local(year, month, 1).to_date.end_of_month + 1.day

    compensate_holiday_records = HolidayRecord.where(is_compensate: true, source_id: nil, is_deleted: [false, nil]).where("created_at >= ? AND created_at <= ?", start_date, end_date)
    compensate_sc_records = SignCardRecord.where(is_compensate: true, source_id: nil, is_deleted: [false, nil]).where("created_at >= ? AND created_at <= ?", start_date, end_date)
    compensate_overtime_records = OvertimeRecord.where(is_compensate: true, source_id: nil, is_deleted: [false, nil]).where("created_at >= ? AND created_at <= ?", start_date, end_date)
    compensate_wht_records = WorkingHoursTransactionRecord.where(is_compensate: true, source_id: nil, is_deleted: [false, nil]).where("created_at >= ? AND created_at <= ?", start_date, end_date)

    h_user_date_arr = compensate_holiday_records.pluck(:user_id, :start_date).uniq
    sc_user_date_arr = compensate_sc_records.pluck(:user_id, :sign_card_date).uniq
    o_user_date_arr = compensate_overtime_records.pluck(:user_id, :overtime_start_date).uniq
    wht_user_date_arr_as_a = compensate_wht_records.pluck(:user_a_id, :apply_date).uniq
    wht_user_date_arr_as_b = compensate_wht_records.pluck(:user_b_id, :apply_date).uniq

    tmp_all_user_date_arr = (h_user_date_arr + sc_user_date_arr + o_user_date_arr + wht_user_date_arr_as_a + wht_user_date_arr_as_b).select { |arr| arr.first != nil }.uniq
    all_user_date_arr = tmp_all_user_date_arr.map { |arr| [arr.first, arr.second.year, arr.second.month] }.uniq

    all_user_date_arr.each do |arr|
      user_id  = arr.first
      u = User.find_by(id: user_id)
      y = arr.second
      m = arr.third
      ['original', 'compensate'].each do |type|
        if type == 'original'
          latest_c_report =  CompensateReport
                               .where(user_id: u.id,
                                      record_type: 'compensate',
                                      year: y,
                                      month: m)
                               .where.not(year_month: "#{year}#{month.to_s.rjust(2, "0")}".to_i)
                               .order(created_at: :desc).first

          template_report = nil
          if latest_c_report
            template_report = latest_c_report
          else
            origin_m_report = AttendMonthlyReport.where(user_id: u.id,
                                                        year: y,
                                                        month: m,
                                                       ).first
            if origin_m_report
              template_report = origin_m_report
            end
          end

          if template_report
            report = CompensateReport.create(template_report.attributes.except("status").merge(
                                               {id: nil,
                                                user_id: u.id,
                                                department_id: u.department_id,
                                                year: y,
                                                record_type: type,
                                                month: m,
                                                year_month: "#{year}#{month.to_s.rjust(2, "0")}".to_i,
                                                pair_sort_key: "#{u.id}#{year}#{month}#{y}#{m}0"
                                               }
                                             ))
          end

        elsif type == 'compensate'
          if CompensateReport.where(user_id: u.id,
                                    year: y,
                                    month: m,
                                    record_type: 'original',
                                    year_month: "#{year}#{month.to_s.rjust(2, "0")}".to_i
                                   ).first != nil

            report = CompensateReport.where(user_id: u.id,
                                            year: y,
                                            month: m,
                                            record_type: 'compensate',
                                            year_month: "#{year}#{month.to_s.rjust(2, "0")}".to_i).first

            if report == nil
              report = CompensateReport.create(user_id: u.id,
                                               department_id: u.department_id,
                                               year: y,
                                               month: m,
                                               record_type: type,
                                               year_month: "#{year}#{month.to_s.rjust(2, "0")}".to_i,
                                               pair_sort_key: "#{u.id}#{year}#{month}#{y}#{m}1"
                                              )
            end


            report.set_holiday_counts('force_holiday') # force_holiday_counts
            report.set_holiday_counts('public_holiday') # public_holiday_counts
            report.set_public_holiday_for_leave_counts
            report.set_day_counts_for('working') # working_day_counts
            report.set_day_counts_for('general_holiday') # general_holiday_counts

            report.set_late_mins # late_mins
            report.set_late_counts # late_counts
            report.set_late_counts_between(0, 10)
            report.set_late_counts_between(10, 20)
            report.set_late_counts_between(20, 30)
            report.set_late_counts_between(30, 120)
            report.set_late_counts_between(120, 10080)
            report.set_leave_early_mins_for('include') # leave_early_mins
            report.set_leave_early_counts # leave_early_counts
            report.set_leave_early_mins_for('not_include') # leave_early_mins_not_include_allowable

            report.set_sick_leave_counts_link_off
            report.set_sick_leave_counts_not_link_off


            ['annual_leave', 'birthday_leave', 'paid_bonus_leave', 'compensatory_leave',
             'paid_sick_leave', 'unpaid_sick_leave', 'paid_marriage_leave', 'unpaid_marriage_leave',
             'paid_compassionate_leave', 'unpaid_compassionate_leave', 'maternity_leave', 'paid_maternity_leave',
             'unpaid_maternity_leave', 'immediate_leave', 'absenteeism', 'unpaid_but_maintain_position', 'pregnant_sick_leave'].each do |l_type|

              report.set_leave_counts_for(l_type)
            end

            report.set_leave_counts_for('unpaid_leave') # TODO

            report.set_work_injury_counts
            report.set_overtime_leave_counts

            report.set_absenteeism_from_exception_counts

            ['forget_to_punch_in', 'forget_to_punch_out', 'leave_early', 'work_out', 'others', 'typhoon'].each do |s_type|
              report.set_sign_card_counts_for(s_type)
            end

            ['weekdays', 'general_holiday', 'force_holiday', 'public_holiday'].each do |o_type|
              report.set_overtime_counts_for(o_type)
            end

            report.set_vehicle_department_overtime_mins
            report.set_working_hours_transaction_counts
            report.set_typhoon_allowance_counts
            report.set_real_working_hours

            report.save
          end
        end
      end
    end
  end

  # for force_holiday & public_holiday
  def set_holiday_counts(type)
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    all_holidays = HolidaySetting.where(category: type,
                                        holiday_date: start_date..end_date).pluck(:holiday_date)

    count = 0
    all_holidays.each do |d|
      att = Attend.find_by(user_id: u_id, attend_date: d)
      result = (att && att.roster_object_id != nil && (att.roster_object.class_setting_id != nil || att.roster_object.working_time != nil) && att.roster_object.is_general_holiday != true) rescue false
      if result
        count = count + 1
      end
    end

    if type == 'force_holiday'
      self.force_holiday_counts = count

      user = User.find_by(id: u_id)
      wr = user&.welfare_records.by_current_valid_record_for_welfare_info.first
      force_holiday_make_up = wr == nil || (wr&.id rescue -1) == -1 ?
                                nil :
                                ActiveModelSerializers::SerializableResource.new(
                                  wr
                                ).serializer_instance.force_holiday_make_up

      # wr = user.welfare_records.by_current_valid_record_for_welfare_info.first
      # force_holiday_make_up = wr == nil ?
      #                           nil :
      #                           ActiveModelSerializers::SerializableResource.new(
      #                             wr
      #                           ).serializer_instance.force_holiday_make_up

      # force_holiday_make_up = user.welfare_records.where(status: :being_valid).first.try(:force_holiday_make_up)
      if force_holiday_make_up == 'one_money_and_one_holiday'
        self.force_holiday_for_leave_counts = count * 1
        self.force_holiday_for_money_counts = count * 1
      elsif force_holiday_make_up == 'two_money'
        self.force_holiday_for_leave_counts = 0
        self.force_holiday_for_money_counts = count * 2
      elsif force_holiday_make_up == 'two_holiday'
        self.force_holiday_for_leave_counts = count * 2
        self.force_holiday_for_money_counts = 0
      end
    elsif type == 'public_holiday'
      self.public_holiday_counts = count
      self.public_holiday_for_money_counts = count
    end
    self.save
  end

  def set_public_holiday_for_leave_counts
    self.public_holiday_for_leave_counts = 0
    self.save
  end

  def set_day_counts_for(type)
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    roster_object_ids = Attend.where(user_id: u_id, attend_date: start_date..end_date).pluck(:roster_object_id)
    counts = 0
    if type == 'working'
      counts = RosterObject.where(id: roster_object_ids, is_general_holiday: [false, nil]).where.not(class_setting_id: nil).count
      self.working_day_counts = counts
    elsif type == 'general_holiday'
      counts = RosterObject.where(id: roster_object_ids, is_general_holiday: true).count
      self.general_holiday_counts = counts
    end
    self.save
  end

  def set_real_working_hours
    u_id, y = self.user_id, self.year
    start_date = Time.zone.local(y, 1, 1).to_date.beginning_of_year
    end_date = Time.zone.local(y, 1, 1).to_date.end_of_year

    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)
    total_hours = 0
    attends.each do |att|
      on_signcard_records = SignCardRecord.where(user_id: u_id,
                                                 source_id: nil,
                                                 is_get_to_work: true,
                                                 is_deleted: [false, nil],
                                                 sign_card_date: att&.attend_date)
      has_on_signcard = on_signcard_records.count > 0
      on_signcard = on_signcard_records&.first
      signcard_on_work_time = has_on_signcard ? on_signcard.sign_card_time.strftime("%H:%M") : nil
      signcard_on_work_time_is_next = has_on_signcard ? on_signcard.is_next : nil

      off_signcard_records = SignCardRecord.where(user_id: u_id,
                                                  source_id: nil,
                                                  is_get_to_work: false,
                                                  is_deleted: [false, nil],
                                                  sign_card_date: att&.attend_date)

      has_off_signcard = off_signcard_records.count > 0
      off_signcard = off_signcard_records&.first
      signcard_off_work_time = has_off_signcard ? off_signcard.sign_card_time.strftime("%H:%M") : nil
      signcard_off_work_time_is_next = has_off_signcard ? off_signcard.is_next : nil

      holiday_records = HolidayRecord
                          .where(user_id: u_id,
                                 source_id: nil,
                                 is_deleted: [false, nil])
                          .where("start_date <= ? AND end_date >= ?", att&.attend_date, att&.attend_date)

      roster_object = RosterObject.find_by(id: att&.roster_object_id)

      is_holiday_or_general_holiday = ((holiday_records.count > 0) || (roster_object && roster_object.is_general_holiday == true))

      real_work = AttendCalculateService.cal_real_work_time_and_hours(
        att,
        signcard_on_work_time,
        signcard_off_work_time,
        signcard_on_work_time_is_next,
        signcard_off_work_time_is_next,
        is_holiday_or_general_holiday
      )

      r_hours = real_work ? real_work[:real_work_hours] : 0
      total_hours = r_hours ? (total_hours + r_hours) : total_hours
    end

    self.real_working_hours = total_hours
    self.save
  end

  def set_late_mins
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)

    total_mins = 0
    attends.each do |att|
      if att.attend_states.where(auto_state: 'late').count > 0
        class_setting = att.try(:roster_object).try(:class_setting)
        should_start = nil

        if class_setting
          date_of_start_time = class_setting.is_next_of_start ? att.attend_date + 1.day : att.attend_date
          start_time = class_setting.start_time

          should_start = Time.zone.local(
            date_of_start_time.year,
            date_of_start_time.month,
            date_of_start_time.day,
            start_time.hour,
            start_time.min).to_datetime + class_setting.late_be_allowed.to_i.minutes
        end

        real_start = att.try(:on_work_time)
        if should_start && real_start
          mins = ((real_start - should_start) * 24 * 60).to_i / 24 / 60 / 60
          total_mins = total_mins + mins
        end
      end
    end

    self.late_mins = total_mins
    self.save
  end

  def set_late_counts
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)

    total_counts = 0
    attends.each do |att|
      if att.attend_states.where(auto_state: 'late').count > 0
        total_counts = total_counts + 1
      end
    end

    self.late_counts = total_counts
    self.save
  end

  def set_late_counts_between(small, big)
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)

    total_counts = 0
    attends.each do |att|
      if att.attend_states.where(auto_state: 'late').count > 0
        class_setting = att.try(:roster_object).try(:class_setting)
        should_start = nil

        if class_setting
          date_of_start_time = class_setting.is_next_of_start ? att.attend_date + 1.day : att.attend_date
          start_time = class_setting.start_time

          should_start = Time.zone.local(
            date_of_start_time.year,
            date_of_start_time.month,
            date_of_start_time.day,
            start_time.hour,
            start_time.min).to_datetime
        end

        real_start = att.try(:on_work_time)
        if should_start && real_start
          mins = ((real_start - should_start) * 24 * 60).to_i / 24 / 60 / 60
          if mins > small && mins <= big
            total_counts = total_counts + 1
          end
        end
      end
    end

    if small == 0 && big == 10
      self.late_mins_less_than_10 = total_counts
    elsif small == 10 && big == 20
      self.late_mins_less_than_20 = total_counts
    elsif small == 20 && big == 30
      self.late_mins_less_than_30 = total_counts
    elsif small == 30 && big == 120
      self.late_mins_more_than_30 = total_counts
    elsif small == 120 && big == 10080
      self.late_mins_more_than_120 = total_counts
    end

    self.save
  end

  def set_leave_early_mins
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)

    total_mins = 0
    attends.each do |att|
      auto_state_leave_early_counts = att.attend_states.where(auto_state: 'leave_early_by_auto').count
      leave_early_counts = att.attend_states.where(sign_card_state: 'leave_early').count
      if (auto_state_leave_early_counts + leave_early_counts) > 0
        class_setting = att.try(:roster_object).try(:class_setting)
        should_end = nil

        if class_setting
          date_of_end_time = class_setting.is_next_of_end ? att.attend_date + 1.day : att.attend_date
          end_time = class_setting.end_time

          should_end = Time.zone.local(
            date_of_end_time.year,
            date_of_end_time.month,
            date_of_end_time.day,
            end_time.hour,
            end_time.min).to_datetime
        end

        real_end = att.try(:off_work_time)
        if should_end && real_end
          mins = ((should_end.to_datetime - real_end.to_datetime) * 24 * 60).to_i
          total_mins = total_mins + mins
        end
      end
    end

    self.leave_early_mins = total_mins
    self.save
  end

  def set_leave_early_mins_for(type)
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)

    total_mins = 0
    attends.each do |att|
      auto_state_leave_early_counts = att.attend_states.where(auto_state: 'leave_early_by_auto').count
      leave_early_counts = att.attend_states.where(sign_card_state: 'leave_early').count
      if (auto_state_leave_early_counts + leave_early_counts) > 0
        class_setting = att.try(:roster_object).try(:class_setting)
        should_end = nil

        if class_setting
          date_of_end_time = class_setting.is_next_of_end ? att.attend_date + 1.day : att.attend_date
          end_time = class_setting.end_time

          tmp_should_end = Time.zone.local(
            date_of_end_time.year,
            date_of_end_time.month,
            date_of_end_time.day,
            end_time.hour,
            end_time.min).to_datetime

          should_end = type == 'include' ? tmp_should_end : tmp_should_end - class_setting.leave_be_allowed.minutes
        end

        real_end = att.try(:off_work_time)

        if should_end && real_end
          mins = ((should_end.to_datetime - real_end.to_datetime) * 24 * 60).to_i
          total_mins = total_mins + mins
        end
      end
    end

    if type == 'include'
      self.leave_early_mins = total_mins
    elsif type == 'not_include'
      self.leave_early_mins_not_include_allowable = total_mins
    end

    self.save
  end

  def set_leave_early_counts
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)

    total_counts = 0
    attends.each do |att|
      auto_state_leave_early_counts = att.attend_states.where(auto_state: 'leave_early_by_auto').count
      # leave_early_counts = att.attend_states.where(sign_card_state: 'leave_early').count
      if auto_state_leave_early_counts > 0
        total_counts = total_counts + 1
      end
    end

    self.leave_early_counts = total_counts
    self.save
  end

  def set_sick_leave_counts_link_off
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)

    total_counts = 0
    attends.each do |att|
      if att.attend_states.where(state: 'paid_sick_leave').count > 0
        if is_link_off_before?(att, start_date) || is_link_off_after?(att, end_date)
          total_counts = total_counts + 1
        end
      end
    end

    self.sick_leave_counts_link_off = total_counts
    self.save
  end

  def set_sick_leave_counts_not_link_off
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)

    total_counts = 0
    attends.each do |att|
      if att.attend_states.where(state: 'paid_sick_leave').count > 0
        if !is_link_off_before?(att, start_date) && !is_link_off_after?(att, end_date)
          total_counts = total_counts + 1
        end
      end
    end

    self.sick_leave_counts_not_link_off = total_counts
    self.save
  end

  def is_link_off_before?(paid_sick_leave_attend, start_date)
    user_id = paid_sick_leave_attend.user_id

    day = paid_sick_leave_attend.attend_date - 1.days
    now_attend = Attend.where(user_id: user_id, attend_date: day).first

    while now_attend.try(:roster_object).try(:is_general_holiday) != true && day >= start_date
      if now_attend == nil || now_attend.attend_states.where(state: 'paid_sick_leave').count <= 0 # 不再是有薪病假
        return false
      end

      day = now_attend.attend_date - 1.days
      now_attend = Attend.where(user_id: user_id, attend_date: day).first
    end
    return true
  end

  def is_link_off_after?(paid_sick_leave_attend, end_date)
    user_id = paid_sick_leave_attend.user_id

    day = paid_sick_leave_attend.attend_date + 1.days
    now_attend = Attend.where(user_id: user_id, attend_date: day).first

    while now_attend.try(:roster_object).try(:is_general_holiday) != true && day <= end_date
      if now_attend == nil || now_attend.attend_states.where(state: 'paid_sick_leave').count <= 0 # 不再是有薪病假
        return false
      end

      day = now_attend.attend_date + 1.days
      now_attend = Attend.where(user_id: user_id, attend_date: day).first
    end
    return true
  end

  def set_leave_counts_for(type)
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    left_outer_records = HolidayRecord.where(holiday_type: type, source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date < ? AND end_date >= ? AND end_date <= ?", u_id, start_date, start_date, end_date)
    right_outer_records = HolidayRecord.where(holiday_type: type, source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date >= ? AND start_date <= ? AND end_date > ?", u_id, start_date, end_date, end_date)
    inside_records = HolidayRecord.where(holiday_type: type, source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date >= ? AND end_date <= ?", u_id, start_date, end_date)
    outer_records = HolidayRecord.where(holiday_type: type, source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date < ? AND end_date > ?", u_id, start_date, end_date)

    total_counts = 0

    left_outer_records.each do |r|
      total_counts = total_counts + (r.end_date - start_date).to_i + 1
    end

    right_outer_records.each do |r|
      total_counts = total_counts + (end_date - r.start_date).to_i + 1
    end

    inside_records.each do |r|
      total_counts = total_counts + r.days_count.to_i
    end

    outer_records.each do |r|
      total_counts = total_counts + (end_date - start_date).to_i + 1
    end

    if type == 'unpaid_leave'
      total_counts += WorkingHoursTransactionRecord.to_unpaid_leave_counts(u_id, nil, start_date, end_date, true)
    end

    me = "#{type}_counts=".to_sym
    self.send(me, total_counts)
    self.save
  end

  def set_work_injury_counts
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    left_outer_records = HolidayRecord.where(holiday_type: 'work_injury', source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date < ? AND end_date >= ? AND end_date <= ?", u_id, start_date, start_date, end_date)
    right_outer_records = HolidayRecord.where(holiday_type: 'work_injury', source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date >= ? AND start_date <= ? AND end_date > ?", u_id, start_date, end_date, end_date)
    inside_records = HolidayRecord.where(holiday_type: 'work_injury', source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date >= ? AND end_date <= ?", u_id, start_date, end_date)
    outer_records = HolidayRecord.where(holiday_type: 'work_injury', source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date < ? AND end_date > ?", u_id, start_date, end_date)

    before_total_counts = 0
    after_total_counts = 0

    left_outer_records.each do |r|
      after_7 = r.start_date + 6.day

      should_add_before = (after_7 < start_date) ? 0 : (after_7 - start_date).to_i + 1
      before_total_counts = before_total_counts + should_add_before

      should_add_after = (after_7 < start_date) ? (r.end_date - start_date).to_i + 1 : (r.end_date - after_7).to_i
      after_total_counts = after_total_counts + should_add_after
    end

    right_outer_records.each do |r|
      after_7 = r.start_date + 6.day
      should_add_before = (after_7 > end_date) ? (end_date - r.start_date).to_i + 1 : 7
      before_total_counts = before_total_counts + should_add_before

      should_add_after = (after_7 > end_date) ? 0 : (r.end_date - after_7).to_i
      after_total_counts = after_total_counts + should_add_after
    end

    inside_records.each do |r|
      should_add_before = r.days_count < 7 ? r.days_count : 7
      before_total_counts = before_total_counts + should_add_before

      should_add_after = r.days_count > 7 ? r.days_count - 7 : 0
      after_total_counts = after_total_counts + should_add_after
    end

    outer_records.each do |r|
      after_7 = r.start_date + 6.day

      should_add_before = (after_7 < start_date) ? 0 : (after_7 - start_date).to_i + 1
      before_total_counts = before_total_counts + should_add_before

      should_add_after = (after_7 < start_date) ? (end_date - start_date).to_i + 1 : (r.end_date - after_7).to_i
      after_total_counts = after_total_counts + should_add_after
    end

    self.work_injury_before_7_counts = before_total_counts <= 30 ? before_total_counts : 30
    self.work_injury_after_7_counts = after_total_counts <= 30 ? after_total_counts : 30
    self.save
  end

  def set_overtime_leave_counts
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    records = HolidayRecord.where(user_id: u_id, source_id: nil, holiday_type: 'overtime_leave', start_date: start_date..end_date, end_date: start_date..end_date, is_deleted: [false, nil])
    total_counts = records.all.inject(0) do |sum, r|
      sum = r.hours_count ? sum + r.hours_count : sum
    end

    self.overtime_leave_counts = total_counts
    self.save
  end

  def set_absenteeism_from_exception_counts
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)

    total_counts = 0
    attends.each do |att|
      hr = HolidayRecord.where(user_id: att.user_id, source_id: nil, is_deleted: [false, nil])
             .where("start_date <= ? AND end_date >= ?", att.attend_date, att.attend_date)

      on_signcard_records = SignCardRecord.where(user_id: att.user.try(:id),
                                                 source_id: nil,
                                                 is_get_to_work: true,
                                                 is_deleted: [false, nil],
                                                 sign_card_date: att.attend_date)
      has_on_signcard = on_signcard_records.count > 0

      on_count = (has_on_signcard || hr.count > 0) ? 0 : att.attend_states.where(auto_state: 'on_work_punching_exception').count

      off_signcard_records = SignCardRecord.where(user_id: att.user.try(:id),
                                                  source_id: nil,
                                                  is_get_to_work: false,
                                                  is_deleted: [false, nil],
                                                  sign_card_date: att.attend_date)

      has_off_signcard = off_signcard_records.count > 0

      off_count = (has_off_signcard || hr.count > 0) ? 0 : att.attend_states.where(auto_state: 'off_work_punching_exception').count

      if (on_count + off_count) > 0
        total_counts += 1
      end
    end

    self.absenteeism_from_exception_counts = total_counts
    self.save
  end

  def set_sign_card_counts_for(type)
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    # records = SignCardRecord.where(user_id: u_id, sign_card_date: start_date..end_date)
    # records.each do |r|
    #   sign_card_setting = r.sign_card_setting_id ? SignCardSetting.find(r.sign_card_setting_id) : nil
    #   if sign_card_setting
    #   end
    # end

    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)

    total_counts = 0
    attends.each do |att|
      if att.attend_states.where(sign_card_state: type).count > 0
        total_counts += 1
      end
    end

    me = "signcard_#{type}_counts=".to_sym
    self.send(me, total_counts)
    self.save
  end

  def set_overtime_counts_for(type)
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    records = OvertimeRecord.where(user_id: u_id,
                                   source_id: nil,
                                   is_deleted: [false, nil],
                                   overtime_type: type,
                                   compensate_type: 'money',
                                   overtime_start_date: start_date..end_date,
                                   overtime_end_date: start_date..end_date
                                  )

    total_hours = records.inject(0) do |sum, r|
      sum += r.overtime_hours.to_i
    end

    if type == 'weekdays'
      total_hours += WorkingHoursTransactionRecord.to_overtime_counts(u_id, nil, start_date, end_date, true)
    end

    me = "#{type}_overtime_hours=".to_sym
    self.send(me, total_hours)
    self.save
  end

  def set_vehicle_department_overtime_mins
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    records = OvertimeRecord.where(user_id: u_id,
                                   source_id: nil,
                                   is_deleted: [false, nil],
                                   overtime_type: 'vehicle_department',
                                   compensate_type: 'money',
                                   overtime_start_date: start_date..end_date,
                                   overtime_end_date: start_date..end_date
                                  )
    total_mins = records.inject(0) do |sum, r|
      sum += r.vehicle_department_over_time_min.to_i
    end

    self.vehicle_department_overtime_mins = total_mins
    self.save
  end

  def set_working_hours_transaction_counts
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    in_date_records = WorkingHoursTransactionRecord.where(apply_date: start_date..end_date, source_id: nil, is_deleted: [false, nil])

    # as_a_in_borrow = in_date_records.where(user_a_id: u_id, apply_type: 'borrow_hours').count
    # as_b_in_borrow = in_date_records.where(user_b_id: u_id, apply_type: 'borrow_hours').count

    tmp_as_a_in_borrow = in_date_records.where(user_a_id: u_id, apply_type: 'borrow_hours')
    tmp_as_b_in_borrow = in_date_records.where(user_b_id: u_id, apply_type: 'borrow_hours')

    as_a_in_borrow = tmp_as_a_in_borrow.reduce(0) do |sum, wht|
      return_wht = WorkingHoursTransactionRecord.where(borrow_id: wht.id, is_deleted: [nil, false])&.first
      after_10_days = wht.apply_date + 10.day
      should_not_add = (return_wht && return_wht.apply_date >= after_10_days) || (!return_wht && after_10_days <= end_date)
      sum = should_not_add ? sum : sum + 1
      sum
    end

    as_b_in_borrow = tmp_as_b_in_borrow.reduce(0) do |sum, wht|
      return_wht = WorkingHoursTransactionRecord.where(borrow_id: wht.id, is_deleted: [nil, false])&.first
      after_x_days = wht.user_a_id == nil ? wht.apply_date + 30.day : wht.apply_date + 10.day
      # should_not_add = (return_wht && return_wht.apply_date > after_x_days) || (wht.can_be_return == true && after_x_days < end_date)
      # sum = should_not_add ? sum : sum + 1
      should_add = return_wht || (!return_wht && after_x_days > end_date)
      sum = should_add ? sum + 1 : sum
      sum
    end

    as_a_in_return = in_date_records.where(user_a_id: u_id, apply_type: 'return_hours').count
    as_b_in_return = in_date_records.where(user_b_id: u_id, apply_type: 'return_hours').count

    self.as_a_in_borrow_hours_counts = as_a_in_borrow
    self.as_b_in_borrow_hours_counts = as_b_in_borrow
    self.as_a_in_return_hours_counts = as_a_in_return
    self.as_b_in_return_hours_counts = as_b_in_return
    self.save
  end

  def set_typhoon_allowance_counts
    u_id, y, m = self.user_id, self.year, self.month
    start_date = Time.zone.local(y, m, 1).to_date.beginning_of_month
    end_date = Time.zone.local(y, m, 1).to_date.end_of_month

    total_counts = TyphoonQualifiedRecord.where(user_id: u_id, qualify_date: start_date..end_date, is_apply: true).count

    self.typhoon_allowance_counts = total_counts
    self.save
  end

  def self.delete_reports(year, month)
    ym = "#{year}#{month.to_s.rjust(2, "0")}".to_i
    CompensateReport.where(year_month: ym).each do |report|
      report.destroy
    end
  end

  def self.delete_reports_with_y_and_m(year, month)
    CompensateReport.where(year: year, month: month).each do |report|
      report.destroy
    end
  end

  def self.update_reports(record)
    new_amas = AttendMonthApproval.where(status: 'approval').where("approval_time >= ?", record.created_at.to_datetime)

    order_new_amas = new_amas&.order(approval_time: :desc)
    last_ama = order_new_amas&.last

    if last_ama
      year = last_ama.month.split("/").first.to_i
      month = last_ama.month.split("/").second.to_i
      CompensateReport.delete_reports(year, month)
      CalcCompensateReportJob.perform_later(year, month)
    end
  end

  def self.update_reports_after_cancel_approval(ama)
    if ama
      year = ama.month.split("/").first.to_i
      month = ama.month.split("/").second.to_i
      CompensateReport.delete_reports(year, month)
      CompensateReport.delete_reports_with_y_and_m(year, month)
    end
  end
end
