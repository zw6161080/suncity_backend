# == Schema Information
#
# Table name: float_salary_month_entries
#
#  id              :integer          not null, primary key
#  year_month      :datetime
#  status          :string
#  employees_count :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class FloatSalaryMonthEntry < ApplicationRecord
  enum status: { not_approved: 'not_approved', approved: 'approved', generating: 'generating' }

  has_many :bonus_element_month_amounts, dependent: :destroy
  has_many :bonus_element_month_shares, dependent: :destroy
  has_many :bonus_element_items, dependent: :destroy
  has_many :location_department_statuses, dependent: :destroy
  has_many :location_statuses, dependent: :destroy

  def self.query(year_month)
    if year_month.nil?
      self.all
    else
      self.where("year_month >= :year_month_begin AND year_month <= :year_month_end", year_month_begin: year_month.beginning_of_month, year_month_end: year_month.end_of_month)
    end
  end

  def self.year_month_options
    self.all.select(:year_month).distinct.pluck(:year_month)
  end

  def self.approved_year_month_options
    self.where(status: :approved).select(:year_month).distinct.pluck(:year_month)
  end

  def self.exists_by_year_month?(year_month)
    date = year_month.is_a?(String) ? Time.zone.parse(year_month) : year_month
    self.where(year_month: date.beginning_of_month..date.end_of_month).exists?
  end

  def self.create_by_year_month(year_month)
    year_month = year_month.is_a?(String) ? Time.zone.parse(year_month).beginning_of_month : year_month.beginning_of_month
    fsm = FloatSalaryMonthEntry.create!(
      year_month: year_month,
      status: :generating,
    )
    GeneratingFloatSalaryMonthEntriesJob.perform_later(fsm)
    # GeneratingFloatSalaryMonthEntriesJob.perform_now(fsm)
    fsm
  end

  def update_per_shares_to_items
    bonus_elements = BonusElement.where.not(key: %w(dispatch_bonus recommend_new_guest_bonus))
    performance_bonus_item = bonus_elements.find_by(key: 'performance_bonus')
    kill_bonus_item = bonus_elements.find_by(key: 'kill_bonus')
    bonus_element_items = self.bonus_element_items.includes(:bonus_element_item_values)
    amounts = self.bonus_element_month_amounts
    bonus_element_items.each do |bonus_element_item|
      bonus_elements.each do |bonus_element|
        query_params = {
            location_id: bonus_element_item.location_id,
            department_id: bonus_element_item.department_id,
            bonus_element_id: bonus_element.id
        }
        # grade 1, 2 -> 总监
        level = ([1, 2].include? bonus_element_item.position.grade.to_i) ? 'manager' : 'ordinary' rescue 'ordinary'
        query_params = query_params.merge(level: level) if bonus_element.key == 'performance_bonus'
        if bonus_element.key == 'commission_margin'
          bonus_element.subtypes.each do |subtype|
            target = bonus_element_item.bonus_element_item_values.find_by(bonus_element_id: bonus_element.id, subtype: subtype)
            if target && target.departmental?
              amount = (amounts.find_by(query_params.merge(subtype: subtype)).amount rescue nil) || BigDecimal(0)
              shares = target.shares || BigDecimal(0)
              count_result = shares * amount
              target.update(per_share: amount, amount: count_result)
            end
          end
        elsif bonus_element.key == 'performance_bonus'
          target = bonus_element_item.bonus_element_item_values.find_by(bonus_element_id: bonus_element.id)
          if target && target.departmental?
            basic_salary =  target.basic_salary rescue BigDecimal(0)
            shares = target.shares || BigDecimal(0)
            amount = (amounts.find_by(query_params).amount rescue nil) || BigDecimal(0)
            count_result = shares * amount * basic_salary
            target.update(per_share: amount, amount: count_result)
          end
        else
          target = bonus_element_item.bonus_element_item_values.find_by(bonus_element_id: bonus_element.id)
          if target && target.departmental?
            amount = (amounts.find_by(query_params).amount rescue nil) || BigDecimal(0)
            shares = target.shares || BigDecimal(0)
            count_result = shares * amount
            target.update(per_share: amount, amount: count_result)
          end
        end
      end
      # 业绩分红 & 杀数分红 计算
      # 业绩分红
      performance_bonus = bonus_element_item.bonus_element_item_values.find_by(bonus_element_id: performance_bonus_item.id)
      performance_bonus_value = performance_bonus.amount
      # 杀数分红
      kill_bonus = bonus_element_item.bonus_element_item_values.find_by(bonus_element_id: kill_bonus_item.id)
      kill_bonus_value = kill_bonus.amount
      if (performance_bonus_value < 0 rescue false)
        # 當「業績分紅」為負數時，「業績分紅」=0；「殺數分紅」顯示為=「殺數分紅」+「業績分紅」；若最後殺數分紅的值小於0則按照0處理
        kill_bonus_value = kill_bonus_value + performance_bonus_value
        kill_bonus_value = BigDecimal(0) if kill_bonus_value < 0
        performance_bonus_value = BigDecimal(0)
        performance_bonus.update(amount: performance_bonus_value)
        kill_bonus.update(amount: kill_bonus_value)
        # 當「業績分紅」為非負數時，「業績分紅」與「殺數分紅」正常顯示
      end
    end
  end

  def create_bonus_element_items
    ymd = self.year_month.end_of_month
    bonus_element_settings = BonusElementSetting.all
    # 筛选符合条件的员工
    users = ProfileService.float_salary_month_entries_users(ymd).includes(:salary_records, :resignation_records)
    bonus_elements = BonusElement.all
    # 计算员工份数
    users.each do |user|
      # resigned_date
      # 员工离职日期
      resignation_record = user.resignation_records.where(resigned_date: ymd.month_range).last
      resigned_day = resignation_record.resigned_date.day rescue nil
      resigned_reason = resignation_record.resigned_reason rescue nil
      bonus_element_item = BonusElementItem.create(
          float_salary_month_entry_id: self.id,
          user_id: user.id,
          location_id: ProfileService.location(user, ymd)&.id,
          department_id: ProfileService.department(user, ymd)&.id,
          position_id: ProfileService.position(user, ymd)&.id
      )
      # 创建员工份数
      bonus_elements.each do |bonus_element|
        setting = bonus_element_settings.find_by(location_id: bonus_element_item.location_id, department_id: bonus_element_item.department_id, bonus_element_id: bonus_element.id)
        value_type = setting.value rescue 'personal'
        shares = SalaryCalculatorService._calc_salary_element_raw(user, ymd, bonus_element_key_transfer(bonus_element.key))
        is_personal = setting.personal? rescue true
        # 薪金项为个人制 不进行计算 => 0
        shares = nil if is_personal
        # 不是当月最后一天离职
        shares = 0 if (resigned_day && (resigned_day != ymd.day))
        # 离职类别 为 '中止雇佣' 浮动薪金项目为 '特别茶资' 当月最后一天离职
        shares = 0 if ((bonus_element.key == 'special_cover_charge') && (resigned_reason == 'termination'))
        if bonus_element.key == 'commission_margin'
          bonus_element.subtypes.each do |subtype|
            bonus_element_item.bonus_element_item_values.create(bonus_element_id: bonus_element.id, shares: shares, value_type: value_type, subtype: subtype)
          end
        elsif bonus_element.key == 'performance_bonus'
          basic_salary = SalaryCalculatorService._calc_salary_element_raw(user, ymd, :final_basic_salary)
          bonus_element_item.bonus_element_item_values.create(bonus_element_id: bonus_element.id, shares: shares, value_type: value_type, basic_salary: basic_salary)
        else
          bonus_element_item.bonus_element_item_values.create(bonus_element_id: bonus_element.id, shares: shares, value_type: value_type)
        end
      end
    end
  end

  def create_bonus_element_month_shares_and_amounts
    bonus_element = BonusElement.where.not(key: %w(dispatch_bonus recommend_new_guest_bonus))
    bonus_element_settings = BonusElementSetting.all
    bonus_element_item_values = BonusElementItemValue.where(bonus_element_item_id: self.bonus_element_items.select(:id)).joins(:bonus_element_item)
    Location.includes(:departments).each do |location|
      location.departments.where.not(id: 1).each do |department|
        query_values_by_l_d = bonus_element_item_values.where(:bonus_element_items => { location_id: location.id, department_id: department.id })
        bonus_element.each do |bonus_element|
          setting = bonus_element_settings.find_by(location_id: location.id, department_id: department.id, bonus_element_id: bonus_element.id)
          is_departmental = setting.departmental? rescue false
          # shares = query_values_by_l_d.where(bonus_element_id: bonus_element.id).where.not(subtype: 'business_development').sum(:shares)
          shares = query_values_by_l_d.where(bonus_element_id: bonus_element.id).sum(:shares)
          # 去除掉一份佣金差额份数
          if bonus_element.key == 'commission_margin'
            shares /= BigDecimal(2) rescue BigDecimal(0)
          end
          create_params = {
              float_salary_month_entry_id: self.id,
              location_id: location.id,
              department_id: department.id,
              bonus_element_id: bonus_element.id
            }
          # 创建部门份数 -> 个人制时不创建
          self.bonus_element_month_shares.find_or_create_by(create_params.merge(shares: shares)) if is_departmental
          # 创建部门基数 -> 个人制时不创建
          if bonus_element.levels.nil?
            if bonus_element.subtypes.nil?
              # 普遍情况
              self.bonus_element_month_amounts.find_or_create_by(create_params.merge(amount: nil)) if is_departmental
            else
              # 存在sub_types
              bonus_element.subtypes.each do |subtype|
                self.bonus_element_month_amounts.find_or_create_by(create_params.merge({ amount: nil, subtype: subtype })) if is_departmental
              end
            end
          else
            # 存在levels
            bonus_element.levels.each do |level|
              self.bonus_element_month_amounts.find_or_create_by(create_params.merge({ amount: nil, level: level })) if is_departmental
            end
          end
        end
      end
    end
  end

  # def create_bonus_element_month_values
  #   all_setting = BonusElementSetting.all
  #   BonusElement.all.each do |element|
  #     element_setting = all_setting.where(bonus_element_id: element.id)
  #     Location.includes(:departments).list.each do |location|
  #       loc = location
  #       location_setting = element_setting.where(location_id: loc.id)
  #       location.departments.without_suncity_department.each do |dep|
  #         setting = location_setting
  #                     .where(department_id: dep.id)
  #                     .first
  #         if setting.departmental?
  #           create_departmental_month_values(
  #             location_id: loc.id,
  #             department_id: dep.id,
  #             bonus_element: element)
  #         end
  #       end
  #     end
  #   end
  # end

  private
  def bonus_element_key_transfer(key)
    {
        cover_charge: :final_tea_bonus, # 茶資
        kill_bonus: :final_kill_bonus, # 殺數分紅
        performance_bonus: :final_performance_bonus, # 業績分紅
        swiping_card_bonus: :final_charge_bonus, # 刷卡獎金
        commission_margin: :final_commission_bonus, # 傭金差額
        collect_accounts_bonus: :final_receive_bonus, # 收賬分紅
        exchange_rate_bonus: :final_exchange_rate_bonus, # 匯率分紅
        vip_card_bonus: :final_guest_card_bonus, # 貴賓卡消費
        zunhuadian: :final_respect_bonus, # 尊華殿
        xinchunlishi: :final_new_year_bonus, # 新春利是
        project_bonus: :final_project_bonus, # 項目分紅
        shangpin_bonus: :final_product_bonus, # 尚品獎金
        performance_award: :final_performance_award, # 績效獎金
        special_cover_charge: :final_special_tie_bonus, # 特別茶資
        dispatch_bonus: :dispatch_bonus, # 出車獎金
        recommend_new_guest_bonus: :recommand_new_guest_bonus, # 介紹新客戶轉碼分紅
    }[key.to_sym]
  end

  # def create_departmental_month_values(location_id:, department_id:, bonus_element:)
  #   # shares = User.where(id: ProfileService.users1(self.year_month).ids - ProfileService.users2(self.year_month).ids - ProfileService.users3(self.year_month).ids + ProfileService.users5(self.year_month).ids )
  #   shares = ProfileService.float_salary_month_entries_users(self.year_month)
  #                .where(location_id: location_id)
  #                .where(department_id: department_id)
  #                .inject(BigDecimal('0')) do |sum, u|
  #     sum + SalaryCalculationService.raw_bonus_shares_in_date(u, self.year_month, bonus_element.key)
  #   end
  #
  #   share_params = {
  #     location_id: location_id,
  #     department_id: department_id,
  #     float_salary_month_entry_id: self.id,
  #     bonus_element_id: bonus_element.id
  #   }
  #   BonusElementMonthShare.where(share_params).first_or_create(share_params).update(shares: shares)
  #
  #   if bonus_element.levels.nil?
  #     if bonus_element.subtypes.nil?
  #       # 最普通情况，不区分级别、不区分子类别（例如：市场拓展部门、运营）
  #       amount_params = {
  #         location_id: location_id,
  #         department_id: department_id,
  #         float_salary_month_entry_id: self.id,
  #         bonus_element_id: bonus_element.id
  #       }
  #       BonusElementMonthAmount.where(amount_params).first_or_create(amount_params)
  #     else
  #       # 不区分级别、区分子类别（例如：市场拓展部门、运营）
  #       bonus_element.subtypes.each do |subtype|
  #         amount_params = {
  #           location_id: location_id,
  #           department_id: department_id,
  #           float_salary_month_entry_id: self.id,
  #           bonus_element_id: bonus_element.id,
  #           subtype: subtype
  #         }
  #         BonusElementMonthAmount.where(amount_params).first_or_create(amount_params)
  #       end
  #     end
  #   else
  #     bonus_element.levels.each do |level|
  #       if bonus_element.subtypes.nil?
  #         # 区分级别、不区分子类别（例如：市场拓展部门、运营）
  #         amount_level_params = {
  #           location_id: location_id,
  #           department_id: department_id,
  #           float_salary_month_entry_id: self.id,
  #           bonus_element_id: bonus_element.id,
  #           level: level
  #         }
  #         BonusElementMonthAmount.where(amount_level_params).first_or_create(amount_level_params)
  #       else
  #         bonus_element.subtypes.each do |subtype|
  #           # 区分级别、区分子类别（例如：市场拓展部门、运营）
  #           amount_params = {
  #             location_id: location_id,
  #             department_id: department_id,
  #             float_salary_month_entry_id: self.id,
  #             bonus_element_id: bonus_element.id,
  #             subtype: subtype,
  #             level: level
  #           }
  #           BonusElementMonthAmount.where(amount_params).first_or_create(amount_params)
  #         end
  #       end
  #     end
  #   end
  # end
end
