class HolidayCalculateService
  class << self
    # annual_leave: 0
    # birthday_leave: 1
    # paid_bonus_leave: 2
    # compensatory_leave: 3
    # paid_sick_leave: 4
    # unpaid_sick_leave: 5
    # unpaid_leave: 6
    # paid_marriage_leave: 7
    # unpaid_marriage_leave: 8
    # paid_compassionate_leave: 9
    # unpaid_compassionate_leave: 10
    # maternity_leave: 11
    # paid_maternity_leave: 12
    # unpaid_maternity_leave: 13
    # immediate_leave: 14
    # absenteeism: 15
    # work_injury: 16
    # unpaid_but_maintain_position: 17
    # overtime_leave: 18
    # pregnant_sick_leave: 19
    # reserved: 20

    def calculate_total_days
      0
    end

    def calculate_taken_days(query_date, user, holiday_type, apply_type)
      date_of_employment = user.profile.data['position_information']['field_values']['date_of_employment']
      start_date = Time.zone.parse(date_of_employment)
      dead_line = apply_type == 'taken' ? Time.zone.now : query_date
      records = HolidayRecord.where(user_id: user.id, source_id: nil, holiday_type: holiday_type, start_date: start_date..dead_line, is_deleted: [false, nil])
      counts = records.inject(0) do |sum, r|
        sum = holiday_type == 'overtime_leave' ? (sum + r.hours_count.to_i) : (sum + r.days_count.to_i)
      end
      counts
    end

    def calculate_accumulation_days(query_date, user, holiday_type, apply_type)
      case holiday_type
        when 'annual_leave'
          HolidayRecord.calc_total_annual_leave_count_until_date(user, query_date) - calculate_taken_days(query_date, user, holiday_type, apply_type)
        when 'birthday_leave'
          date_of_employment = user ? user.profile.data['position_information']['field_values']['date_of_employment'] : nil
          entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil
          after_one_year = entry ? entry + 365.day : nil

          date_of_birth = user.profile.data['personal_information']['field_values']['date_of_birth'] if user
          b_day = (date_of_birth != nil && date_of_birth != "") ? date_of_birth.in_time_zone.to_date : nil

          parse_date = Time.zone.parse(query_date).to_date

          count = (after_one_year && b_day && parse_date && parse_date > after_one_year && parse_date.month == b_day.month) ? 1 : 0
          count

        when 'paid_bonus_leave'
          HolidayRecord.calc_total_paid_bonus_leave_count_until_date(user, query_date) - calculate_taken_days(query_date, user, holiday_type, apply_type)
        when 'compensatory_leave'
          HolidayRecord.calc_compensatory_leave_count(user, Time.zone.parse(query_date).year) - calculate_taken_days(query_date, user, holiday_type, apply_type)
        when 'paid_sick_leave'
          HolidayRecord.calc_total_paid_sick_leave_count_until_date(user, query_date) - calculate_taken_days(query_date, user, holiday_type, apply_type)
        when 'unpaid_sick_leave'
          0
        when 'unpaid_leave'
          0
        when 'paid_marriage_leave'
          HolidayRecord.calc_paid_marriage_leave_count(user, Time.zone.parse(query_date).year) - calculate_taken_days(query_date, user, holiday_type, apply_type)
        when 'unpaid_marriage_leave'
          HolidayRecord.calc_unpaid_marriage_leave_count(user, Time.zone.parse(query_date).year) - calculate_taken_days(query_date, user, holiday_type, apply_type)
        when 'paid_compassionate_leave'
          HolidayRecord.calc_paid_compassionate_leave_count(user, Time.zone.parse(query_date).year) - calculate_taken_days(query_date, user, holiday_type, apply_type)
        when 'unpaid_compassionate_leave'
          HolidayRecord.calc_unpaid_compassionate_leave_count(user, Time.zone.parse(query_date).year) - calculate_taken_days(query_date, user, holiday_type, apply_type)
        when 'maternity_leave'
          HolidayRecord.calc_maternity_leave_count(user, Time.zone.parse(query_date).year) - calculate_taken_days(query_date, user, holiday_type, apply_type)
        when 'paid_maternity_leave'
          HolidayRecord.calc_paid_maternity_leave_count(user, Time.zone.parse(query_date).year) - calculate_taken_days(query_date, user, holiday_type, apply_type)
        when 'unpaid_maternity_leave'
          HolidayRecord.calc_unpaid_maternity_leave_count(user, Time.zone.parse(query_date).year) - calculate_taken_days(query_date, user, holiday_type, apply_type)
        when 'immediate_leave'
          0
        when 'absenteeism'
          0
        when 'work_injury'
          0
        when 'unpaid_but_maintain_position'
          0
        when 'overtime_leave'
          HolidayRecord.calc_overtime_leave_count(user, Time.zone.parse(query_date).year) - calculate_taken_days(query_date, user, holiday_type, apply_type)
        when 'pregnant_sick_leave'
          0
        else
          /reserved_holiday_\d+/.match(holiday_type)
          reserved_holiday_setting_id = holiday_type.split('_').last.to_i
          rhs = ReservedHolidaySetting.find_by(id: reserved_holiday_setting_id)
          total_count = rhs ? rhs.days_count.to_i : 0
          count = total_count - calculate_taken_days(query_date, user, holiday_type, apply_type)
          if ReservedHolidayParticipator.where(reserved_holiday_setting_id: reserved_holiday_setting_id).pluck(:user_id).include? user.id
            count_all = count
          else
            count_all = 0
          end
          count_all
      end
    end

    def calculate_total_counts(user, holiday_type)
      case holiday_type
        when :annual_leave
          return 0
      end
    end

    private

  end
end
