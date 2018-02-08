module SalaryCalculation
  module RawSalary

    # 薪酬信息的KEYS
    def all_salary_keys_table
      {
        basic_salary: :base_salary,      # 基本工资
        bonus: :benefits,                # 津贴
        attendance_award: :incentive,    # 勤工
        # house_bonus: :housing_benefits,  # 房屋津贴
      }
    end

    # 獎金信息的KEYS
    def all_salary_bonus_keys_table
      {
        cover_charge: :tea_bonus,           # 茶資
        kill_bonus: :kill_bonus,          # 殺數分紅
        performance_bonus: :performance_bonus,   # 業績分紅
        swiping_card_bonus: :charge_bonus,        # 刷卡獎金
        commission_margin: :commission_bonus,    # 傭金差額
        collect_accounts_bonus: :receive_bonus,       # 收賬分紅
        exchange_rate_bonus: :exchange_rate_bonus, # 匯率分紅
        vip_card_bonus: :guest_card_bonus,    # 貴賓卡消費
        zunhuadian: :respect_bonus,       # 尊華殿
        xinchunlishi: :new_year_bonus,      # 新春利是
        project_bonus: :project_bonus,       # 項目分紅
        shangpin_bonus: :product_bonus,       # 尚品獎金
      }
    end

    # 员工薪酬信息
    def raw_salary_in_date(user, date, salary_key, unit)
      return BigDecimal('0') unless salary_key.to_sym.in? all_salary_keys_table.keys
      salary_key = salary_key.to_s

      # 找到包含參數日期的薪酬歷史
      salary = (user.profile.fetch_salary_history_section_rows.presence || []).find do |item|
        begin_date = Time.zone.parse(item['salary_start_date']).beginning_of_day rescue nil
        end_date = Time.zone.parse(item['salary_end_date']).end_of_day rescue nil

        if begin_date.nil? && end_date.nil?
          false
        elsif end_date.nil?
          begin_date <= date.in_time_zone
        else
          date.in_time_zone === (begin_date..end_date)
        end
      end

      if salary.nil? ||
        salary[salary_key].nil? ||
        salary["#{salary_key}_unit"].nil? ||
        salary["#{salary_key}_unit"] != unit
        BigDecimal('0.0')
      else
        BigDecimal(salary[salary_key])
      end
    end

    def raw_bonus_shares_in_date(user, date, salary_bonus_key)
      return BigDecimal('0') unless salary_bonus_key.to_sym.in? all_salary_bonus_keys_table.keys
      salary_key = all_salary_bonus_keys_table.with_indifferent_access[salary_bonus_key].to_s

      if (ProfileService.employees_left_this_month(date).include? user.id) &&
        (!ProfileService.employees_left_last_day_this_month(date).include? user.id)
        return BigDecimal('0')
      end

      # 找到包含參數日期的薪酬歷史
      begin_date = date.beginning_of_month
      end_date = date.end_of_month
      query = user.salary_records.where(
        "(salary_end > :begin_date OR salary_end is null )  AND salary_begin < :end_date", begin_date: begin_date, end_date: end_date
      ).order(salary_begin: :desc)

      if query.count == 1
        ActiveModelSerializers::SerializableResource.new(query.first).serializer_instance.send('final_' + salary_key)
      else
        query.inject(BigDecimal(0)) do |sum, salary_record|
          value = ActiveModelSerializers::SerializableResource.new(salary_record).serializer_instance.send('final_' + salary_key)
          salary_begin_date = [begin_date, salary_record.salary_begin].max
          salary_end_date = [end_date, salary_record.salary_end&.end_of_day].compact.min
          sum + value / BigDecimal("30.0") * ((salary_end_date - salary_begin_date) / 1.day).round
        end
      end
    end

  end
end
