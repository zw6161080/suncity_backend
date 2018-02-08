module SalaryCalculation
  module AttendancePaybackReduction

    # 所有参与考勤补扣薪的假期类别
    def all_leave_types
      [
        :paid_maternity_leave,
        :absenteeism,
        :immediate_leave,
        :unpaid_leave,
        :unpaid_marriage_leave,
        :unpaid_compassionate_leave,
        :unpaid_maternity_leave,
        :pregnant_sick_leave,
        :occupational_injury
      ]
    end

    # 所有考勤补薪项
    def all_payback_leave_types
      [:paid_maternity_leave]
    end

    # 所有考勤扣薪项
    def all_reduction_leave_types
      all_leave_types - all_payback_leave_types
    end

    # 薪酬計算統一按照每天30天計算考勤比例
    def salary_days_in_month
      BigDecimal('30')
    end

    # 当月考勤对【薪金项】的扣薪/补薪
    def attendance_salary_payback_or_reduction(salary_key:, leave_type:, user:, year_month_date:, unit:)
      days = AttendanceCalculationService.send("#{leave_type}_days", user, year_month_date)
      factor_value = salary_element_factor_value("#{leave_type}_#{all_salary_keys_table[salary_key].presence || salary_key}")
      raw_salary_in_date(user, year_month_date, salary_key, unit) * factor_value * days / salary_days_in_month
    end

    # 当月考勤对【部门制】【浮动薪金项】扣薪/补薪
    def departmental_bonus_payback_or_reduction(bonus_key:, leave_type:, user:, year_month_date:, unit:)
      days = AttendanceCalculationService.send("#{leave_type}_days", user, year_month_date)
      value = raw_bonus(user: user, year_month_date: year_month_date, bonus_key: bonus_key, unit: unit, bonus_value_type: 'departmental')
      factor = salary_element_factor_value("#{leave_type}_department_bonus")
      value * factor * days / salary_days_in_month
    end

    # 当月考勤对【个人制】【浮动薪金项】扣薪/补薪
    def personal_bonus_payback_or_reduction(bonus_key:, leave_type:, user:, year_month_date:, unit:)
      days = AttendanceCalculationService.send("#{leave_type}_days", user, year_month_date)
      value = raw_bonus(user: user, year_month_date: year_month_date, bonus_key: bonus_key, unit: unit, bonus_value_type: 'personal')
      factor = salary_element_factor_value("#{leave_type}_personal_bonus")
      value * factor * days / salary_days_in_month
    end

    # 当月考勤对【勤工】的扣薪/补薪
    def incentive_payback_or_reduction(leave_type:, user:, year_month_date:, unit:)
      days = AttendanceCalculationService.send("#{leave_type}_days", user, year_month_date)
      factor = salary_element_factor_value("#{leave_type}_days")
      if unit == 'hkd'
        days * factor
      else
        BigDecimal('0')
      end
    end

    #========== 假期补偿及其他补薪/扣薪 ================

    # 强制假期补偿
    def compulsion_holiday_compensation(user, year_month_date, unit)
      AttendanceCalculationService.compulsion_holiday_compensation_days(user, year_month_date) * raw_salary_in_date(user, year_month_date, :basic_salary, unit) / salary_days_in_month
    end

    # 公众假期补偿
    def public_holiday_compensation(user, year_month_date, unit)
      AttendanceCalculationService.public_holiday_compensation_days(user, year_month_date) * raw_salary_in_date(user, year_month_date, :basic_salary, unit) / salary_days_in_month
    end

    # 有薪病假扣薪
    def paid_sick_leave_reduction_hkd(user, year_month_date)
      days_adjoin_public_holiday = AttendanceCalculationService.paid_sick_leave_adjoin_public_holiday_days(user, year_month_date)
      days_not_adjoin_public_holiday = AttendanceCalculationService.paid_sick_leave_not_adjoin_public_holiday_days(user, year_month_date)
      BigDecimal(days_adjoin_public_holiday) * salary_element_factor_value('paid_sick_leave_adjoin_public_holiday') +
        BigDecimal(days_not_adjoin_public_holiday) * salary_element_factor_value('paid_sick_leave_not_adjoin_public_holiday')
    end

    # 迟到扣薪 HKD
    def late_reduction_hkd(user, year_month_date)
      att = AttendanceCalculationService
      BigDecimal([att.late_0_10_min_times(user, year_month_date) - 3, 0].max) * BigDecimal('250') +
        BigDecimal(att.late_10_20_min_times(user, year_month_date)) * BigDecimal('250') +
        BigDecimal(att.late_20_30_min_times(user, year_month_date)) * BigDecimal('500') +
        BigDecimal(att.late_30_120_min_times(user, year_month_date)) * BigDecimal('750')
    end

    # 漏打卡扣薪 HKD
    def missing_punch_card_reduction_hkd(user, year_month_date)
      BigDecimal([AttendanceCalculationService.missing_punch_times(user, year_month_date) - 1, 0].max) * 300
    end

    # 加班费
    def overtime_pay(user, year_month_date, unit)
      # TODO (zhangmeng): 是否需要读取福利模板？
      normal_ot_hours = AttendanceCalculationService.normal_overtime_hours(user, year_month_date)
      normal_ot_hours = BigDecimal(normal_ot_hours.to_s)
      holiday_ot_hours = AttendanceCalculationService.holiday_overtime_hours(user, year_month_date)
      holiday_ot_hours = BigDecimal(holiday_ot_hours.to_s)
      raw_salary_in_date(user, year_month_date, :basic_salary, unit) / salary_days_in_month / BigDecimal('8') *
        (normal_ot_hours * BigDecimal('1.2') + holiday_ot_hours * BigDecimal('2'))
    end

    #========== 以下为汇总计数 ===========

    # 考勤某一项【假期】的总扣除/总补薪
    def attendance_leave_total_reduction_or_payback(leave_type:, user:, year_month_date:, unit:)
      res = all_salary_keys_table.keys.inject(BigDecimal('0')) { |sum, salary_key|
        sum + attendance_salary_payback_or_reduction(salary_key: salary_key, leave_type: leave_type, user: user, year_month_date: year_month_date, unit: unit)
      }

      res = all_bonus_keys.inject(res) { |sum, bonus_key|
        sum +
          departmental_bonus_payback_or_reduction(bonus_key: bonus_key, leave_type: leave_type, user: user, year_month_date: year_month_date, unit: unit) +
          personal_bonus_payback_or_reduction(bonus_key: bonus_key, leave_type: leave_type, user: user, year_month_date: year_month_date, unit: unit)
      }
      res + incentive_payback_or_reduction(leave_type: leave_type, user: user, year_month_date: year_month_date, unit: unit)
    end

    # 考勤对某一项【薪金项】的总扣除
    def attendance_total_salary_reduction(salary_key:, user:, year_month_date:, unit:)
      all_reduction_leave_types.inject(BigDecimal('0')) do |res, leave_type|
        tmp = res + attendance_salary_payback_or_reduction(salary_key: salary_key, leave_type: leave_type, user: user, year_month_date: year_month_date, unit: unit)
        if salary_key == :incentive
          # 对于勤工奖，还需要按照请假天数额外扣除/补薪HKD
          tmp = tmp + incentive_payback_or_reduction(leave_type: leave_type, user: user, year_month_date: year_month_date, unit: unit)
        end
        tmp
      end
    end

    # 考勤对某一项【薪金项】的总补薪
     def attendance_total_salary_payback(salary_key:, user:, year_month_date:, unit:)
      all_payback_leave_types.inject(BigDecimal('0')) do |res, leave_type|
        tmp = res + attendance_salary_payback_or_reduction(salary_key: salary_key, leave_type: leave_type, user: user, year_month_date: year_month_date, unit: unit)
        if salary_key == :incentive
          # 对于勤工奖，还需要按照请假天数额外扣除/补薪HKD
          tmp = tmp + incentive_payback_or_reduction(leave_type: leave_type, user: user, year_month_date: year_month_date, unit: unit)
        end
        tmp
      end
     end


    # 考勤对某一项【浮动薪金】的总扣除
    def attendance_total_bonus_reduction(bonus_key:, user:, year_month_date:, unit:)
      all_reduction_leave_types.inject(BigDecimal('0')) do |res, leave_type|
        res +
          departmental_bonus_payback_or_reduction(bonus_key: bonus_key,
                                                  leave_type: leave_type,
                                                  user: user,
                                                  year_month_date: year_month_date,
                                                  unit: unit) +
          personal_bonus_payback_or_reduction(bonus_key: bonus_key,
                                              leave_type: leave_type,
                                              user: user,
                                              year_month_date: year_month_date,
                                              unit: unit)
      end
    end

    # 考勤对某一项【浮动薪金】的总补薪
    def attendance_total_bonus_payback(bonus_key:, user:, year_month_date:, unit:)
      all_payback_leave_types.inject(BigDecimal('0')) do |res, leave_type|
        res +
          departmental_bonus_payback_or_reduction(bonus_key: bonus_key,
                                                  leave_type: leave_type,
                                                  user: user,
                                                  year_month_date: year_month_date,
                                                  unit: unit) +
          personal_bonus_payback_or_reduction(bonus_key: bonus_key,
                                              leave_type: leave_type,
                                              user: user,
                                              year_month_date: year_month_date,
                                              unit: unit)
      end
    end

  end
end