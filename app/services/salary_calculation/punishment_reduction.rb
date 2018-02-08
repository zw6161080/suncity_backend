module SalaryCalculation
  module PunishmentReduction

    # 员工当月是否有纪律处分
    def punished(user:, year_month_date:)
      Punishment
        .where(punishment_date: year_month_date.month_range)
        .where(user_id: user.id)
        .where(punishment_result: [:classA_written_warning, :classB_written_warning, :final_written_warning ])
        .exists?
    end

    # 纪律处分对某一项【浮动薪金】的扣薪
    def punishment_bonus_reduction(bonus_key:, user:, year_month_date:, unit:)
      raw_bonus(user: user, year_month_date: year_month_date, bonus_key: bonus_key, unit: unit) * salary_element_factor_value("punishment_#{bonus_key}")
    end

    # 纪律处分对某一项【浮动薪金】的最终实际扣除
    def actual_punishment_bonus_reduction(bonus_key:, user:, year_month_date:, unit:)
      att_reduction = attendance_total_bonus_reduction(bonus_key: bonus_key, user: user, year_month_date: year_month_date, unit: unit) -
        attendance_total_bonus_payback(bonus_key: bonus_key, user: user, year_month_date: year_month_date, unit: unit)

      punishment_reduction = punishment_bonus_reduction(bonus_key: bonus_key, user: user, year_month_date: year_month_date, unit: unit)

      [punishment_reduction, raw_bonus(user: user, year_month_date: year_month_date, bonus_key: bonus_key, unit: unit) - att_reduction].min
    end

    def all_actual_punishment_bonus_reduction(user:, year_month_date:, unit:)
      all_bonus_keys.inject(BigDecimal('0')) { |sum, bonus_key|
        sum + actual_punishment_bonus_reduction(bonus_key: bonus_key, user: user, year_month_date: year_month_date, unit: unit)
      }
    end
  end
end
