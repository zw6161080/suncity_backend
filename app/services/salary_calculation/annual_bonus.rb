module SalaryCalculation
  module AnnualBonus

    # 双粮
    def double_pay_mop(user, year_month_date)
      AnnualBonusItem
        .joins(:annual_bonus_event)
        .where(user_id: user.id)
        .where(annual_bonus_events: { settlement_date: year_month_date.month_range, settlement_type: :salary_settlement })
        .sum(:double_pay_mop)
    end

    # 花红
    def year_end_bonus_mop(user, year_month_date)
      AnnualBonusItem
        .joins(:annual_bonus_event)
        .where(user_id: user.id)
        .where(annual_bonus_events: { settlement_date: year_month_date.month_range, settlement_type: :salary_settlement })
        .sum(:year_end_bonus_mop)
    end

    # 全年勤工奖 HKD
    def annual_incentive_payment_hkd(user, year_month_date)
      AnnualBonusItem
        .joins(:annual_bonus_event)
        .where(user_id: user.id)
        .where(annual_bonus_events: { settlement_date: year_month_date.month_range, settlement_type: :salary_settlement })
        .sum(:annual_incentive_payment_hkd)
    end

  end
end
