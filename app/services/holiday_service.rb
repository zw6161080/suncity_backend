class HolidayService
  class << self
    def remaining_paid_marriage_holiday(profile)
      if is_permanent_staff?(profile)
        result = Config.get(:constants_collection)['PaidMarriageHolidayDays'] - User.joins(
            {holidays: [:holiday_items]}).select("sum(holiday_items.duration) as sum1"
        ).where(
            id: profile.user_id, holidays: {holiday_items: {holiday_type: Config.get(:constants_collection)['PaidMarriageHolidayType']}}
        ).group(
            "users.id"
        ).first.try(:sum1).to_i
        result > 1 ? result : 0
      else
        0
      end
    end

    def remaining_nonepaid_marriage_holiday(profile)
      if is_permanent_staff?(profile)
        result = Config.get(:constants_collection)['NonepaidMarriageHolidayDays'] - User.joins(
            {holidays: [:holiday_items]}).select("sum(holiday_items.duration) as sum1"
        ).where(
            id: profile.user_id, holidays: {holiday_items: {holiday_type: Config.get(:constants_collection)['NonepaidMarriageHolidayType']}}
        ).group(
            "users.id"
        ).first.try(:sum1).to_i
        result > 1 ? result : 0
      else
        0
      end
    end

    def remaining_paid_grace_leave(profile)
      this_year_range = Date.today.beginning_of_year..Date.today.end_of_year
      if is_permanent_staff?(profile)
        result = Config.get(:constants_collection)['PaidGraceLeaveDays'] - User.joins(
            {holidays: [:holiday_items]}).select("sum(holiday_items.duration) as sum1"
        ).where(
            id: profile.user_id, holidays: {holiday_items: {holiday_type: Config.get(:constants_collection)['PaidMarriageHolidayType'],
                                                         start_time: this_year_range}}
        ).group(
            "users.id"
        ).first.try(:sum1).to_i
        result > 1 ? result : 0
      else
        0
      end
    end

    def remaining_nonepaid_grace_leave(profile)
      this_year_range = Date.today.beginning_of_year..Date.today.end_of_year
      if is_permanent_staff?(profile)
        result = Config.get(:constants_collection)['NonepaidGraceLeaveDays'] - User.joins(
            {holidays: [:holiday_items]}).select("sum(holiday_items.duration) as sum1"
        ).where(
            id: profile.user_id, holidays: {holiday_items: {holiday_type: Config.get(:constants_collection)['NonepaidMarriageHolidayType'],
                                                         start_time: this_year_range}}
        ).group(
            "users.id"
        ).first.try(:sum1).to_i
        result > 1 ? result : 0
      else
        0
      end
    end

    def remaining_supplement_holiday
      #TODO 补假申请规则还未最终确定，目前可申请天数保持为0
      0
    end

    def remaining_none_paid_leave
      Config.get(:constants_collection)['NOLimitToHoliay']
    end

    def remaning_awaiting_delivery_leave(profile)
      if has_worked_for_a_year?(profile)
        2
      else
        0
      end
    end

    def remaining_paid_maternity_leave(profile)
      if has_worked_for_a_year?(profile)
        Config.get(:constants_collection)['PaidMaternityLeaveDays']
      else
        0
      end
    end

    def remaining_nonepaid_maternity_leave(profile)
      if has_worked_for_a_year?(profile)
        Config.get(:constants_collection)['NonepaidMaternityLeaveDays']
      else
        0
      end
    end

    def remaining_work_injury_leave
      Config.get(:constants_collection)['NOLimitToHoliay']
    end

    def remaining_without_pay_stay_leave
      Config.get(:constants_collection)['NOLimitToHoliay']
    end

    def remaining_pregnancy_leave(profile)
      if Config.get(:selects)['gender']['options'][1].fetch_values('chinese_name', 'english_name').include? profile.data['personal_information']['field_values']['gender']
        Config.get(:constants_collection)['NOLimitToHoliay']
      else
        0
      end
    end

    def remaining_best_empolyee_holiday
      #TODO 待补充 ，可申请天数暂为0
      0
    end

    def remaining_other_leave
      Config.get(:constants_collection)['NOLimitToHoliay']
    end


    def remaining_birthday_holiday(profile)
      date_of_birth = profile.data['personal_information']['field_values']['date_of_birth']
      year, month, day = date_of_birth.split('/')
      month_begin = Time.zone.local(Time.zone.now.year, month, day).beginning_of_month
      month_end = Time.zone.local(Time.zone.now.year, month, day).end_of_month
      if has_worked_for_a_year?(profile) &&(Time.zone.now > month_begin)&&(Time.zone.now < month_end)
        result = 1- User.joins(
            {holidays: [:holiday_items]}
        ).select(
            "sum(holiday_items.duration) as sum1"
        ).where(
            id: profile.user_id, holidays: {holiday_items: {holiday_type: Config.get(:constants_collection)['BirthdayHolidayType'],
                                                         start_time: month_begin..month_end}}
        ).group(
            "users.id"
        ).first.try(:sum1).to_i
        result >= 1 ? result : 0
      else
        0
      end
    end

    def remaining_annual_leave_days(to_date = nil, profile)
      date_of_employment = profile.data['position_information']['field_values']['date_of_employment']
      if !date_validate?(date_of_employment.to_s)
        0
      else
        result = profile.total_annual_leave_days_has_got(to_date) - profile.total_annual_leave_has_used
        result < 0 ? 0 : result
      end
    end

    def remaining_reward_leave_days(profile)
      days_of_award = profile.get_offered_reward_leave_days
      offer_date = profile.get_offer_date
      if offer_date[0] && offer_date[0].updated_at
        days_of_award - profile.get_used_reward_leave_days(offer_date[0].updated_at..Date.today.end_of_year)
      else
        days_of_award
      end
    end

    def remaining_sick_leave_days(profile)
      sick_leave = profile.data['holiday_information']['field_values']['sick_leave'].to_i
      this_year_range = Date.today.beginning_of_year..Date.today.end_of_year
      if sick_leave == 0 || !is_permanent_staff?(profile)
        0
      else
        sick_leave - User.joins(
            {holidays: [:holiday_items]}).select("sum(holiday_items.duration) as sum1"
        ).where(
            id: profile.user_id, holidays: {holiday_items: {holiday_type: Config.get(:constants_collection)['PaidIllnessLeaveType'], end_time: this_year_range}}
        ).group(
            "users.id"
        ).first.try(:sum1).to_i
      end
    end

    private
    def date_validate?(date)
      if date =~ /(([0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})\/(((0[13578]|1[02])\/(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)\/(0[1-9]|[12][0-9]|30))|(02\/(0[1-9]|[1][0-9]|2[0-8]))))|((([0-9]{2})(0[48]|[2468][048]|[13579][26])|((0[48]|[2468][048]|[3579][26])00))\/02\/29)/
        true
      else
        false
      end
    end

    def has_worked_for_a_year?(profile)
      date_of_employment = profile.data['position_information']['field_values']['date_of_employment']
      year, month, day = date_of_employment.split('/')
      date_of_employment_time = Time.zone.local(year, month, day)
      Time.zone.now > date_of_employment_time + 1.year
    end

    #判断是否为正式职工
    def is_permanent_staff?(profile)
      Config.get(:constants_collection)['FormalEmployeeType'].include? profile.data['position_information']['field_values']['employment_status']
    end

  end
end