class SalaryCalculationService
  class << self

    include SalaryCalculation::RawSalary
    include SalaryCalculation::RawBonus
    include SalaryCalculation::AttendancePaybackReduction
    include SalaryCalculation::DimissionSalary
    include SalaryCalculation::AnnualBonus
    include SalaryCalculation::PunishmentReduction

    def get_provident_fund_exchange_by_grade(grade)
      case grade
        when '1', 1 , '2', 2
          BigDecimal('0.07')
        when '3', 3, '4', 4
          BigDecimal('0.06')
        when '5', 5
          BigDecimal('0.05')
        else
          BigDecimal('0')
      end
    end

    def hkd_to_mop_exchange_rate
      BigDecimal(Config.get('salary_constants')['HKD_to_MOP_exchange_rate'])
    end

    def hkd_to_mop(hkd_decimal)
      hkd_decimal * hkd_to_mop_exchange_rate
    end

    def mop_to_hkd(mop_decimal)
      mop_decimal / hkd_to_mop_exchange_rate
    end

    # 薪酬结算起始日期
    def salary_begin_date(user, year_month_date)
      year_month_date.beginning_of_month
    end

    # 薪酬结算结束日期
    def salary_end_date(user, year_month_date)
      dimission = user.dimissions.where(last_work_date: year_month_date.month_range).first
      if dimission.nil?
        year_month_date.end_of_month
      else
        dimission.last_work_date
      end
    end

    # 现金/支票支付
    def check_or_cash(user, year_month_date)
      dimission = user.dimissions.where(last_work_date: year_month_date.month_range).first
      if !dimission.nil? && (dimission.last_work_date === year_month_date.end_of_month.day_range)
        return :cash
      end
      (user.profile.sections.find('position_information').field_value('payment_method').presence || 'check').to_sym
    end

    # 薪金计算规则 - 薪金计算系数
    def salary_element_factor_value(key)
      factor = SalaryElementFactor.find_by_key(key)
      case factor.factor_type
      when 'fraction'
        BigDecimal(factor.numerator) / BigDecimal(factor.denominator)
      when 'value'
        BigDecimal(factor.value)
      else
        # raise LogicError, "unknown factor type #{factor.factor_type}"
        BigDecimal('0')
      end
    end

    # 实收金额
    def actual_salary(user, year_month_date, unit)
      total_salary(user, year_month_date, unit) - total_reduction(user, year_month_date, unit)
    end

    # 总薪酬
    def total_salary(user, year_month_date, unit)
      raw_salary_in_date(user, year_month_date, :basic_salary, unit) +
        raw_salary_in_date(user, year_month_date, :bonus, unit) +
        raw_salary_in_date(user, year_month_date, :attendance_award, unit) +
        raw_salary_in_date(user, year_month_date, :house_bonus, unit) +
        overtime_pay(user, year_month_date, unit) +
        compulsion_holiday_compensation(user, year_month_date, unit) +
        public_holiday_compensation(user, year_month_date, unit) +
        medicare_reimbursement_mop(user, year_month_date) +
        all_salary_keys_table.keys.inject(BigDecimal('0')) { |sum, salary_key|
          sum + attendance_total_salary_payback(salary_key: salary_key, user: user, year_month_date: year_month_date, unit: unit)
        } +
        all_bonus_keys.inject(BigDecimal('0')) { |sum, bonus_key|
          sum + attendance_total_bonus_payback(bonus_key: bonus_key, user: user, year_month_date: year_month_date, unit: unit)
        }
        (unit == 'mop' ? double_pay_mop(user, year_month_date) : BigDecimal('0')) +
        (unit == 'mop' ? year_end_bonus_mop(user, year_month_date) : BigDecimal('0')) +
        (unit == 'hkd' ? seniority_compensation_hkd(user, year_month_date) : BigDecimal('0')) +
        (unit == 'hkd' ? dismission_annual_holiday_compensation_hkd(user, year_month_date) : BigDecimal('0')) +
        (unit == 'hkd' ? dismission_inform_period_compensation_hkd(user, year_month_date) : BigDecimal('0')) +
        raw_bonus(user: user, year_month_date: year_month_date, bonus_key: :cover_charge, unit: unit) +
        raw_bonus(user: user, year_month_date: year_month_date, bonus_key: :kill_bonus, unit: unit) +
        raw_bonus(user: user, year_month_date: year_month_date, bonus_key: :performance_bonus, unit: unit) +
        raw_bonus(user: user, year_month_date: year_month_date, bonus_key: :swiping_card_bonus, unit: unit) +
        raw_bonus(user: user, year_month_date: year_month_date, bonus_key: :commission_margin, unit: unit) +
        raw_bonus(user: user, year_month_date: year_month_date, bonus_key: :collect_accounts_bonus, unit: unit) +
        raw_bonus(user: user, year_month_date: year_month_date, bonus_key: :exchange_rate_bonus, unit: unit) +
        raw_bonus(user: user, year_month_date: year_month_date, bonus_key: :zunhuadian, unit: unit) +
        raw_bonus(user: user, year_month_date: year_month_date, bonus_key: :xinchunlishi, unit: unit) +
        raw_bonus(user: user, year_month_date: year_month_date, bonus_key: :project_bonus, unit: unit) +
        raw_bonus(user: user, year_month_date: year_month_date, bonus_key: :shangpin_bonus, unit: unit) +
        raw_bonus(user: user, year_month_date: year_month_date, bonus_key: :dispatch_bonus, unit: unit) +
        raw_bonus(user: user, year_month_date: year_month_date, bonus_key: :recommend_new_guest_bonus, unit: unit) +
        (unit == 'hkd' ? typhoon_benefits_hkd(user, year_month_date) : BigDecimal('0')) +
        (unit == 'hkd' ? annual_incentive_payment_hkd(user, year_month_date) : BigDecimal('0'))
    end

    # 总扣减
    def total_reduction(user, year_month_date, unit)
      (unit == 'mop' ? medical_insurance_plan_reduction_mop(user, year_month_date) : BigDecimal('0')) +
        (unit == 'mop' ? public_accumulation_fund_reduction_mop(user, year_month_date) : BigDecimal('0')) +
        (unit == 'mop' ? love_fund_reduction_mop(user, year_month_date) : BigDecimal('0')) +
        [:basic_salary, :benefits, :incentive].inject(BigDecimal('0')) { |sum, salary_key|
          sum + attendance_total_salary_reduction(salary_key: salary_key, user: user, year_month_date: year_month_date, unit: unit)
        }
        all_bonus_keys.inject(BigDecimal('0')) { |sum, bonus_key|
          sum +
            attendance_total_bonus_reduction(bonus_key: bonus_key, user: user, year_month_date: year_month_date, unit: unit) +
            actual_punishment_bonus_reduction(bonus_key: bonus_key, user: user, year_month_date: year_month_date, unit: unit)
        }
        (unit == 'hkd' ? paid_sick_leave_reduction_hkd(user, year_month_date) : BigDecimal('0')) +
        (unit == 'hkd' ? late_reduction_hkd(user, year_month_date) : BigDecimal('0')) +
        (unit == 'hkd' ? missing_punch_card_reduction_hkd(user, year_month_date) : BigDecimal('0'))
    end

    # 社会保障基金
    def social_security_fund_reduction_mop(user, year_month_date)
      social_security = SocialSecurityFundItem.where(user_id: user.id, year_month: year_month_date.month_range).first
      social_security.nil? ? BigDecimal('0.0') : social_security.company_payment_mop + social_security.employee_payment_mop
    end

    #=======================================

    # 爱心基金 MOP
    def love_fund_reduction_mop(user, year_month_date)
      reduction_mop = BigDecimal(Config.get('salary_constants')['love_fund_reduction_mop'])

      love_fund = LoveFund.find_by_user_id(user.id)
      return BigDecimal('0') if love_fund.nil?

      if (love_fund.to_status == 'participated_in_the_future' && (love_fund.participate_date.nil? ||love_fund.participate_date < Time.now)) || (love_fund.to_status == 'not_participated_in_the_future' && love_fund.cancel_date  &&love_fund.cancel_date > Time.zone.now.midnight)
        reduction_mop
      else
        BigDecimal('0')
      end

    end

    # 剩余年假天数
    def remaining_annual_holidays(user, year_month_date)
      HolidayService.remaining_annual_leave_days(nil, user.profile)
    end

    # 每月职业税扣减 MOP
    def occupation_tax_reduction_mop(user, year_month_date)
     salary_before_tax = total_salary(user, year_month_date, 'mop')  + total_salary(user, year_month_date, 'hkd') * hkd_to_mop_exchange_rate - medicare_reimbursement_mop(user, year_month_date) + medical_insurance_plan_reduction_mop(user, year_month_date) +  public_accumulation_fund_reduction_mop(user, year_month_date) + love_fund_reduction_mop(user, year_month_date) - house_bonus_in_tax_mop(user)
     salary_after_tax(salary_before_tax * BigDecimal(deduct_percent)) * BigDecimal(favorable_percent)
    end

    # 医疗报销 MOP
    def medicare_reimbursement_mop(user, year_month_date)
      BigDecimal(user.medical_reimbursements.where(apply_date: year_month_date.end_of_month.day_range).sum(:reimbursement_amount))

    end

    # 医疗保险 MOP
    def medical_insurance_plan_reduction_mop(user, year_month_date)
      if user.try(:medical_insurance_participator).try(:participate)  == 'participated'
        BigDecimal('50')
      else
        BigDecimal('0')
      end
    end

    # 公积金 MOP
    def public_accumulation_fund_reduction_mop(user, year_month_date)
      basic_salary = BigDecimal(user.profile.data['salary_information']['field_values']['basic_salary']) rescue BigDecimal('0')
      provident_fund_exchange = get_provident_fund_exchange_by_grade(user.grade)
      basic_salary * provident_fund_exchange
    end

    # 台风津贴 HKD
    def typhoon_benefits_hkd(user, year_month_date)
      ReviseClockItem.where(user_id: user.id, clock_date: salary_begin_date(user, year_month_date)...salary_end_date(user, year_month_date) ).count * BigDecimal(100) *1.03
    end

    # 补薪 HKD
    def back_pay_hkd(user, year_month_date)
      # TODO (zhangmeng): 待補充
      BigDecimal('0')
    end
    #计税房屋津貼 mop
    def house_bonus_in_tax_mop(user)
      house_bonus = BigDecimal(user.profile.data['salary_information']['field_values']['house_bonus']) rescue BigDecimal('0')
      house_bonus > BigDecimal(500) ? BigDecimal(500) : BigDecimal(0)
    end

    #全年不屬課稅收益固定扣除百分比：
    def deduct_percent
      OccupationTaxSetting.first.deduct_percent
    end

    #財政預算對職業稅稅率優惠比例：
    def favorable_percent
      OccupationTaxSetting.first.favorable_percent
    end

    def salary_after_tax(salary)
      if salary <= BigDecimal('144000.00')
        BigDecimal('0')
      elsif salary > BigDecimal('144000.00') && salary <= BigDecimal('164000.00')
        (salary - BigDecimal('144000.00')) * BigDecimal('0.07')
      elsif salary > BigDecimal('164000.00') && salary <= BigDecimal('184000.00')
        tax_over_164000 + (salary - BigDecimal('164000.00')) * BigDecimal('0.08')
      elsif salary > BigDecimal('184000.00') && salary <= BigDecimal('224000.00')
        tax_over_184000 + (salary - BigDecimal('184000.00')) * BigDecimal('0.09')
      elsif salary > BigDecimal('224000.00') && salary <= BigDecimal('304000.00')
        tax_over_224000 + (salary - BigDecimal('184000.00')) * BigDecimal('0.10')
      elsif salary > BigDecimal('304000.00') && salary <= BigDecimal('424000.00')
        tax_over_304000 + (salary - BigDecimal('304000.00')) * BigDecimal('0.11')
      elsif salary > BigDecimal('424000.00')
        tax_over_null(salary)
      end
    end

    def tax_over_164000
      BigDecimal('20000') * BigDecimal('0.07')
    end

    def tax_over_184000
      tax_over_164000 + BigDecimal('20000') * BigDecimal('0.08')
    end
    def tax_over_224000
      tax_over_184000 + BigDecimal('40000') * BigDecimal('0.09')
    end
    def tax_over_304000
      tax_over_224000+ BigDecimal('80000') * BigDecimal('0.10')
    end
    def tax_over_424000
      tax_over_304000 + BigDecimal('120000') * BigDecimal('0.11')
    end
    def tax_over_null(salary)
      tax_over_424000 + (salary - BigDecimal(424000))* BigDecimal('0.12')
    end


  end
end