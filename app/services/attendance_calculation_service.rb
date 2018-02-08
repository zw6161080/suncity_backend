class AttendanceCalculationService
  class << self

    def normal_overtime_hours(user, year_month_date)
      OverTimeItem
        .joins(:over_time)
        .where(over_times: { user_id: user.id })
        .where(date: year_month_date.month_range)
        .where(over_time_type: :weekday_work)
        .where(make_up_type: :add_money)
        .sum(:duration)
    end

    def holiday_overtime_hours(user, year_month_date)
      OverTimeItem
        .joins(:over_time)
        .where(over_times: { user_id: user.id })
        .where(date: year_month_date.month_range)
        .where(over_time_type: :holiday_work)
        .where(make_up_type: :add_money)
        .sum(:duration)
    end


    def compulsion_holiday_compensation_days(user, year_month_date)
      welfare_template_row = (user.profile.fetch_welfare_history_section_rows.presence || []).find do |item|
        begin_date = Time.zone.parse(item['welfare_start_date']).beginning_of_day rescue nil
        end_date = Time.zone.parse(item['welfare_end_date']).end_of_day rescue nil
        if begin_date.nil? && end_date.nil?
          false
        elsif end_date.nil?
          item['status'] == 1 && begin_date < year_month_date.end_of_month
        else
          year_month_date.end_of_month === (begin_date..end_date)
        end
      end

      overtime_days = common_holiday_overtime_days(user, year_month_date, :force_holiday)

      if welfare_template_row.nil?
        0
      else
        case welfare_template_row.force_holiday_make_up
        when 'one_money_and_one_holiday'
          overtime_days
        when 'two_money'
          overtime_days * 2
        else
          0
        end
      end
    end

    def public_holiday_compensation_days(user, year_month_date)
      common_holiday_overtime_days(user, year_month_date, :public_holiday)
    end

    def absenteeism_days(user, year_month_date)
      AbsenteeismItem
        .joins(:absenteeism)
        .where(absenteeisms: { user_id: user.id })
        .where(date: year_month_date.month_range)
        .count
    end

    def immediate_leave_days(user, year_month_date)
      ImmediateLeaveItem
        .joins(:immediate_leave)
        .where(immediate_leaves: { user_id: user.id })
        .where(date: year_month_date.beginning_of_month..year_month_date.end_of_month)
        .count
    end

    def unpaid_leave_days(user, year_month_date)
      common_leave_days(user, year_month_date, :none_paid_leave)
    end

    def paid_sick_leave_days(user, year_month_date)
      common_leave_days(user, year_month_date, :paid_illness_leave)
    end

    def paid_sick_leave_adjoin_public_holiday_days(user, year_month_date)
      # TODO (zhangmeng): 病假连公休假期天数
      0
    end

    def paid_sick_leave_not_adjoin_public_holiday_days(user, year_month_date)
      # TODO (zhangmeng): 病假不连公休假期天数
      0
    end

    def unpaid_marriage_leave_days(user, year_month_date)
      common_leave_days(user, year_month_date, :nonepaid_marriage_holiday)
    end

    def unpaid_compassionate_leave_days(user, year_month_date)
      common_leave_days(user, year_month_date, :nonepaid_grace_leave)
    end

    def unpaid_maternity_leave_days(user, year_month_date)
      common_leave_days(user, year_month_date, :nonepaid_maternity_leave)
    end

    def paid_maternity_leave_days(user, year_month_date)
      common_leave_days(user, year_month_date, :paid_maternity_leave)
    end

    def pregnant_sick_leave_days(user, year_month_date)
      common_leave_days(user, year_month_date, :pregnancy_leave)
    end

    def occupational_injury_days(user, year_month_date)
      common_leave_days(user, year_month_date, :work_injury_leave)
    end

    def late_0_10_min_times(user, year_month_date)
      common_calc_late_times(user, year_month_date, 0, 10)
    end

    def late_10_20_min_times(user, year_month_date)
      common_calc_late_times(user, year_month_date, 10, 20)
    end

    def late_20_30_min_times(user, year_month_date)
      common_calc_late_times(user, year_month_date, 20, 30)
    end

    def late_30_120_min_times(user, year_month_date)
      common_calc_late_times(user, year_month_date, 30, 120)
    end

    def missing_punch_times(user, year_month_date)
      AttendanceItem
        .where(user_id: user.id)
        .where(attendance_date: year_month_date.month_range)
        .where('states LIKE :start_state OR states LIKE :end_state',
               start_state: '%上班打卡異常%',
               end_state: '%下班打卡異常%')
        .count
    end

    private

    def common_holiday_overtime_days(user, year_month_date, holiday_category)
      beginning_of_month = year_month_date.beginning_of_month
      end_of_month = year_month_date.end_of_month

      # 当月所有假日的区间
      holiday_ranges = PublicHoliday
                         .where('start_date >= :beginning_of_month AND start_date <= :end_of_month
                                 OR end_date >= :beginning_of_month AND end_date <= :end_of_month',
                                beginning_of_month: beginning_of_month,
                                end_of_month: end_of_month)
                         .where(category: holiday_category)
                         .map { |holiday| [holiday.start_date, beginning_of_month].min..[holiday.end_date, end_of_month].max }

      # 当月假期排班的天数
      db_table = RosterItem.arel_table
      query = RosterItem.where(user: user)
      unless holiday_ranges.empty?
        conditions = holiday_ranges.inject(db_table) do |sum, range|
          condition = db_table[:date].in(range)
          sum.class == Arel::Table ? condition : sum.or(condition)
        end
        query = query.where(conditions)
      end
      query.count
      # TODO (zhangmeng): 是否需要判断排班的这天是否来上班了？
    end

    def common_leave_days(user, year_month_date, holiday_type)
      beginning_of_month = year_month_date.beginning_of_month
      end_of_month = year_month_date.end_of_month

      HolidayItem
        .includes(:holiday)
        .where(holidays: { user_id: user.id })
        .where(holiday_type: holiday_type)
        .where('start_time >= :beginning_of_month AND start_time <= :end_of_month
               OR end_time >= :beginning_of_month AND end_time <= :end_of_month',
               beginning_of_month: beginning_of_month,
               end_of_month: end_of_month)
        .map { |holiday| [holiday.start_time, beginning_of_month].min..[holiday.end_time, end_of_month].max }
        .inject(0) { |sum, range| sum + range.count }
    end

    def common_calc_late_times(user, year_month_date, minutes_min, minutes_max)
      AttendanceItem
        .where(user_id: user.id)
        .where(attendance_date: year_month_date.beginning_of_month..year_month_date.end_of_month)
        .where("start_working_time - plan_start_time > interval '#{minutes_min} minutes'")
        .where("start_working_time - plan_start_time <= interval '#{minutes_max} minutes'")
        .count
    end

  end
end