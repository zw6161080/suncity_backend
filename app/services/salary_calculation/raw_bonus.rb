module SalaryCalculation
  module RawBonus

    # 浮动薪金的KEY
    def all_bonus_keys
      [
        :cover_charge, # 茶资
        :kill_bonus, # 杀数分红
        :performance_bonus, # 绩效奖金
        :swiping_card_bonus, # 刷卡奖金
        :commission_margin, # 佣金差额
        :collect_accounts_bonus, # 收账分红
        :exchange_rate_bonus, # 汇率分红
        :vip_card_bonus, # 贵宾卡消费
        :zunhuadian, # 尊华殿
        :xinchunlishi, # 新春利是
        :project_bonus, # 项目奖金
        :shangpin_bonus, # 尚品奖金
        :dispatch_bonus, # 出车奖金
        :recommend_new_guest_bonus # 推荐新客户转码奖金
      ]
    end

    # 获取员工当月浮动薪金数据项
    def get_bonus_element_item(user, year_month_date)
      float_salary_month_entry = FloatSalaryMonthEntry.where(year_month: year_month_date.month_range).first
      return nil if float_salary_month_entry.nil?
      BonusElementItem.where(user_id: user.id, float_salary_month_entry_id: float_salary_month_entry.id).first
    end

    # 当月浮动薪金原始数值
    def raw_bonus(user:, year_month_date:, bonus_key:, unit:, bonus_value_type: nil)
      bonus_element = BonusElement.find_by_key(bonus_key)

      if bonus_element.unit != unit
        return BigDecimal('0.0')
      end

      bonus_element_item = get_bonus_element_item(user, year_month_date)

      if bonus_element_item.nil?
        return BigDecimal('0.0')
      end

      # TODO (zhangmeng)： 处理是否是manager
      bonus_element_item_value = bonus_element_item
                                   .bonus_element_item_values
                                   .where(bonus_element_id: bonus_element.id)
                                   .first

      if bonus_element_item_value.nil?
        return BigDecimal('0.0')
      end

      if !bonus_value_type.nil? && bonus_element_item_value.value_type != bonus_value_type
        return BigDecimal('0.0')
      end

      case bonus_element_item_value.value_type
      when 'personal'
        bonus_element_item_value.amount.presence || BigDecimal(0)
      when 'departmental'
        (bonus_element_item_value.shares.presence || BigDecimal(0)) *
          (bonus_element_item_value.per_share.presence || BigDecimal(0))
      else
        BigDecimal('0.0')
      end
    end

  end
end
