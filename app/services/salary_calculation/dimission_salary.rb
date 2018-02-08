module SalaryCalculation
  module DimissionSalary
    # 是否当月离职
    def is_dismissed_this_month(user, year_month_date)
      user.dimissions.where(last_work_date: year_month_date.month_range).exists?
    end

    # 年资补偿
    def seniority_compensation_hkd(user, year_month_date)
      DismissionSalaryItem
        .joins(:dimission)
        .where(user_id: user.id)
        .where(dimissions: { last_work_date: year_month_date.month_range })
        .sum(:seniority_compensation_hkd)
    end

    def seniority_compensation_mop(user, year_month_date)
      hkd_to_mop seniority_compensation_hkd(user, year_month_date)
    end

    # 离职剩余年假补偿
    def dismission_annual_holiday_compensation_hkd(user, year_month_date)
      DismissionSalaryItem
        .joins(:dimission)
        .where(user_id: user.id)
        .where(dimissions: { last_work_date: year_month_date.month_range })
        .sum(:dismission_annual_holiday_compensation_hkd)
    end

    def dismission_annual_holiday_compensation_mop(user, year_month_date)
      hkd_to_mop dismission_annual_holiday_compensation_hkd(user, year_month_date)
    end

    # 离职通知期补偿
    def dismission_inform_period_compensation_hkd(user, year_month_date)
      DismissionSalaryItem
        .joins(:dimission)
        .where(user_id: user.id)
        .where(dimissions: { last_work_date: year_month_date.month_range })
        .sum(:dismission_inform_period_compensation_hkd)
    end

    def dismission_inform_period_compensation_mop(user, year_month_date)
      hkd_to_mop dismission_inform_period_compensation_hkd(user, year_month_date)
    end

  end
end
