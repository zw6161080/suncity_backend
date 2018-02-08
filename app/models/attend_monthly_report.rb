# coding: utf-8
# == Schema Information
#
# Table name: attend_monthly_reports
#
#  id                                     :integer          not null, primary key
#  department_id                          :integer
#  user_id                                :integer
#  year                                   :integer
#  month                                  :integer
#  year_month                             :integer
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
#  status                                 :integer
#  real_working_hours                     :float
#
# Indexes
#
#  index_attend_monthly_reports_on_department_id  (department_id)
#  index_attend_monthly_reports_on_user_id        (user_id)
#

class AttendMonthlyReport < ApplicationRecord
  belongs_to :user
  belongs_to :department
  enum status: { not_calc: 0, calculating: 1, calculated: 2 }

  scope :by_company, lambda { |company|
    if company
      joins(:user).where(users: { company_name: company })
    end
  }

  scope :by_department_ids, lambda { |department_ids, start_d, end_d|
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
      start_ym = Time.zone.parse(start_time).strftime('%Y%m').to_i
      end_ym = Time.zone.parse(end_time).strftime('%Y%m').to_i
      where(year_month: start_ym .. end_ym)
    end
  }

  def self.generate_reports(year, month)
    User.all.each do |u|
      r = AttendMonthlyReport.where(user_id: u.id, year: year, month: month).first
      if r
        r.refresh_data(year, month)
      else
        report = AttendMonthlyReport.create(user_id: u.id,
                                            department_id: u.department_id,
                                            year: year,
                                            month: month,
                                            year_month: "#{year}#{month.to_s.rjust(2, "0")}".to_i
                                           )

        report.set_data(year, month)
        report.save!
      end
    end
  end

  def refresh_data(year, month)
    self.set_data(year, month)
    self.save!
  end

  def set_data(year, month)
    report = self
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
     'unpaid_maternity_leave', 'immediate_leave', 'absenteeism', 'unpaid_but_maintain_position', 'pregnant_sick_leave'].each do |type|

      report.set_leave_counts_for(type)
    end

    report.set_leave_counts_for('unpaid_leave') # TODO

    report.set_work_injury_counts
    report.set_overtime_leave_counts

    report.set_absenteeism_from_exception_counts

    ['forget_to_punch_in', 'forget_to_punch_out', 'leave_early', 'work_out', 'others', 'typhoon'].each do |type|
      report.set_sign_card_counts_for(type)
    end

    ['weekdays', 'general_holiday', 'force_holiday', 'public_holiday'].each do |type|
      report.set_overtime_counts_for(type)
    end

    report.set_vehicle_department_overtime_mins
    report.set_working_hours_transaction_counts
    report.set_typhoon_allowance_counts
    report.set_real_working_hours

    report.status = 'calculated'
    report.save
  end

  # for force_holiday & public_holiday
  def set_holiday_counts(type, start_date = nil, end_date = nil)
    self.save_data(self.class.get_holiday_counts(type, self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_holiday_counts(type, user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
    all_holidays = HolidaySetting.where(category: 'force_holiday',
                                        holiday_date: start_date..end_date).pluck(:holiday_date)
    if type == 'force_holiday'
      count = []
      all_holidays.each do |d|
        att = Attend.find_by(user_id: u_id, attend_date: d)
        result = (att && att.roster_object_id != nil && (att.roster_object.class_setting_id != nil || att.roster_object.working_time != nil) && att.roster_object.is_general_holiday != true) rescue false
        if result
          count.push({attend_date: d})
        end
      end
      force_holiday_counts = count.count
      user = User.find_by(id: u_id)

      force_holiday_for_leave_counts = 0
      force_holiday_for_money_counts = 0
      count.each do |hash|
        wr = user&.welfare_records.by_current_valid_record_for_welfare_info.first
        force_holiday_make_up = wr == nil || (wr&.id rescue -1) == -1 ?
                                  nil :
                                  ActiveModelSerializers::SerializableResource.new(
                                    wr
                                  ).serializer_instance.force_holiday_make_up

        # wr = user.welfare_records
        #        .where('welfare_begin <= :attend_date AND (welfare_end < :attend_date OR welfare_end IS NOT NULL)', attend_date: hash[:attend_date].to_datetime)
        #        .order(welfare_begin: :desc).first
        # force_holiday_make_up = wr == nil ?
        #                           nil :
        #                           ActiveModelSerializers::SerializableResource.new(
        #                             wr
        #                           ).serializer_instance.force_holiday_make_up

        if force_holiday_make_up == 'one_money_and_one_holiday'
          force_holiday_for_leave_counts += 1 * 1
          force_holiday_for_money_counts += 1 * 1
        elsif force_holiday_make_up == 'two_money'
          force_holiday_for_leave_counts += 0
          force_holiday_for_money_counts += 1 * 2
        elsif force_holiday_make_up == 'two_holiday'
          force_holiday_for_leave_counts += 1 * 2
          force_holiday_for_money_counts += 0
        end
      end


      {
        force_holiday_counts: force_holiday_counts,
        force_holiday_for_leave_counts: force_holiday_for_leave_counts,
        force_holiday_for_money_counts: force_holiday_for_money_counts
      }
    elsif type == 'public_holiday'
      all_holidays = HolidaySetting.where(category: 'public_holiday',
                                          holiday_date: start_date..end_date).pluck(:holiday_date)
      count = 0
      all_holidays.each do |d|
        att = Attend.find_by(user_id: u_id, attend_date: d)
        result = (att && att.roster_object_id != nil && (att.roster_object.class_setting_id != nil || att.roster_object.working_time != nil) && att.roster_object.is_general_holiday != true) rescue false
        if result
          count = count + 1
        end
      end
      public_holiday_counts = count
      public_holiday_for_money_counts = count
      {
        public_holiday_counts: public_holiday_counts,
        public_holiday_for_money_counts: public_holiday_for_money_counts
      }
    end
  end

  def set_public_holiday_for_leave_counts
    self.save_data(self.class.get_public_holiday_for_leave_counts)
  end

  def self.get_public_holiday_for_leave_counts(start_date = nil, end_date = nil)
    {
      public_holiday_for_leave_counts: 0
    }
  end

  def set_day_counts_for(type, start_date = nil, end_date = nil)
    self.save_data(self.class.get_day_counts_for(type, self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_day_counts_for(type, user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
    roster_object_ids = Attend.where(user_id: u_id, attend_date: start_date..end_date).pluck(:roster_object_id)
    working_day_counts = RosterObject.where(id: roster_object_ids, is_general_holiday: [false, nil], holiday_type: nil).where("class_setting_id != ? OR working_time != ?", nil, nil).count
    general_holiday_counts = RosterObject.where(id: roster_object_ids, is_general_holiday: true, holiday_type: nil).count
    if type == 'working'
      {working_day_counts:  working_day_counts}
    elsif type == 'general_holiday'
      {general_holiday_counts: general_holiday_counts}
    end
  end

  def set_real_working_hours(start_date = nil, end_date = nil)
    self.save_data(self.class.get_real_working_hours(self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_real_working_hours(user_id, year, month, start_date = nil, end_date = nil)
    u_id, y, m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)
    total_hours = 0

    attends.each do |att|
      on_signcard_records = SignCardRecord.where(user_id: u_id,
                                                 source_id: nil,
                                                 is_get_to_work: true,
                                                 is_deleted: [false, nil],
                                                 sign_card_date: att&.attend_date,
                                                 is_compensate: false)
      has_on_signcard = on_signcard_records.count > 0
      on_signcard = on_signcard_records&.first
      signcard_on_work_time = has_on_signcard ? on_signcard.sign_card_time.strftime("%H:%M") : nil
      signcard_on_work_time_is_next = has_on_signcard ? on_signcard.is_next : nil

      off_signcard_records = SignCardRecord.where(user_id: u_id,
                                                  source_id: nil,
                                                  is_get_to_work: false,
                                                  is_deleted: [false, nil],
                                                  sign_card_date: att&.attend_date,
                                                  is_compensate: false)

      has_off_signcard = off_signcard_records.count > 0
      off_signcard = off_signcard_records&.first
      signcard_off_work_time = has_off_signcard ? off_signcard.sign_card_time.strftime("%H:%M") : nil
      signcard_off_work_time_is_next = has_off_signcard ? off_signcard.is_next : nil

      holiday_records = HolidayRecord
                          .where(user_id: u_id,
                                 source_id: nil,
                                 is_deleted: [false, nil],
                                 is_compensate: false)
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

    {
      real_working_hours: total_hours
    }
  end

  def set_late_mins(start_date = nil, end_date = nil)
    self.save_data(self.class.get_late_mins(self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_late_mins(user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
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

        if should_start != nil && real_start != nil
          # mins = ((real_start - should_start) * 24 * 60).to_i
          # mins = ((real_start - should_start) / 60).to_i
          mins = ((real_start - should_start) * 24 * 60).to_i / 24 / 60 / 60
          total_mins = total_mins + mins
        end
      end
    end
    late_mins = total_mins
    {
      late_mins: late_mins
    }
  end

  def set_late_counts(start_date = nil, end_date = nil)
    self.save_data(self.class.get_late_counts(self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_late_counts(user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)
    total_counts = 0
    attends.each do |att|
      if att.attend_states.where(auto_state: 'late').count > 0
        total_counts = total_counts + 1
      end
    end
    late_counts = total_counts
    {
      late_counts: late_counts
    }
  end

  def set_late_counts_between(small, big, start_date = nil, end_date = nil)
    self.save_data(self.class.get_late_counts_between(small, big, self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_late_counts_between(small, big, user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
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
        if should_start != nil && real_start != nil
          mins = ((real_start - should_start) * 24 * 60).to_i / 24 / 60 / 60
          if mins > small && mins <= big
            total_counts = total_counts + 1
          end
        end
      end
    end

    if small == 0 && big == 10
      late_mins_less_than_10 = total_counts
      {
        late_mins_less_than_10: late_mins_less_than_10
      }
    elsif small == 10 && big == 20
      late_mins_less_than_20 = total_counts
      {
        late_mins_less_than_20: late_mins_less_than_20
      }
    elsif small == 20 && big == 30
      late_mins_less_than_30 = total_counts
      {
        late_mins_less_than_30: late_mins_less_than_30
      }
    elsif small == 30 && big == 120
      late_mins_more_than_30 = total_counts
      {
        late_mins_more_than_30: late_mins_more_than_30
      }
    elsif small == 120 && big == 10080
      late_mins_more_than_120 = total_counts
      {
        late_mins_more_than_120: late_mins_more_than_120
      }
    end
  end

  def set_leave_early_mins(start_date = nil, end_date = nil)
    self.save_data(self.class.get_leave_early_mins( self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_leave_early_mins(user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
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

        if should_end != nil && real_end != nil
          mins = ((should_end.to_datetime - real_end.to_datetime) * 24 * 60).to_i
          # mins = 0
          total_mins = total_mins + mins
        end
      end
    end
    leave_early_mins = total_mins
    {
      leave_early_mins: leave_early_mins
    }
  end


  def set_leave_early_mins_for(type, start_date = nil, end_date = nil)
    self.save_data(self.class.get_leave_early_mins_for(type, self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_leave_early_mins_for(type, user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
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

          should_end = type == 'include' ? tmp_should_end : (tmp_should_end - class_setting.leave_be_allowed.minutes).in_time_zone.to_datetime
        end

        real_end = att.try(:off_work_time)
        if should_end != nil && real_end != nil
          mins = ((should_end.to_datetime - real_end.to_datetime) * 24 * 60).to_i
          # mins = 233
          total_mins = total_mins + mins
        end
      end
    end

    if type == 'include'
      leave_early_mins = total_mins
      {
        leave_early_mins: leave_early_mins
      }
    elsif type == 'not_include'
      leave_early_mins_not_include_allowable = total_mins
      {
        leave_early_mins_not_include_allowable: leave_early_mins_not_include_allowable
      }
    end

  end

  def set_leave_early_counts(start_date = nil, end_date = nil)
    self.save_data(self.class.get_leave_early_counts( self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_leave_early_counts(user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)

    total_counts = 0
    attends.each do |att|
      auto_state_leave_early_counts = att.attend_states.where(auto_state: 'leave_early_by_auto').count
      # leave_early_counts = att.attend_states.where(sign_card_state: 'leave_early').count
      if auto_state_leave_early_counts > 0
        total_counts = total_counts + 1
      end
    end
    leave_early_counts = total_counts
    {
      leave_early_counts: leave_early_counts
    }
  end

  def set_sick_leave_counts_link_off(start_date = nil, end_date = nil)
    self.save_data(self.class.get_sick_leave_counts_link_off( self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_sick_leave_counts_link_off(user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)

    total_counts = 0
    attends.each do |att|
      if att.attend_states.where(state: 'paid_sick_leave').count > 0
        if is_link_off_before?(att, start_date) || is_link_off_after?(att, end_date)
          total_counts = total_counts + 1
        end
      end
    end

    sick_leave_counts_link_off = total_counts
    {
      sick_leave_counts_link_off: sick_leave_counts_link_off
    }
  end

  def set_sick_leave_counts_not_link_off(start_date = nil, end_date = nil)
    self.save_data(self.class.get_sick_leave_counts_not_link_off( self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_sick_leave_counts_not_link_off(user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)

    total_counts = 0
    attends.each do |att|
      if att.attend_states.where(state: 'paid_sick_leave').count > 0
        if !is_link_off_before?(att, start_date) && !is_link_off_after?(att, end_date)
          total_counts = total_counts + 1
        end
      end
    end

    sick_leave_counts_not_link_off = total_counts
    {
      sick_leave_counts_not_link_off: sick_leave_counts_not_link_off
    }
  end

  def self.is_link_off_before?(paid_sick_leave_attend, start_date)
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

  def self.is_link_off_after?(paid_sick_leave_attend, end_date)
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

  def set_leave_counts_for(type, start_date = nil, end_date = nil)
    self.save_data(self.class.get_leave_counts_for(type, self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_leave_counts_for(type, user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
    left_outer_records = HolidayRecord.where(holiday_type: type, source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date < ? AND end_date >= ? AND end_date <= ? AND is_compensate = ?", u_id, start_date, start_date, end_date, false)
    right_outer_records = HolidayRecord.where(holiday_type: type, source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date >= ? AND start_date <= ? AND end_date > ? AND is_compensate = ?", u_id, start_date, end_date, end_date, false)
    inside_records = HolidayRecord.where(holiday_type: type, source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date >= ? AND end_date <= ? AND is_compensate = ?", u_id, start_date, end_date, false)
    outer_records = HolidayRecord.where(holiday_type: type, source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date < ? AND end_date > ? AND is_compensate = ?", u_id, start_date, end_date, false)

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
      total_counts += WorkingHoursTransactionRecord.to_unpaid_leave_counts(u_id, nil, start_date, end_date, false)
    end

    me = "#{type}_counts".to_sym
    {
      me => total_counts
    }
  end

  def set_work_injury_counts(start_date = nil, end_date = nil)
    self.save_data(self.class.get_work_injury_counts( self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_work_injury_counts(user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
    left_outer_records = HolidayRecord.where(holiday_type: 'work_injury', source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date < ? AND end_date >= ? AND end_date <= ? AND is_compensate = ?", u_id, start_date, start_date, end_date, false)
    right_outer_records = HolidayRecord.where(holiday_type: 'work_injury', source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date >= ? AND start_date <= ? AND end_date > ? AND is_compensate = ?", u_id, start_date, end_date, end_date, false)
    inside_records = HolidayRecord.where(holiday_type: 'work_injury', source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date >= ? AND end_date <= ? AND is_compensate = ?", u_id, start_date, end_date, false)
    outer_records = HolidayRecord.where(holiday_type: 'work_injury', source_id: nil, is_deleted: [false, nil]).where("user_id = ? AND start_date < ? AND end_date > ? AND is_compensate = ?", u_id, start_date, end_date, false)

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

    work_injury_before_7_counts = before_total_counts <= 30 ? before_total_counts : 30
    work_injury_after_7_counts = after_total_counts <= 30 ? after_total_counts : 30
    {
      work_injury_before_7_counts: work_injury_before_7_counts,
      work_injury_after_7_counts: work_injury_after_7_counts
    }
  end

  def set_overtime_leave_counts(start_date = nil, end_date = nil)
    self.save_data(self.class.get_overtime_leave_counts( self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_overtime_leave_counts (user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
    records = HolidayRecord.where(user_id: u_id,
                                  source_id: nil,
                                  is_deleted: [false, nil],
                                  holiday_type: 'overtime_leave',
                                  start_date: start_date..end_date,
                                  end_date: start_date..end_date,
                                  is_compensate: false,
                                 )
    total_counts = records.all.inject(0) do |sum, r|
      sum = r.hours_count ? sum + r.hours_count : sum
    end
    overtime_leave_counts = total_counts
    {
      overtime_leave_counts: overtime_leave_counts
    }
  end

  def set_absenteeism_from_exception_counts(start_date = nil, end_date = nil)
    self.save_data(self.class.get_absenteeism_from_exception_counts( self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_absenteeism_from_exception_counts(user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
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
    absenteeism_from_exception_counts = total_counts
    {
      absenteeism_from_exception_counts: absenteeism_from_exception_counts
    }
  end

  def set_sign_card_counts_for(type, start_date = nil, end_date = nil)
    self.save_data(self.class.get_sign_card_counts_for(type, self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_sign_card_counts_for(type, user_id, year, month, start_date = nil, end_date = nil )
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
    attends = Attend.where(user_id: u_id, attend_date: start_date..end_date)

    total_counts = 0
    attends.each do |att|
      if att.attend_states.where(sign_card_state: type).count > 0
        total_counts += 1
      end
    end

    me = "signcard_#{type}_counts".to_sym
    {
      me => total_counts
    }

  end

  def set_overtime_counts_for(type, start_date = nil, end_date = nil)
    self.save_data(self.class.get_overtime_counts_for(type, self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_overtime_counts_for(type, user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
    records = OvertimeRecord.where(user_id: u_id,
                                   source_id: nil,
                                   is_deleted: [false, nil],
                                   overtime_type: type,
                                   compensate_type: 'money',
                                   overtime_start_date: start_date..end_date,
                                   overtime_end_date: start_date..end_date,
                                   is_compensate: false,
                                  )

    total_hours = records.inject(0) do |sum, r|
      sum += r.overtime_hours.to_i
    end

    if type == 'weekdays'
      total_hours += WorkingHoursTransactionRecord.to_overtime_counts(u_id, nil, start_date, end_date, false)
    end

    me = "#{type}_overtime_hours".to_sym
    {
      me => total_hours
    }
  end

  def set_vehicle_department_overtime_mins(start_date = nil, end_date = nil)
    self.save_data(self.class.get_vehicle_department_overtime_mins( self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_vehicle_department_overtime_mins( user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
    records = OvertimeRecord.where(user_id: u_id,
                                   source_id: nil,
                                   is_deleted: [false, nil],
                                   overtime_type: 'vehicle_department',
                                   compensate_type: 'money',
                                   overtime_start_date: start_date..end_date,
                                   overtime_end_date: start_date..end_date,
                                   is_compensate: false,
                                  )
    total_mins = records.inject(0) do |sum, r|
      sum += r.vehicle_department_over_time_min.to_i
    end

    {vehicle_department_overtime_mins: total_mins}
  end

  def set_working_hours_transaction_counts(start_date = nil, end_date = nil)
    self.save_data(self.class.get_working_hours_transaction_counts( self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_working_hours_transaction_counts(user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
    in_date_records = WorkingHoursTransactionRecord.where(apply_date: start_date..end_date,
                                                          source_id: nil,
                                                          is_deleted: [false, nil],
                                                          is_compensate: false,
                                                         )
    tmp_as_a_in_borrow = in_date_records.where(user_a_id: u_id, apply_type: 'borrow_hours')
    tmp_as_b_in_borrow = in_date_records.where(user_b_id: u_id, apply_type: 'borrow_hours')

    as_a_in_borrow = tmp_as_a_in_borrow.reduce(0) do |sum, wht|
      return_wht = WorkingHoursTransactionRecord.where(borrow_id: wht.id, is_compensate: false, is_deleted: [nil, false])&.first
      after_10_days = wht.apply_date + 10.day
      should_not_add = (return_wht && return_wht.apply_date >= after_10_days) || (!return_wht && after_10_days <= end_date)
      sum = should_not_add ? sum : sum + 1
      sum
    end

    as_b_in_borrow = tmp_as_b_in_borrow.reduce(0) do |sum, wht|
      return_wht = WorkingHoursTransactionRecord.where(borrow_id: wht.id, is_compensate: false, is_deleted: [nil, false])&.first
      after_x_days = wht.user_a_id == nil ? wht.apply_date + 30.day : wht.apply_date + 10.day
      # should_not_add = (return_wht && return_wht.apply_date > after_x_days) || (wht.can_be_return == true && after_x_days < end_date)
      should_add = return_wht || (!return_wht && after_x_days > end_date)
      sum = should_add ? sum + 1 : sum
      sum
    end

    # as_a_in_borrow = in_date_records.where(user_a_id: u_id, apply_type: 'borrow_hours').count
    # as_b_in_borrow = in_date_records.where(user_b_id: u_id, apply_type: 'borrow_hours').count
    as_a_in_return = in_date_records.where(user_a_id: u_id, apply_type: 'return_hours').count
    as_b_in_return = in_date_records.where(user_b_id: u_id, apply_type: 'return_hours').count
    {
      as_a_in_borrow_hours_counts: as_a_in_borrow,
      as_b_in_borrow_hours_counts: as_b_in_borrow,
      as_a_in_return_hours_counts: as_a_in_return,
      as_b_in_return_hours_counts: as_b_in_return
    }
  end

  def set_typhoon_allowance_counts(start_date = nil, end_date = nil)
    self.save_data(self.class.get_typhoon_allowance_counts( self.user_id, self.year, self.month, start_date, end_date))
  end

  def self.get_typhoon_allowance_counts( user_id, year, month, start_date = nil, end_date = nil)
    u_id, y , m , start_date, end_date = formed_params(user_id, year, month, start_date, end_date)
    start_date = start_date.nil? ? Time.zone.local(y, m, 1).to_date.beginning_of_month : start_date.to_date
    end_date = end_date.nil? ? Time.zone.local(y, m, 1).to_date.end_of_month : end_date.to_date
    total_counts = TyphoonQualifiedRecord.where(user_id: u_id, qualify_date: start_date..end_date, is_apply: true).count
    {
      typhoon_allowance_counts: total_counts
    }
  end

  def save_data(data)
    data.each do |k, v|
      self[k] = v
    end
    self.save
  end

  def self.update_calc_status(user_id, date)
    if report = AttendMonthlyReport.where(user_id: user_id, year: date.year, month: date.month).first
      # report.status = 'not_calc'
      RefreshAttendMonthlyReportJob.perform_later(report)
      report.save
    else
      AttendMonthlyReport.create(user_id: user_id,
                                 year: date.year,
                                 month: date.month,
                                 year_month: "#{date.year}#{date.month.to_s.rjust(2, "0")}".to_i,
                                 status: 'not_calc'
                                )
    end
  end


  def self.create_fake_data_reports
    fake_data = [1, 2, 3]
    # user_id 69, 62， 68
    [
      {user_id: 62, department_id: 12, year: 2012, month: 1, year_month: 201201},
      {user_id: 62, department_id: 12, year: 2012, month: 2, year_month: 201202},
      {user_id: 68, department_id: 12, year: 2012, month: 1, year_month: 201201},
      {user_id: 68, department_id: 12, year: 2012, month: 2, year_month: 201202},
      {user_id: 69, department_id: 12, year: 2012, month: 1, year_month: 201201},
      {user_id: 69, department_id: 12, year: 2012, month: 2, year_month: 201202},
    ].each do |pa|
      report = AttendMonthlyReport.create(
        user_id: pa[:user_id],
        department_id: pa[:department_id],
        year: pa[:year],
        month: pa[:month],
        year_month: pa[:year_month]
      )

      (AttendMonthlyReport.new.attributes.keys - ["id", "department_id", "user_id", "year", "month", "year_month", "created_at", "updated_at"]).each do |field|
        me = "#{field}=".to_sym
        report.send(me, fake_data.sample)
        report.save!
      end

      # for compensate_report
      if pa[:month] == 2
        ['original', 'compensate'].each do |type|
          c_report = CompensateReport.create(report.attributes.merge(
                                               {id: nil,
                                                year: 2012,
                                                record_type: type,
                                                month: 1,
                                                year_month: 201202
                                               }
                                             ))

          c_report.save!

          if type == 'compensate'
            c_report.signcard_work_out_counts = c_report.signcard_work_out_counts + 1
            c_report.annual_leave_counts = c_report.annual_leave_counts + 1
            c_report.force_holiday_overtime_hours = c_report.force_holiday_overtime_hours + 1
            c_report.save!
          end
        end
      end
    end
  end

  def self.complete_table_for(company, department_ids, position_ids, user_ids, start_d, end_d)
    selected_users = nil
    start_ym = Time.zone.parse(start_d).to_datetime
    end_ym = Time.zone.parse(end_d).to_datetime
    start_end_month = (start_ym .. end_ym).map { |d| d.end_of_month }.compact.uniq

    all_users = User.all

    if company
      selected_users = selected_users == nil ? [nil] : selected_users
      current_users = !selected_users.empty? && selected_users.first == nil ? all_users : selected_users
      selected_users = []

      current_users.each do |u|
        selected_users << u if company.include?(u.company_name)
      end
    end

    if user_ids
      selected_users = selected_users == nil ? [nil] : selected_users
      current_users = !selected_users.empty? && selected_users.first == nil ? all_users : selected_users
      selected_users = []

      int_user_ids = user_ids.map(& :to_i)

      current_users.each do |u|
        selected_users << u if int_user_ids.include?(u.id)
      end
    end

    if department_ids
      selected_users = selected_users == nil ? [nil] : selected_users
      current_users = !selected_users.empty? && selected_users.first == nil ? all_users : selected_users
      selected_users = []

      int_department_ids = department_ids.map(& :to_i)

      start_end_month.each do |d|
        current_users.each do |u|
          department = ProfileService.department(u, d)
          selected_users << u if (department && int_department_ids.include?(department.id))
        end
      end
    end

    if position_ids
      selected_users = selected_users == nil ? [nil] : selected_users
      current_users = !selected_users.empty? && selected_users.first == nil ? all_users : selected_users
      selected_users = []

      int_position_ids = position_ids.map(& :to_i)

      start_end_month.each do |d|
        current_users.each do |u|
          position = ProfileService.position(u, d)
          selected_users << u if (position && int_position_ids.include?(position.id))
        end
      end
    end

    final_users = selected_users == nil ? all_users : selected_users

    final_users.each do |su|
      start_end_month.each do |d|
        if AttendMonthlyReport.where(user_id: su.id, year: d.year, month: d.month).first == nil
          AttendMonthlyReport.create(user_id: su.id,
                                     year: d.year,
                                     month: d.month,
                                     year_month: "#{d.year}#{d.month.to_s.rjust(2, "0")}".to_i,
                                     status: 'calculated'
                                    )
        end
      end
    end
  end

  private

  def self.formed_params(user_id, year, month, start_date, end_date)
    [user_id, year, month, start_date.nil? ? Time.zone.local(year, month, 1).to_date.beginning_of_month : start_date.to_date, end_date.nil? ? Time.zone.local(year, month, 1).to_date.end_of_month : end_date.to_date]
  end
end
