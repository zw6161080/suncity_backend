class SalaryCalculatorService
  class << self
    #0:status
    def calc_salary_status(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = 'not_granted'
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 1 員工編號
    def calc_employee_number(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = user.empoid
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 2 員工姓名
    def calc_employee_name(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = user.as_json
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 3 年度
    def calc_year(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = month_salary_report.year_month.beginning_of_year
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 4 月份
    def calc_month(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = month_salary_report.year_month.beginning_of_month
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 5 公司名稱
    def calc_company_name(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        year_month_day = salary_type.to_sym == :on_duty ? month_salary_report.year_month.end_of_month.beginning_of_day : ResignationRecord.find(resignation_record_id).resigned_date
        re = ProfileService.company_name(user, year_month_day).as_json
        re = Config.get_all_option_from_selects(:company_name).find { |item| item['key'] == re }
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 6 場館
    def calc_location(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        year_month_day = salary_type.to_sym == :on_duty ? month_salary_report.year_month.end_of_month.beginning_of_day : ResignationRecord.find(resignation_record_id).resigned_date
        re = ProfileService.location(user, year_month_day).as_json
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 7 部門
    def calc_department(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        year_month_day = salary_type.to_sym == :on_duty ? month_salary_report.year_month.end_of_month.beginning_of_day : ResignationRecord.find(resignation_record_id).resigned_date
        re = ProfileService.department(user, year_month_day).as_json
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 8 職位
    def calc_position(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        year_month_day = salary_type.to_sym == :on_duty ? month_salary_report.year_month.end_of_month.beginning_of_day : ResignationRecord.find(resignation_record_id).resigned_date
        re = ProfileService.position(user, year_month_day).as_json
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 9 職級
    def calc_grade(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        year_month_day = salary_type.to_sym == :on_duty ? month_salary_report.year_month.end_of_month.beginning_of_day : ResignationRecord.find(resignation_record_id).resigned_date
        re = ProfileService.grade(user, year_month_day).as_json
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 10 漏打卡上班（次）：「考勤月報」中讀取「簽卡漏打卡上班次數」
    def calc_unaccounted_clock_in_times(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('signcard_forget_to_punch_in_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 11 漏打卡下班（次）：「考勤月報」中讀取「簽卡漏打卡下班次數」
    def calc_unaccounted_clock_out_times(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('signcard_forget_to_punch_out_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 12 年假剩餘天數：計算截止到「161薪酬結束日期」剩餘年假的天數
    def calc_annual_leave_balance(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = HolidayRecord.calc_remaining(user, 'annual_leave', month_salary_report.year_month.end_of_month)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 13 有薪病假剩餘天數：計算截止到「161薪酬結束日期」剩餘有薪病假的天數
    def calc_sick_leave_balance(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = HolidayRecord.calc_remaining(user, 'paid_sick_leave', month_salary_report.year_month.end_of_month)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 14 強制性假期天數（補薪）：「考勤月報」中讀取「強制性假日補錢天數」
    def calc_mandatory_holiday_days_compensation_salary(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('force_holiday_for_money_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 15 強制性假期天數（補假）：「考勤月報」中讀取「強制性假日補假天數」
    def calc_mandatory_holiday_days_compensation_leave(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('force_holiday_for_leave_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 16 公眾假期天數（補薪）：「考勤月報」中讀取「公眾假日補薪天數」
    def calc_public_holiday_days_compensation_salary(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('public_holiday_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 17 曠工天數：「考勤月報」中讀取「遲到超過120次數」＋「曠工天數」+「考勤異常導致曠工天數」
    def calc_absenteeism_days(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('absenteeism_counts + late_mins_more_than_120 + absenteeism_from_exception_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 18 無薪假天數：「考勤月報」中讀取「無薪假天數」＋「無薪病假天數」
    def calc_no_pay_leave_days(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('unpaid_leave_counts + unpaid_sick_leave_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 19 即告天數：「考勤月報」中讀取「即告天數」
    def calc_same_day_leave_days(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('immediate_leave_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 20 無薪婚假天數：「考勤月報」中讀取「無薪婚假天數」
    def calc_marriage_leave_without_pay_days(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('unpaid_marriage_leave_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 21 無薪恩恤假天數：「考勤月報」中讀取「無薪恩恤假天數」
    def calc_unpaid_compassionate_leave_days(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('unpaid_compassionate_leave_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 22 懷孕病假天數：「考勤月報」中讀取「懷孕病假天數」
    def calc_pregnant_sick_leave_days(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('pregnant_sick_leave_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re) || BigDecimal(0)
      end
    end

    # id: 23 有薪病假不連off天數：「考勤月報」中讀取「病假不連off天數」
    def calc_paid_discountinous_sick_days(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('sick_leave_counts_link_off')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 24 有薪病假連off天數：「考勤月報」中讀取「病假連off天數天數」
    def calc_paid_continuous_sick_days(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('sick_leave_counts_not_link_off')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 25 無薪分娩假天數：「考勤月報」中讀取「無薪分娩假天數」
    def calc_maternity_leave_without_pay_days(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('unpaid_maternity_leave_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 26 有薪分娩假天數：「考勤月報」中讀取「有薪分娩假天數」
    def calc_paid_maternity_leave_days(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('paid_maternity_leave_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 27 工傷天數（首7天）：「考勤月報」中讀取「工傷(首7天)天數」
    def calc_work_injury_days_first_7_days(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('work_injury_before_7_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 28 工傷天數（7天後）：「考勤月報」中讀取「工傷(7天後)天數」
    def calc_work_injury_days_7_days_later(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('work_injury_after_7_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 29 停薪留職天數：「考勤月報」中讀取「停薪留職天數」
    def calc_leave_without_pay_days(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('unpaid_but_maintain_position_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 30 遲到次數（小於等於10）：「考勤月報」中讀取「遲到小於10次數」
    def calc_late_times_less_than_or_equal_to_10(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('late_mins_less_than_10')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 31 遲到次數（小於等於20）：「考勤月報」中讀取「遲到小於20次數」
    def calc_late_times_less_than_or_equal_to_20(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('late_mins_less_than_20')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 32 遲到次數（小於等於30）：「考勤月報」中讀取「遲到小於30次數」
    def calc_late_times_less_than_or_equal_to_30(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('late_mins_less_than_20')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 33 遲到次數（大於30）：「考勤月報」中讀取「遲到大於30次數」
    def calc_late_times_greater_than_30(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('late_mins_less_than_30')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 34 平日加班時數：「考勤月報」中讀取「平日加班時數」＋「車務部加班分鐘」(換算成小時，餘數不超過半小時捨去，超過半小時進一位)
    def calc_weekdays_overtime_hours(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('weekdays_overtime_hours + round(vehicle_department_overtime_mins / 60)')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 35  假日加班時數：「考勤月報」中讀取「公休加班時數」＋「強制性假日加班時數」＋「公眾假日加班時數」
    def calc_holiday_overtime_hours(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('general_holiday_overtime_hours + force_holiday_overtime_hours + public_holiday_overtime_hours')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 36 颱風上班天數：「考勤月報」中讀取「颱風津貼次數」
    def calc_typhoon_work_days(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        calculator = load_attend_days_to_calculator_store(user, month_salary_report)
        re = calculator.evaluate('typhoon_allowance_counts')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 37 原底薪：計算「160薪酬開始日期」的「底薪」；讀取自「薪酬歷史」
    def calc_original_basic_salary(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_basic_salary, resignation_record_id)
    end

    #id: 38 現底薪：計算「161薪酬結束日期」的「底薪」；讀取自「薪酬歷史」
    def calc_present_basic_salary(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_basic_salary, resignation_record_id)
    end

    #id: 39 底薪：＝「底薪1」＊「底薪1的天數/30」＋「底薪2」＊「底薪2的天數/30」
    def calc_basic_salary(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      re = _calc_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_basic_salary, resignation_record_id) || BigDecimal(0)
      re
    end

    #id: 40 原津貼：計算「160薪酬開始日期」的「津貼」；讀取自「薪酬歷史」
    def calc_original_allowance(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_bonus, resignation_record_id)
    end

    #id: 41 現津貼：計算「161薪酬結束日期」的「津貼」；讀取自「薪酬歷史」；
    def calc_present_allowance(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_bonus, resignation_record_id)
    end

    #id: 42 津貼：＝「津貼1」＊「津貼1的天數/30」＋「津貼2」＊「津貼2的天數/30
    def calc_allowance(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      re = _calc_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_bonus, resignation_record_id)
      re
    end

    #id: 43 原勤工：計算「160薪酬開始日期」的「勤工」；讀取自「薪酬歷史」；
    def calc_original_attendance_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_attendance_award, resignation_record_id)
    end

    #id: 44 現勤工：計算「161薪酬結束日期」的「勤工」；讀取自「薪酬歷史」；
    def calc_present_attendance_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_attendance_award, resignation_record_id)
    end

    #id: 45 勤工：＝「勤工1」＊「勤工1的天數/30」＋「勤工2」＊「勤工2的天數/30」
    def calc_attendance_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      re = _calc_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_attendance_award, resignation_record_id)
      re
    end

    #id: 46 原房屋津貼：計算「160薪酬開始日期」的「房屋津貼」；讀取自「薪酬歷史」；
    def calc_original_housing_allowance(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_house_bonus, resignation_record_id)
    end

    #id: 47 現房屋津貼：計算「161薪酬結束日期」的「房屋津貼」；讀取自「薪酬歷史」；
    def calc_present_housing_allowance(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_house_bonus, resignation_record_id)
    end

    #id: 48 房屋津貼：＝「房屋津貼1」＊「房屋津貼1的天數/30」＋「房屋津貼2」＊「房屋津貼2的天數/30」
    def calc_housing_allowance(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      re = _calc_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_house_bonus, resignation_record_id)
      re
    end

    #id: 49 原地區津貼：計算「160薪酬開始日期」的「地區津貼」；讀取自「薪酬歷史」；
    def calc_original_regional_allowance(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_region_bonus, resignation_record_id)
    end

    #id: 50 現地區津貼：計算「161薪酬結束日期」的「地區津貼」；讀取自「薪酬歷史」；
    def calc_present_regional_allowance(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_region_bonus, resignation_record_id)
    end

    #id: 51 地區津貼：＝「地區津貼1」＊「地區津貼1的天數/30」＋「地區津貼2」＊「地區津貼2的天數/30」
    def calc_regional_allowance(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      re = _calc_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_region_bonus, resignation_record_id)
      re
    end

    #id: 219 原服務獎金：計算「160薪酬開始日期」的「服務獎金」；讀取自「薪酬歷史」
    def calc_original_service_award(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_service_award, resignation_record_id)
    end
    #id: 220 現服務獎金：計算「161薪酬結束日期」的「服務獎金」；讀取自「薪酬歷史」
    def calc_present_service_award(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_service_award, resignation_record_id)
    end
    #id: 221 服務獎金：＝「服務獎金1」＊「服務獎金1的天數/30」＋「服務獎金2」＊「服務獎金2的天數/30」
    def calc_service_award(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      re = _calc_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_service_award, resignation_record_id)
      re
    end
    #id: 222 原實習津貼
    def calc_original_internship_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_internship_bonus, resignation_record_id)
    end
    #id: 223 現實習津貼
    def calc_present_internship_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_internship_bonus, resignation_record_id)
    end
    #id: 224 實習津貼
    def calc_internship_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      re = _calc_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_internship_bonus, resignation_record_id)
      re
    end
    #id: 52 原茶資份數
    def calc_original_tips(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_tea_bonus, resignation_record_id)
    end

    #id: 53 現茶資份數
    def calc_present_tips(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_tea_bonus, resignation_record_id)
    end

    #id: 54 茶資份數
    def calc_tips(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      re = _calc_bonus_element_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, :cover_charge, resignation_record_id)
      re
    end

    #id: 55 每份茶資
    def calc_each_tips_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_per_share(user, month_salary_report, salary_type, salary_column_id, key, value_type, :cover_charge, resignation_record_id)
    end

    #id: 56 茶資
    def calc_tips_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, :cover_charge, resignation_record_id)
    end

    #id: 57 原佣金差額份數
    def calc_original_comission_copies(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_commission_bonus, resignation_record_id)
    end

    #id: 58 現佣金差額份數
    def calc_present_commission_copies(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_commission_bonus, resignation_record_id)
    end

    #id: 59 佣金差額份數
    def calc_commission_copies(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, :commission_margin, resignation_record_id)
    end

    #id: 60 每份市場拓展部佣金差額
    def calc_each_market_planning_department_commission(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re =_get_bonus_per_share(user, month_salary_report, 'commission_margin', 'business_development')
        re = re.nil? ? BigDecimal(0) : re
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 61 市場拓展部佣金差額
    def calc_market_planning_department_commission(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(60, user, month_salary_report, salary_type, resignation_record_id) *
            find_or_create_by(59, user, month_salary_report, salary_type, resignation_record_id) rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 62 每份營運佣金差額
    def calc_each_operating_commission(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = _get_bonus_per_share(user, month_salary_report, 'commission_margin', 'operation')
        re = re.nil? ? BigDecimal(0) : re
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 63 營運佣金差額
    def calc_operating_commission(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(62, user, month_salary_report, salary_type, resignation_record_id) *
            find_or_create_by(59, user, month_salary_report, salary_type, resignation_record_id) rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 64 佣金差額
    def calc_commission(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(61, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(63, user, month_salary_report, salary_type, resignation_record_id) rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 65 原殺數分紅份數
    def calc_original_win_lose(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_kill_bonus, resignation_record_id)
    end

    #id: 66 現殺數分紅份數
    def calc_present_win_lose(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_kill_bonus, resignation_record_id)
    end

    #id: 67 殺數分紅份數
    def calc_win_lose(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, :kill_bonus, resignation_record_id)
    end

    #id: 68 每份殺數分紅
    def calc_each_win_lose_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_per_share(user, month_salary_report, salary_type, salary_column_id, key, value_type, :kill_bonus, resignation_record_id)
    end

    #id: 69 殺數分紅
    def calc_win_lose_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, :kill_bonus, resignation_record_id)
    end

    #id: 70 原業績分紅份數
    def calc_original_rolling(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_performance_bonus, resignation_record_id)
    end

    #id: 71 現業績分紅份數
    def calc_present_rolling(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_performance_bonus, resignation_record_id)
    end

    #id: 72 業績分紅份數
    def calc_rolling(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, :performance_bonus, resignation_record_id)
    end

    #id: 73 業績分紅百分比
    def calc_percentage_of_rolling_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_per_share(user, month_salary_report, salary_type, salary_column_id, key, value_type, :performance_bonus, resignation_record_id)
    end

    #id: 74 業績分紅
    def calc_rolling_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, :performance_bonus, resignation_record_id)
    end

    #id: 75 原刷卡獎金份數
    def calc_original_credit_card_commission(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_charge_bonus, resignation_record_id)
    end

    #id: 76 現刷卡獎金份數
    def calc_present_credit_card_commission(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_charge_bonus, resignation_record_id)
    end

    #id: 77 刷卡獎金份數
    def calc_credit_card_commission(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, :swiping_card_bonus, resignation_record_id)
    end

    #id: 78 每份刷卡獎金
    def calc_each_union_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_per_share(user, month_salary_report, salary_type, salary_column_id, key, value_type, :swiping_card_bonus, resignation_record_id)
    end

    #id: 79 刷卡獎金
    def calc_union_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, :swiping_card_bonus, resignation_record_id)
    end

    #id: 80 原貴賓卡消費份數
    def calc_original_card_sales(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_guest_card_bonus, resignation_record_id)
    end

    #id: 81 現貴賓卡消費份數
    def calc_present_card_sales(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_guest_card_bonus, resignation_record_id)
    end

    #id: 82 貴賓卡消費份數
    def calc_card_sales(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, :vip_card_bonus, resignation_record_id)
    end

    #id: 83 每份貴賓卡消費
    def calc_each_btm_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_per_share(user, month_salary_report, salary_type, salary_column_id, key, value_type, :vip_card_bonus, resignation_record_id)
    end

    #id: 84 貴賓卡消費
    def calc_btm_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, :vip_card_bonus, resignation_record_id)
    end

    #id: 85 原收賬分紅份數
    def calc_original_debtors(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_receive_bonus, resignation_record_id)
    end

    #id: 86 現收賬分紅份數
    def calc_present_debtors(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_receive_bonus, resignation_record_id)
    end

    #id: 87 收賬分紅份數
    def calc_debtors(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, :collect_accounts_bonus, resignation_record_id)
    end

    #id: 88 每份收賬分紅
    def calc_each_receivavle_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_per_share(user, month_salary_report, salary_type, salary_column_id, key, value_type, :collect_accounts_bonus, resignation_record_id)
    end

    #id: 89 收賬分紅
    def calc_receivable_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, :collect_accounts_bonus, resignation_record_id)
    end

    #id: 90 原匯率分紅份數
    def calc_original_commission_difference(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      # 翻译有问题，此处是汇率分红
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_exchange_rate_bonus, resignation_record_id)
    end

    #id: 91 現匯率分紅份數
    def calc_present_commission_difference(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      # 翻译有问题，此处是汇率分红
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_exchange_rate_bonus, resignation_record_id)
    end

    #id: 92 匯率分紅份數
    def calc_commission_difference(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, :exchange_rate_bonus, resignation_record_id)
    end

    #id: 93 每份匯率分紅
    def calc_each_exchange_rate_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_per_share(user, month_salary_report, salary_type, salary_column_id, key, value_type, :exchange_rate_bonus, resignation_record_id)
    end

    #id: 94 匯率分紅
    def calc_exchange_rate_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, :exchange_rate_bonus, resignation_record_id)
    end

    #id: 95 原項目分紅份數
    def calc_original_project(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_project_bonus, resignation_record_id)
    end

    #id: 96 現項目分紅份數
    def calc_present_project(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_project_bonus, resignation_record_id)
    end

    #id: 97 项目分紅份數
    def calc_project_copies(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, :project_bonus, resignation_record_id)
    end

    #id: 98 每份項目分紅
    def calc_each_project_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_per_share(user, month_salary_report, salary_type, salary_column_id, key, value_type, :project_bonus, resignation_record_id)
    end

    #id: 99 项目分紅
    def calc_project_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, :project_bonus, resignation_record_id)
    end

    #id: 100 原尊華殿份數
    def calc_orignal_e_mall(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_respect_bonus, resignation_record_id)
    end

    #id: 101 現尊華殿份數
    def calc_present_e_mall(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_respect_bonus, resignation_record_id)
    end

    #id: 102 尊華殿份數
    def calc_e_mall(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, :zunhuadian, resignation_record_id)
    end

    #id: 103 每份尊華殿
    def calc_each_e_mall_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_per_share(user, month_salary_report, salary_type, salary_column_id, key, value_type, :zunhuadian, resignation_record_id)
    end

    #id: 104 尊華殿
    def calc_e_mall_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, :zunhuadian, resignation_record_id)
    end

    #id: 105 原尚品獎金份數
    def calc_original_luxe(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_product_bonus, resignation_record_id)
    end

    #id: 106 現尚品獎金份數
    def calc_present_luxe(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_product_bonus, resignation_record_id)
    end

    #id: 107 尚品獎金份數
    def calc_luxe_copies(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, :shangpin_bonus, resignation_record_id)
    end

    #id: 108 每份尚品獎金
    def calc_each_luxe_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_per_share(user, month_salary_report, salary_type, salary_column_id, key, value_type, :shangpin_bonus, resignation_record_id)
    end

    #id: 109 尚品獎金
    def calc_luxe(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, :shangpin_bonus, resignation_record_id)
    end

    #id: 110 出車獎金
    def calc_incentive_on_driving(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, :dispatch_bonus, resignation_record_id)
    end

    #id: 111 介紹新客戶轉碼分紅
    def calc_referral_bonus_on_rolling(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, :recommend_new_guest_bonus, resignation_record_id)
    end

    #id: 112 原新春利是份數
    def calc_orignal_new_year_lai_see(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_new_year_bonus, resignation_record_id)
    end

    #id: 113 現新春利是份數
    def calc_present_new_year_lai_see(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_new_year_bonus, resignation_record_id)
    end

    #id: 114 新春利是份數
    def calc_new_year_lai_see(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, :xinchunlishi, resignation_record_id)
    end

    #id: 115 每份新春利是
    def calc_each_new_year_lai_see_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_per_share(user, month_salary_report, salary_type, salary_column_id, key, value_type, :xinchunlishi, resignation_record_id)
    end

    #id: 116 新春利是
    def calc_new_year_lai_see_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, :xinchunlishi, resignation_record_id)
    end

    #id: 225 原績效獎金份數
    def calc_original_performance_award(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_performance_award, resignation_record_id)
    end

    #id: 226 現績效獎金份數
    def calc_present_performance_award(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_performance_award, resignation_record_id)
    end

    #id: 227 績效獎金份數
    def calc_performance_award(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, :performance_award, resignation_record_id)
    end

    #id: 228 每份績效獎金
    def calc_each_performance_award(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_per_share(user, month_salary_report, salary_type, salary_column_id, key, value_type, :performance_award, resignation_record_id)
    end

    #id: 229 績效獎金
    def calc_performance_award_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, :performance_award, resignation_record_id)
    end

    #id: 230 原特別茶資份數
    def calc_orignal_special_tie(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_special_tie_bonus, resignation_record_id)
    end

    #id: 231 現特別茶資份數
    def calc_present_special_tie(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, :final_special_tie_bonus, resignation_record_id)
    end

    #id: 232 特別茶資份數
    def calc_special_tie(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, :special_cover_charge, resignation_record_id)
    end

    #id: 233 每份特別茶資
    def calc_each_special_tie_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_per_share(user, month_salary_report, salary_type, salary_column_id, key, value_type, :special_cover_charge, resignation_record_id)
    end

    #id: 234 特別茶資
    def calc_special_tie_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, :special_cover_charge, resignation_record_id)
    end

    #id: 117 上年度12月底薪：自動讀取上一年度「全部薪酬」中的12月底薪；讀取員工檔案的薪酬歷史，需要按照比例來計算
    def calc_december_basic_salary_in_last_year(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        year_month = month_salary_report.year_month - 1.year
        re = _calc_salary_element_raw(user, year_month.end_of_year, :final_basic_salary)
        re = re.nil? ? BigDecimal(0) : re
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 118 上年度12月津貼：自動讀取上一年度「全部薪酬」中的12月津貼
    def calc_december_allowance_in_last_year(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        year_month = month_salary_report.year_month - 1.year
        re = _calc_salary_element_raw(user, year_month.end_of_year, :final_bonus)
        re = re.nil? ? BigDecimal(0) : re
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 119 上年度12月勤工：自動讀取上一年度「全部薪酬」中的12月勤工
    def calc_december_allowance_bonus_in_last_year(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        year_month = month_salary_report.year_month - 1.year
        re = _calc_salary_element_raw(user, year_month.end_of_year, :final_attendance_award)
        re = re.nil? ? BigDecimal(0) : re
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 120  是否享有雙糧
    def calc_have_double_pay(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:add_double_pay)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 121 雙糧
    def calc_double_pay(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:double_pay_hkd)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 122 雙糧調整
    def calc_adjust_double_pay(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:double_pay_alter_hkd)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 123 雙糧實發
    def calc_really_issued_double_pay(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:double_pay_final_hkd)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 124 是否享有花紅
    def calc_have_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:add_end_bonus)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 125 花紅應發
    def calc_should_pay_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:end_bonus_hkd)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 126 表揚信次數
    def calc_praise_letters_number(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:praise_times)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 127 花紅總增加
    def calc_bonus_total_add(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:end_bonus_add_hkd)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 128 全年曠工次數
    def calc_absences_without_official_leave_times_yearly(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:absence_times)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 129 全年即告次數
    def calc_same_day_leave_times_yearly(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:notice_times)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 130 全年遲到次數
    def calc_lateness_times_yearly(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:late_times)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 131 全年漏打卡上班次數
    def calc_unaccounted_clock_in_out_times_yearly(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:lack_sign_card_times)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 132 處罰通知書次數
    def calc_disposition_notice_times(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:punishment_times)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 133 扣減花紅_曠工
    def calc_deduct_bonus_absences_without_offical_leave(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:de_end_bonus_for_absence_hkd)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 134 扣減花紅_即告
    def calc_deduct_bonus_same_day_leave(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:de_bonus_for_notice_hkd)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 135 扣減花紅_遲到
    def calc_deduct_bonus_lateness(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:de_end_bonus_for_late_hkd)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 136 扣減花紅_漏打卡上下班
    def calc_deduct_bonus_unaccounted_clock_in_out(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:de_end_bonus_for_sign_card_hkd)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 137  扣減花紅_處罰通知書
    def calc_deduct_bonus_disposition_notice(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:de_end_bonus_for_punishment_hkd)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 138 花紅總扣減
    def calc_total_deduct_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:de_bonus_total_hkd)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 139 花紅實發
    def calc_really_issued_bonus(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:end_bonus_final_hkd)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 140 上年度是否全勤
    def calc_annual_attendance_last_year(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:present_at_duty_first_half)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 141 全年勤工基數
    def calc_year_round_work_base(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:annual_at_duty_basic_hkd)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 142 全年勤工實發
    def calc_really_issued_annual_attendance(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = get_annual_award_report_item(user, month_salary_report).try(:annual_at_duty_final_hkd)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 143 薪酬月份：自動顯示對應工資的月份；
    def calc_salary_month(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = month_salary_report.year_month
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 144 薪酬開始日期：若當月入職則顯示入職日期，若非當日入職則顯示當月1日；
    def calc_salary_start_date(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        entry_date = user.career_records.minimum(:career_begin)
        month_begin = month_salary_report.year_month.beginning_of_month
        re = entry_date <= month_begin ? month_begin : entry_date
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 145 薪酬結束日期：若當月離職則顯示最後僱用日期，若非當日離職則顯示當月31日；
    def calc_salary_end_date(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        resigned_date = user.resignation_records.where(resigned_date: month_salary_report.year_month.month_range).maximum(:resigned_date) || month_salary_report.year_month.end_of_month
        month_end = month_salary_report.year_month.end_of_month
        re = resigned_date >= month_end ? month_end : resigned_date
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 235  課稅金額（MOP）：按照職業稅的計算公式自動計算，課稅金額＝（「190」﹣「202」＋「214」﹣「231」-「57」）；
    # 175 - 187 + 199 - 215 - 224
    # 其中房屋津貼免稅500MOP，也就是如果房屋津貼400MOP，則計算課稅金額為0；
    # 若房屋津貼為600MOP，則課稅金額計算使用的房屋津貼100MOP；
    # 房屋津貼計算時需要先轉換為MOP再計算；所有的項目都需要轉變為MOP再計算；
    def calc_occupational_count(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        amount_for_tax = find_or_create_by(175, user, month_salary_report, salary_type, resignation_record_id) -
            find_or_create_by(187, user, month_salary_report, salary_type, resignation_record_id) +
            hkd_to_mop(find_or_create_by(199, user, month_salary_report, salary_type, resignation_record_id)) -
            hkd_to_mop(find_or_create_by(215, user, month_salary_report, salary_type, resignation_record_id)) -
            hkd_to_mop(find_or_create_by(224, user, month_salary_report, salary_type, resignation_record_id))
        housing_allowance = hkd_to_mop(find_or_create_by(48, user, month_salary_report, salary_type, resignation_record_id))
        house_deduct = housing_allowance > 500 ? BigDecimal(500) : housing_allowance
            re = (amount_for_tax - house_deduct)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 146 職業稅（MOP）：=162*職業稅的月份的分段公式；
    def calc_occupational_tax_mop(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        mop = find_or_create_by(235, user, month_salary_report, salary_type, resignation_record_id)
        re = month_tax_mop(mop)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 147 社會保障金（MOP）：自動讀取自「社會保障基金」中對應月份員工供款金額
    def calc_social_security_fund_mop(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      re = SocialSecurityFundItem.where(user_id: user.id, year_month: month_salary_report.year_month).first&.employee_payment_mop
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 148 身份證件號碼：自動讀取員工檔案中「證件號碼」的數據
    def calc_id_card_no(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = ProfileService.id_number(user)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 149 納稅編號：自動讀取員工檔案中「稅務編號」的數據；
    def calc_tax_number(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = ProfileService.tax_number(user)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 150 社會保障號：自動讀取員工檔案中「社會保障號碼」的數據；
    def calc_sss_number(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = ProfileService.sss_number(user)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 151 報政府職位：自動讀取員工檔案「工作簽證信息」中「獲批職位名稱」的數據；
    def calc_position_of_govt_record(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = ProfileService.position_of_govt_record(user)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 152 糧單職位：
    # 本地僱員顯示員工檔案中「職位」，外地僱員顯示員工檔案中「報政府職位」；
    # 外地僱員判斷標準：員工檔案中「本地/外地僱員」選擇了「專業」或」「非專業」
    def calc_payroll_positions(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        is_foreign_employee = ProfileService.whether_foreign_employee(user)
        # not_cancel = ProfileService.not_cancel_blue_card_this_month(user, month_salary_report.year_month)
        position_of_govt_record = find_or_create_by(151, user, month_salary_report, salary_type, resignation_record_id)
        re = is_foreign_employee ? {
            id: nil,
            chinese_name: position_of_govt_record,
            english_name: position_of_govt_record,
            simple_chinese_name: position_of_govt_record
        } : user.position.as_json
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 153 是否扣愛心基金：自動讀取「愛心基金參加成員」中當月員工是否扣愛心基金；只有當月1日或之前參加這裡才符合扣愛心基金；若當月離職則不扣愛心基金；
    def calc_is_deduct_love_fund(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        if resignation_record_id
          re = false
        else
          love_fund_record = user.love_fund_records.where('participate_begin <= :month_end', month_end: month_salary_report.year_month.end_of_month).order(participate_begin: :desc).first
          re =!!love_fund_record.try(:participate)
        end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 154 是否扣醫療基金：自動讀取「醫療基金參加成員」中當月員工是否扣醫療基金；只有當月1日或之前參加這裡才符合扣醫療基金；若當月離職則不扣醫療基金
    def calc_is_deduct_medical_fund(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        if resignation_record_id
          re = false
        else
          medical_record = user.medical_records.where('participate_begin <= :month_end', month_end: month_salary_report.year_month.end_of_month).order(participate_begin: :desc).first
          re =!!medical_record.try(:participate)
        end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 155 是否扣公積金：自動讀取「公積金參加成員」中是否參加公積金的數據，只有當月1日或之前參加這裡才扣公積金；若當月離職則不扣公積金
    def calc_is_deduct_pension_fund(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        is_leave = ProfileService.is_leave_in_this_month(user, month_salary_report.year_month)
        re = if is_leave
               false
             else
               ProfileService.has_provident_fund_this_month_by_user?(user, month_salary_report.year_month)
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 156 當年在職天數：自動計算員工入職日期或者當年的1月1日到當月「薪酬結束日期」的差；具體根據員工是否當年入職；
    def calc_in_service_days(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        # re = if ProfileService.is_leave_in_this_month(user, month_salary_report.year_month.beginning_of_month)
        #        ((ProfileService.resigned_date(user) - ProfileService.employment_of_date(user)) /
        #            1.day).round rescue 0
        #      else
        #        ((month_salary_report.year_month.end_of_month - ProfileService.employment_of_date(user)) /
        #            1.day).round rescue 0
        #      end
        entry_date = user.career_records.minimum(:career_begin)
        end_date = find_or_create_by(145, user, month_salary_report, salary_type, resignation_record_id)
        _from = [entry_date, month_salary_report.year_month.beginning_of_year].compact.max rescue month_salary_report.year_month.beginning_of_year
        # _from = entry_date <= month_salary_report.year_month.beginning_of_year ? month_salary_report.year_month.beginning_of_year : entry_date
        re = ((end_date - _from) / 1.day).round rescue 0
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 157
    def calc_should_be_deducted_days_in_last_year(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      #   Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
      #     leave_without_pay_days = SalaryValue.where(user_id: user.id, salary_column_id: 29)
      #                                .where('year_month > :last_year_begin AND year_month <:last_year_end',
      #                                       last_year_begin: month_salary_report.year_month.last_year.beginning_of_year,
      #                                       last_year_end: month_salary_report.year_month.last_year.end_of_year
      #                                ).sum(:integer_value)
      #     absenteeism_days = SalaryValue.where(user_id: user.id, salary_column_id: 17)
      #                          .where('year_month > :last_year_begin AND year_month <:last_year_end',
      #                                 last_year_begin: month_salary_report.year_month.last_year.beginning_of_year,
      #                                 last_year_end: month_salary_report.year_month.last_year.end_of_year
      #                          ).sum(:integer_value)
      #     same_day_leave_days = SalaryValue.where(user_id: user.id, salary_column_id: 19)
      #                             .where('year_month > :last_year_begin AND year_month <:last_year_end',
      #                                    last_year_begin: month_salary_report.year_month.last_year.beginning_of_year,
      #                                    last_year_end: month_salary_report.year_month.last_year.end_of_year
      #                             ).sum(:integer_value)
      #     no_pay_leave_days = SalaryValue.where(user_id: user.id, salary_column_id: 18)
      #                           .where('year_month > :last_year_begin AND year_month <:last_year_end',
      #                                  last_year_begin: month_salary_report.year_month.last_year.beginning_of_year,
      #                                  last_year_end: month_salary_report.year_month.last_year.end_of_year
      #                           ).sum(:integer_value)
      #     work_injury_days_7_days_later = SalaryValue.where(user_id: user.id, salary_column_id: 28)
      #                                       .where('year_month > :last_year_begin AND year_month <:last_year_end',
      #                                              last_year_begin: month_salary_report.year_month.last_year.beginning_of_year,
      #                                              last_year_end: month_salary_report.year_month.last_year.end_of_year
      #                                       ).sum(:integer_value)
      #     days = leave_without_pay_days + absenteeism_days + same_day_leave_days + no_pay_leave_days +
      #       work_injury_days_7_days_later - 30
      #     re = days < 0 ? 0 : days
      #     get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      #   end
    end

    #id: 158 支票/現金出糧：自動讀取員工檔案中「支票/現金出糧」的數據
    def calc_payment_method(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        if resignation_record_id
          re = Config.get_single_option('payment_method', 'cash')
        else
          re = Config.get_single_option('payment_method', ProfileService.payment_method(user))
        end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 159 是否本月入職：根據入職日期是否在當月自動顯示
    def calc_entry_in_the_month(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        entry_date = user.career_records.minimum(:career_begin)
        re = entry_date >= month_salary_report.year_month.beginning_of_month && entry_date <=month_salary_report.year_month.end_of_month
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 160 是否本月離職：根據最後僱用日期是否在當月自動顯示
    def calc_turnover_in_the_month(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        # re = ProfileService.is_leave_in_this_month(user, month_salary_report.year_month)
        re = user.resignation_records.where(resigned_date: month_salary_report.year_month.month_range).empty? rescue true
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, !re)
      end
    end

    #id: 161 葡幣賬戶號碼：自動讀取員工檔案中「中國銀行帳號碼(葡幣)」的數據；
    def calc_mop_account_number(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = ProfileService.mop_account_number(user)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 162 港幣賬戶號碼：自動讀取員工檔案中「中國銀行帳號碼(港幣)」的數據；
    def calc_hkd_account_number(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = ProfileService.hkd_account_number(user)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 163 公司月結：顯示為空；
    def calc_companys_monthly_statement(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = nil
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 164 扣薪（財務報表）：顯示為空；
    def calc_deduct_salary_financial_report(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = nil
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 165 備註：默認為空，可以在表格中進行編輯
    def calc_remarks(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = nil
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 166 底薪_強制性假期補償（MOP）：自動計算＝「14強制性假期補償天數(補薪)」＊{「39底薪」+「57實習津貼」}/30天；「底薪」和「實習津貼」需要轉換為MOP來計算；
    def calc_basic_salary_compensation_fof_statutory_holiday(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(14, user, month_salary_report, salary_type, resignation_record_id) *
            hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 167 底薪_公眾假期補償（MOP）：自動計算＝「16公眾假期補償天數(補薪)」＊{「39底薪」+「57實習津貼」}/30天；「底薪」和「實習津貼」需要轉換為MOP來計算；
    def calc_basic_salary_compensation_for_public_holiday(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(16, user, month_salary_report, salary_type, resignation_record_id) *
            hkd_to_mop(
                find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id) + find_or_create_by(224, user, month_salary_report, salary_type, resignation_record_id)
            ) / 30 rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 168 底薪_加班費（MOP）：
    # 自動計算＝{「34正常加班時數」＊1.2＋「35假日加班時數」＊2 } /30天/8小時＊{「39底薪」+「57實習津貼」}；
    # 「底薪」和「實習津貼」需要轉換為MOP來計算；
    # 員工檔案中福利信息「加班薪金」若為1.2倍，則假日加班小時數也按照平日加班小時數來計算乘以1.2而不是2；
    # 讀取福利模板中的信息時以「161薪酬結束日期」當天的福利歷史記錄為準；
    def calc_basic_salary_overtime_pay(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        basic_salary_mop = hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id))

        if resignation_record_id
          start_date = find_or_create_by(144, user, month_salary_report, salary_type, resignation_record_id)
          end_date = find_or_create_by(145, user, month_salary_report, salary_type, resignation_record_id)
        else
          start_date = month_salary_report.year_month
          end_date = month_salary_report.year_month.end_of_month
        end

        welfare_records = WelfareRecord
                              .by_date_range(start_date, end_date.end_of_day)
                              .where(user: user.id)

        if welfare_records.count == 1
          times = ActiveModelSerializers::SerializableResource
                      .new(welfare_records.first)
                      .serializer_instance
                      .try(:over_time_salary) rescue nil
          times = times == 'one_point_two_times' ? 1.2 : 2
          weekday_overtime_hours = find_or_create_by(34, user, month_salary_report, salary_type, resignation_record_id)
          holiday_overtime_hours = find_or_create_by(35, user, month_salary_report, salary_type, resignation_record_id)

          re = (weekday_overtime_hours * 1.2 + holiday_overtime_hours * times) /
              BigDecimal('30') /
              BigDecimal('8') *
              basic_salary_mop rescue BigDecimal(0)
        else
          re = welfare_records.inject(BigDecimal(0)) do |total, record|
            times = ActiveModelSerializers::SerializableResource
                        .new(record)
                        .serializer_instance
                        .try(:over_time_salary) rescue nil
            welfare_begin = [record.welfare_begin.beginning_of_day, start_date].compact.max
            welfare_end = [record.welfare_end&.end_of_day, end_date].compact.min
            times = times == 'one_point_two_times' ? 1.2 : 2
            weekday_overtime_hours = _overtime_hours_for_money('weekdays',
                                                               user,
                                                               welfare_begin,
                                                               welfare_end)
            holiday_overtime_hours =
                _overtime_hours_for_money('general_holiday',
                                          user,
                                          welfare_begin,
                                          welfare_end) +
                    _overtime_hours_for_money('force_holiday',
                                              user,
                                              welfare_begin,
                                              welfare_end) +
                    _overtime_hours_for_money('public_holiday',
                                              user,
                                              welfare_begin,
                                              welfare_end)
            total +
                (weekday_overtime_hours * 1.2 + holiday_overtime_hours * times) /
                    BigDecimal('30') /
                    BigDecimal('8') *
                    basic_salary_mop rescue BigDecimal(0)
          end
        end

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    def _overtime_hours_for_money(ot_type, user, start_date, end_date)
      # ot_type in ['weekdays', 'general_holiday', 'force_holiday', 'public_holiday]
      if end_date
        records = OvertimeRecord.where(user_id: user.id,
                                       overtime_type: ot_type,
                                       compensate_type: 'money',
                                       overtime_start_date: start_date..end_date,
                                       overtime_end_date: start_date..end_date,
                                       is_compensate: false)
      else
        records = OvertimeRecord.where(user_id: user.id,
                                       overtime_type: ot_type,
                                       compensate_type: 'money',
                                       is_compensate: false)
                      .where('overtime_start_date >= :overtime_start_date  AND overtime_end_date >= :overtime_end_date ', overtime_start_date: start_date, overtime_end_date: start_date)
      end

      records.inject(0) do |sum, r|
        sum + r.overtime_hours.to_i
      end
    end

    # id: 169
    def calc_basic_salary_compensation_leave_for_paid_maternity_leave(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      #   Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
      #     re = find_or_create_by(26, user, month_salary_report, salary_type, resignation_record_id) *
      #       hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) rescue BigDecimal(0)
      #     get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      #   end
    end

    # id: 170 底薪_其他加項（MOP）：默認為空，支持表格中手動輸入修改；
    def calc_basic_salary_other_additions(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = nil
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 171 底薪_考勤補發（MOP）：根據考勤補薪的數據（補薪記錄）自動計算所有相關金額：「182 ~ 184」的補記錄﹣「191 ~ 199」的扣記錄；
    def calc_basic_salary_attendance_reissued(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        add_total = BigDecimal(0)
        add = find_or_create_add_info_by(14, user, month_salary_report) - find_or_create_deduct_info_by(14, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        add_total += add

        add = find_or_create_add_info_by(16, user, month_salary_report) - find_or_create_deduct_info_by(16, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        add_total += add

        add_1 = find_or_create_add_info_by(34, user, month_salary_report) - find_or_create_deduct_info_by(34, user, month_salary_report)
        add_1 = add_1 > 0 ? add_1 : 0

        add_2 = find_or_create_add_info_by(35, user, month_salary_report) - find_or_create_deduct_info_by(35, user, month_salary_report)
        add_2 = add_2 > 0 ? add_2 : 0

        year_month = month_salary_report.year_month
        welfare_records = WelfareRecord
                              .by_date_range(year_month.beginning_of_month, year_month.end_of_month)
                              .where(user: user.id)
        if welfare_records.count == 1
          times = ActiveModelSerializers::SerializableResource
                      .new(welfare_records.first)
                      .serializer_instance
                      .try(:over_time_salary) rescue nil
          times = times == 'one_point_two_times' ? 1.2 : 2
          add = (add_1 * 1.2 + add_2 * times) /
              BigDecimal(30) /
              BigDecimal(8) *
              hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) rescue BigDecimal(0)
          add_total += add
        else
          # FIXME (zhangmeng): 需要根据时间段按比例计算，但是补扣薪的计算不够清晰
          times = ActiveModelSerializers::SerializableResource
                      .new(welfare_records.order(:welfare_begin).last)
                      .serializer_instance
                      .try(:over_time_salary) rescue nil
          times = times == 'one_point_two_times' ? 1.2 : 2
          add = (add_1 * 1.2 + add_2 * times) /
              BigDecimal(30) /
              BigDecimal(8) *
              hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) rescue BigDecimal(0)
          add_total += add
        end

        add = find_or_create_add_info_by(14, user, month_salary_report) - find_or_create_deduct_info_by(14, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) rescue BigDecimal(0)
        add_total += add

        deduct_total = BigDecimal(0)

        add = find_or_create_add_info_by(17, user, month_salary_report) - find_or_create_deduct_info_by(17, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        deduct_total += add

        add = find_or_create_add_info_by(19, user, month_salary_report) - find_or_create_deduct_info_by(19, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        deduct_total += add

        add = find_or_create_add_info_by(18, user, month_salary_report) - find_or_create_deduct_info_by(18, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        deduct_total += add

        add = find_or_create_add_info_by(20, user, month_salary_report) - find_or_create_deduct_info_by(20, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        deduct_total += add

        add = find_or_create_add_info_by(21, user, month_salary_report) - find_or_create_deduct_info_by(21, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        deduct_total += add
        add = find_or_create_add_info_by(22, user, month_salary_report) - find_or_create_deduct_info_by(22, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        deduct_total += add
        add = find_or_create_add_info_by(25, user, month_salary_report) - find_or_create_deduct_info_by(25, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        deduct_total += add
        add = find_or_create_add_info_by(28, user, month_salary_report) - find_or_create_deduct_info_by(28, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        deduct_total += add
        add = find_or_create_add_info_by(29, user, month_salary_report) - find_or_create_deduct_info_by(29, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        deduct_total += add

        re = add_total + deduct_total
        re = re < 0 ? BigDecimal(0) : re
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 172 底薪_未享受年假補償（MOP）：只有當月員工離職才進行計算，不計算時顯示為空；
    # 自動計算＝「12剩餘年假天數」＊「39底薪」/30天；「底薪」需要轉換為MOP來計算；計算剩餘年假時以該員工最後僱用日期為計算日期；
    def calc_basic_salary_dont_enjoy_the_annual_leave_compensation(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        if salary_type == 'left'
          re = find_or_create_by(12, user, month_salary_report, salary_type, resignation_record_id) *
              hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / BigDecimal(30) rescue BigDecimal(0)
        else
          re = BigDecimal(0)
        end

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 173  底薪_解僱賠償（MOP）：只有當月員工離職才進行計算，不計算時顯示為空；
    # 當員工為本地員工時，且工作年限1年以上，計算=「39底薪」/30＊補償年資天數＊賠償天數係數；賠償金額上限為12＊「底薪」
    # 使用計算的底薪上限為20000MOP；賠償天數係數為工作年限1年一下為7；
    # 1 ~ 3年為10；
    # 3 ~ 5年為13；5 ~ 7年為15；
    # 7 ~ 8年為16；8 ~ 9年為17；
    # 9 ~ 10年為18；
    # 10年以上為20
    # 當員工為本地員工時，且工作年限小於1年，計算=「39底薪」*7/30；
    # 當員工為外地僱員時，計算=「39底薪」*3*n/30；n=「藍卡到期日」-「最後僱用日期」的月份值，為整數，也就是每相差一個月算作是1，只舍不進，但若不到一個月但是是正數則也算作1；
    # 若取不到其中任何一個數據或者n小於0，則整體結果算作是0；
    # 「底薪」需要轉換為MOP來計算；
    # 僅當員工檔案離職記錄中的「是否補償年資」為「是」時才按此計算，否則計算為0；
    def calc_basic_salary_fire_compensation(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = nil
        if resignation_record_id
          resignation_record = ResignationRecord.find(resignation_record_id)
          get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re) unless resignation_record
          compensation_year = resignation_record.compensation_year rescue false
          if compensation_year
            is_foreign = ProfileService.whether_foreign_employee(user)
            unless is_foreign
              basic_salary = hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id))
              basic_salary = basic_salary > BigDecimal(20000) ? BigDecimal(20000) : basic_salary
              year = ((ProfileService.resigned_date(user).end_of_day - ProfileService.employment_of_date(user).beginning_of_day) / 1.year).floor rescue 0
              day_num = if year < 1
                          7
                        elsif year >= 1 && year < 3
                          10
                        elsif year >= 3 && year < 5
                          13
                        elsif year >= 5 && year < 7
                          15
                        elsif year >= 7 && year < 8
                          16
                        elsif year >= 8 && year < 9
                          17
                        elsif year >= 9 && year < 10
                          18
                        else
                          20
                        end
              if year > 1
                # 39底薪/30＊補償年資天數 ＊ 賠償天數係數；賠償金額上限為12 ＊ 「底薪」
                # 補償年資天數
                employment_of_date = ProfileService.date_of_employment(user)
                resigned_date = ProfileService.resigned_date(user, resignation_record_id)
                d_year = resigned_date.year - employment_of_date.year
                d_month = resigned_date.month - (employment_of_date.month + 1)
                d_day = resigned_date.mday + employment_of_date.end_of_month.mday - employment_of_date.mday
                remainder = d_day % 30
                months = d_day / 30
                d_day = remainder >= 15 ? (months + 1) : months
                months = d_year * 12 + d_month + d_day
                result = (BigDecimal(months) / BigDecimal(12)).round(2)
                re = basic_salary / 30 * day_num * result rescue 0
                re = [re, basic_salary * BigDecimal(12)].min
              else
                # 39底薪 *7/30
                re = basic_salary * 7 / BigDecimal(30) rescue 0
                re = [re, basic_salary * BigDecimal(12)].min
              end
            else
              # 「39底薪」*3*n/30；n=「藍卡到期日」-「最後僱用日期」的月份值，為整數，也就是每相差一個月算作是1，只舍不進，但若不到一個月但是是正數則也算作1；
              n = ((CardProfile.find_by(user_id: user.id).allocation_valid_date - resignation_record.resigned_date) / 1.month).floor rescue 0
              re = basic_salary / BigDecimal(30) * n * 3 rescue 0
            end
          else
            re = 0
          end
        end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 174 底薪_代通知金（MOP）
    # 只有當月員工離職才進行計算，不計算時顯示為空；
    # 自動計算＝{「離職通知期」- [「最後僱用日期」-「通知日期」]}＊「底薪」/30天；
    # 其中「{「離職通知期」- [「最後僱用日期」-「通知日期」]}」的值必須大於0，否按照0來計算；
    # 「離職通知期」讀取福利模板中的信息時以「161薪酬結束日期」當天的福利歷史記錄為準；
    # 若「員工辭職」未豁免通知期則為負數；
    # 若「終止僱用」有通知期則為正數；「底薪」需要轉換為MOP來計算；
    # 僅當員工檔案離職記錄中的「是否豁免通知期」為「否」時才按此計算，否則為0；
    def calc_basic_salary_notice_of_compensation(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        if resignation_record_id
          # wr = WelfareRecord.where(user_id: user.id, status: :being_valid).first
          resigned_date = ProfileService.resigned_date(user, resignation_record_id)
          #离职当天生效的福利信息
          wr = WelfareRecord
                   .where('welfare_begin <= :resigned_date AND (welfare_end >= :resigned_date OR welfare_end IS NULL)', resigned_date: resigned_date)
                   .where(user_id: user.id)
                   .order(welfare_begin: :desc)
                   .first
          notice_days = if wr
                          ActiveModelSerializers::SerializableResource.new(wr).serializer_instance.notice_period
                        else
                          0
                        end
          resignation_record = ResignationRecord.find(resignation_record_id)
          days_between_resign_and_notice = ((resigned_date - resignation_record.notice_date) / 1.day).round
          days_between_resign_and_notice = if days_between_resign_and_notice < 0
                                             0
                                           elsif days_between_resign_and_notice > notice_days
                                             notice_days
                                           else
                                             days_between_resign_and_notice
                                           end
          d_value = notice_days - days_between_resign_and_notice

          basic_salary = hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id))
          sum = if resignation_record.notice_period_compensation
                  if resignation_record.resigned_reason == 'resignation'
                    BigDecimal(-1)
                  elsif resignation_record.resigned_reason == 'termination'
                    BigDecimal(1)
                  else
                    BigDecimal(0)
                  end
                else
                  BigDecimal(0)
                end
          re = d_value * basic_salary / 30 * sum
        else
          re = BigDecimal(0)
        end

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 175 '底薪_總薪酬（MOP）：＝「39底薪」+「57實習津貼」+「182」+「183」+「184」+「185」+「186」+「187」+「188」+「189」'
    # 「底薪」和「實習津貼」需要轉換為MOP來計算
    def calc_basic_salary_gross_income(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id) + find_or_create_by(224, user, month_salary_report, salary_type, resignation_record_id)) +
            find_or_create_by(166, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(167, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(168, user, month_salary_report, salary_type, resignation_record_id) +
            # find_or_create_by(169, user, month_salary_report, salary_type, resignation_record_id) +
            math_add(find_or_create_by(170, user, month_salary_report, salary_type, resignation_record_id)) +
            find_or_create_by(171, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(172, user, month_salary_report, salary_type, resignation_record_id) +
            (find_or_create_by(173, user, month_salary_report, salary_type, resignation_record_id) || BigDecimal(0)) +
            find_or_create_by(174, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 176 底薪_曠工扣減（MOP）：自動計算＝「17曠工天數」＊{「39底薪」+「57實習津貼」}/30天；「底薪」和「實習津貼」需要轉換為MOP來計算；
    def calc_basic_salary_absences_without_official_leave_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(17, user, month_salary_report, salary_type, resignation_record_id) *
            hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id) + find_or_create_by(224, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 177 底薪_即告扣減（MOP）：自動計算＝「19即告天數」＊{「39底薪」+「57實習津貼」}/30天；「底薪」和「實習津貼」需要轉換為MOP來計算；
    def calc_basic_salary_same_day_leave_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(19, user, month_salary_report, salary_type, resignation_record_id) *
            hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id) + find_or_create_by(224, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 178 底薪_無薪假扣減（MOP）：自動計算＝「18無薪假天數」＊{「39底薪」+「57實習津貼」}/30天；「底薪」和「實習津貼」需要轉換為MOP來計算；
    def calc_basic_salary_unpaid_leave_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(18, user, month_salary_report, salary_type, resignation_record_id) *
            hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id) + find_or_create_by(224, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 179 底薪_無薪婚假扣減（MOP）：自動計算＝「20無薪婚假天數」＊{「39底薪」+「57實習津貼」}/30天；「底薪」和「實習津貼」需要轉換為MOP來計算；
    def calc_baisc_salary_marriage_leave_without_pay_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(20, user, month_salary_report, salary_type, resignation_record_id) *
            hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id) + find_or_create_by(224, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 180 底薪_無薪恩恤假扣減（MOP）：自動計算＝「21無薪恩恤假天數」＊{「39底薪」+「57實習津貼」}/30天；「底薪」和「實習津貼」需要轉換為MOP來計算；
    def calc_basic_salary_unpaid_compssionate_leave_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(21, user, month_salary_report, salary_type, resignation_record_id) *
            hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id) + find_or_create_by(224, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 181 底薪_懷孕病假扣減（MOP）：自動計算＝「22懷孕病假天數」＊{「39底薪」+「57實習津貼」}/30天；「底薪」和「實習津貼」需要轉換為MOP來計算；
    def calc_basic_salary_pregnant_sick_leave_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(22, user, month_salary_report, salary_type, resignation_record_id) *
            hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id) + find_or_create_by(224, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 182 底薪_無薪分娩假扣減（MOP）：自動計算＝「25無薪分娩假天數」＊{「39底薪」+「57實習津貼」}/30天；「底薪」和「實習津貼」需要轉換為MOP來計算；
    def calc_basic_salary_maternity_leave_without_pay_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(25, user, month_salary_report, salary_type, resignation_record_id) *
            hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id) + find_or_create_by(224, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 183 底薪_工傷（7天後）扣減（MOP）：自動計算＝「28工傷天數(7天後)」＊{「39底薪」+「57實習津貼」}/30天；「底薪」和「實習津貼」需要轉換為MOP來計算；
    def calc_basic_work_injury_7_days_later_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(28, user, month_salary_report, salary_type, resignation_record_id) *
            hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id) + find_or_create_by(224, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 184 底薪_停薪留職扣減（MOP）：自動計算＝「29停薪留職天數」＊{「39底薪」+「57實習津貼」}/30天；「底薪」和「實習津貼」需要轉換為MOP來計算；
    def calc_basic_salary_leave_without_pay_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(29, user, month_salary_report, salary_type, resignation_record_id) *
            hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id) + find_or_create_by(224, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 185 底薪_其他扣減（MOP）：默認為空，支持表格中手動輸入修改；
    def calc_basic_salary_other_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = nil
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 186 底薪_考勤補扣（MOP）：根據考勤補薪的數據（補薪記錄）自動計算所有相關金額：「191 ~ 199」的補記錄﹣「182 ~ 184」的扣記錄
    def calc_basic_salary_attendance_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        add_total = BigDecimal(0)

        add = find_or_create_add_info_by(17, user, month_salary_report) - find_or_create_deduct_info_by(17, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        add_total += add

        add = find_or_create_add_info_by(19, user, month_salary_report) - find_or_create_deduct_info_by(19, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        add_total += add

        add = find_or_create_add_info_by(18, user, month_salary_report) - find_or_create_deduct_info_by(18, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        add_total += add

        add = find_or_create_add_info_by(20, user, month_salary_report) - find_or_create_deduct_info_by(20, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        add_total += add

        add = find_or_create_add_info_by(21, user, month_salary_report) - find_or_create_deduct_info_by(21, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        add_total += add
        add = find_or_create_add_info_by(22, user, month_salary_report) - find_or_create_deduct_info_by(22, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        add_total += add
        add = find_or_create_add_info_by(25, user, month_salary_report) - find_or_create_deduct_info_by(25, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        add_total += add
        add = find_or_create_add_info_by(28, user, month_salary_report) - find_or_create_deduct_info_by(28, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        add_total += add
        add = find_or_create_add_info_by(29, user, month_salary_report) - find_or_create_deduct_info_by(29, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        add_total += add

        deduct_total = BigDecimal(0)
        add = find_or_create_add_info_by(14, user, month_salary_report) - find_or_create_deduct_info_by(14, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        deduct_total += add

        add = find_or_create_add_info_by(16, user, month_salary_report) - find_or_create_deduct_info_by(16, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) / 30 rescue BigDecimal(0)
        deduct_total += add

        # FIXME (zhangmeng): 应该按比例计算，单目前补扣薪的计算不够清晰
        times = ActiveModelSerializers::SerializableResource
                    .new(WelfareRecord.where(user: user.id).order(welfare_begin: :desc).first)
                    .serializer_instance
                    .try(:over_time_salary) rescue nil
        times = times == 'one_point_two_times' ? 1.2 : 2
        add_1 = find_or_create_add_info_by(34, user, month_salary_report) - find_or_create_deduct_info_by(34, user, month_salary_report)
        add_1 = add_1 < 0 ? add_1 : 0

        add_2 = find_or_create_add_info_by(35, user, month_salary_report) - find_or_create_deduct_info_by(35, user, month_salary_report)
        add_2 = add_2 < 0 ? add_2 : 0

        add = (add_1 * 1.2 + add_2 * times) /
            BigDecimal(30) /
            BigDecimal(8) *
            hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) rescue BigDecimal(0)
        deduct_total += add

        add = find_or_create_add_info_by(14, user, month_salary_report) - find_or_create_deduct_info_by(14, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) rescue BigDecimal(0)
        deduct_total += add

        re = deduct_total + add_total
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 187 底薪_總扣減（MOP）：自動計算＝「191」＋「192」＋「193」＋「194」＋「195」＋「196」＋「197」＋「198」＋「199」＋「200」＋「201」；
    def calc_basic_salary_total_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(176, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(177, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(178, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(179, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(180, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(181, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(182, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(183, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(184, user, month_salary_report, salary_type, resignation_record_id) +
            math_add(find_or_create_by(185, user, month_salary_report, salary_type, resignation_record_id)) +
            find_or_create_by(186, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 188 醫療報銷（MOP）：自動讀取「醫療報銷」記錄中對應月份的「報銷金額」加和的數據；
    def calc_medical_reimbursement(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = MedicalReimbursement.joins(:medical_template).where(medical_templates: {insurance_type: :suncity_insurance})
                 .where(user_id: user.id, apply_date: month_salary_report.year_month.month_range)
                 .sum(:reimbursement_amount)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 189  其他(不納稅)（MOP）：默認為空，支持表格中手動輸入修改；
    def calc_other_non_tax(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = nil
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 190 扣愛心基金（MOP）：若「170是否扣愛心基金」為是，則顯示為20；反之為0；
    def calc_deduct_love_fund(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        delete = find_or_create_by(153, user, month_salary_report, salary_type, resignation_record_id)
        re = delete ? BigDecimal(Config.get(:constants_collection)['LoveFundCost']) : BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 191 扣醫療基金（MOP）：若「171是否扣醫療基金」為是，則顯示為50；反之為0；
    def calc_deduct_medical_fund(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        delete = find_or_create_by(154, user, month_salary_report, salary_type, resignation_record_id)
        re = delete ? BigDecimal(Config.get(:constants_collection)['MedicalInsuranceParticipator']) : BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 192 扣公積金百分比：
    # 若「172是否扣公積金」為是，則「161薪酬計算日期」該員工的職級來計算，5級員工為0.05、3~4級員工為0.06、1~2級員工為0.07；
    # 若「172是否扣公積金」為否，則顯示為空；
    def calc_percentage_of_pension_fund_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        #0.01 为百分数的单位
        re = ContributionReportItem.calc_percentage_of_voluntary_contributions_of_members(user, month_salary_report.year_month, ProfileService.is_leave_in_this_month(user, month_salary_report.year_month)) * 0.01 if find_or_create_by(155, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 193 扣公積金（MOP）：自動計算＝「207扣公積金百分比」＊「39底薪」；「底薪」需要轉換為MOP來計算；
    def calc_deduct_pension_fund(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = math_add(find_or_create_by(192, user, month_salary_report, salary_type, resignation_record_id)) * hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id)) if find_or_create_by(155, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 194 扣其他(不納稅)（MOP）：默認為空，支持表格中手動輸入修改；
    def calc_deduct_other_non_tax(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = nil
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 195 底薪總數實發（MOP）：自動計算＝「190」﹣「202」＋「203」＋「204」﹣「205」﹣「206」﹣「208」﹣「209」；
    def calc_really_total_basic_salary(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(175, user, month_salary_report, salary_type, resignation_record_id)-
            find_or_create_by(187, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(188, user, month_salary_report, salary_type, resignation_record_id) +
            math_add(find_or_create_by(189, user, month_salary_report, salary_type, resignation_record_id)) -
            find_or_create_by(190, user, month_salary_report, salary_type, resignation_record_id) -
            find_or_create_by(191, user, month_salary_report, salary_type, resignation_record_id) -
            math_add(find_or_create_by(193, user, month_salary_report, salary_type, resignation_record_id)) -
            math_add(find_or_create_by(194, user, month_salary_report, salary_type, resignation_record_id))
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 196 除底薪外_其他加項：默認為空，支持表格中手動輸入修改；
    def calc_except_for_basic_salary_other_additions(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = nil
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 197 除底薪外_考勤補發：根據考勤補薪的數據（補薪記錄）自動計算所有相關金額：「213」的補記錄﹣「215 ~ 227」的扣記錄；
    def calc_except_fof_basic_salary_attendance_reissued(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        add_total = BigDecimal(0)
        # 198补记录
        add = find_or_create_add_info_by(36, user, month_salary_report) - find_or_create_deduct_info_by(36, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add * 100 rescue BigDecimal(0)
        add_total += add

        # 200～211扣记录
        # 200
        deduct_total = BigDecimal(0)
        add = find_or_create_add_info_by(17, user, month_salary_report) - find_or_create_deduct_info_by(17, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add *(find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)) / 30 +
            add * 1500
        deduct_total += add
        # 201
        add = find_or_create_add_info_by(19, user, month_salary_report) - find_or_create_deduct_info_by(19, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add *(find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)) / 30 +
            add * 1000
        deduct_total += add
        # 202
        add = find_or_create_add_info_by(18, user, month_salary_report) - find_or_create_deduct_info_by(18, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add *(find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)) / 30 +
            add * 500
        deduct_total += add
        # 203
        add = find_or_create_add_info_by(20, user, month_salary_report) - find_or_create_deduct_info_by(20, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add *(find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)) / 30 +
            add * 250
        deduct_total += add
        # 204
        add = find_or_create_add_info_by(21, user, month_salary_report) - find_or_create_deduct_info_by(21, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add *(find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)) / 30 +
            add * 250
        deduct_total += add
        # 205
        add = find_or_create_add_info_by(25, user, month_salary_report) - find_or_create_deduct_info_by(25, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add *
            (find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
                find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id) +
                _calc_department_bonus(user, month_salary_report)) / 30
        deduct_total += add
        # 206
        add = find_or_create_add_info_by(22, user, month_salary_report) - find_or_create_deduct_info_by(22, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add * (find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)) / 30
        deduct_total += add
        # 207
        add = find_or_create_add_info_by(28, user, month_salary_report) - find_or_create_deduct_info_by(28, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add * _calc_department_bonus(user, month_salary_report) / 30 +
            add * (find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
                find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id)) / 30 / 3
        deduct_total += add
        # 208
        add = find_or_create_add_info_by(29, user, month_salary_report) - find_or_create_deduct_info_by(17, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add *(find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id)+
            find_or_create_by(51, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(48, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_all_bonus(user, month_salary_report)
        ) / 30
        deduct_total += add
        # 209
        add_1 = find_or_create_add_info_by(24, user, month_salary_report) - find_or_create_deduct_info_by(24, user, month_salary_report)
        add_1 = add_1 < 0 ? add_1 : 0
        add_2 = find_or_create_add_info_by(23, user, month_salary_report) - find_or_create_deduct_info_by(23, user, month_salary_report)
        add_2 = add_2 < 0 ? add_2 : 0
        # 「有薪病假連off天數」＊500＋「有薪病假不連off天數」＊250;有薪病假只扣除勤工
        add = add_1 * 500 + add_2 * 250
        deduct_total += add
        # 210
        add_1 = find_or_create_add_info_by(30, user, month_salary_report) - find_or_create_deduct_info_by(30, user, month_salary_report)
        add_1 = add_1 < 0 ? add_1 : 0
        add_2 = find_or_create_add_info_by(31, user, month_salary_report) - find_or_create_deduct_info_by(31, user, month_salary_report)
        add_2 = add_2 < 0 ? add_2 : 0
        add_3 = find_or_create_add_info_by(32, user, month_salary_report) - find_or_create_deduct_info_by(32, user, month_salary_report)
        add_3 = add_3 < 0 ? add_3 : 0
        add_4 = find_or_create_add_info_by(33, user, month_salary_report) - find_or_create_deduct_info_by(33, user, month_salary_report)
        add_4 = add_4 < 0 ? add_4 : 0
        # 「遲到次數(小於等於10)﹣3」＊250＋「遲到次數(小於等於20)」＊250＋「遲到次數(小於等於30)」＊500＋「遲到次數(大於30)」＊750；
        add = add_1 * 250 + add_2 * 250 + add_3 * 500 + add_4 * 750
        deduct_total += add
        # 211
        add_1 = find_or_create_add_info_by(10, user, month_salary_report) - find_or_create_deduct_info_by(10, user, month_salary_report)
        add_1 = add_1 < 0 ? add_1 : 0
        add_2 = find_or_create_add_info_by(11, user, month_salary_report) - find_or_create_deduct_info_by(11, user, month_salary_report)
        add_2 = add_2 < 0 ? add_2 : 0
        # {「漏打上班次數」＋「漏打下班次數」﹣1 }＊300；
        add = add_1 + add_2
        add = add * 300
        deduct_total += add
        # 「198」的補記錄+「200 ~ 211」的扣記錄
        re = add_total.abs + deduct_total.abs
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 198 除底薪外_颱風津貼：計算＝「36颱風上班天數」＊100；
    def calc_except_for_basic_salary_typhoon_allowance(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(36, user, month_salary_report, salary_type, resignation_record_id) * 100 rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: '199 除底薪外_總薪酬：
    # '計算＝「42津貼」＋「45勤工」＋「48房屋津貼」＋「51地區津貼」＋「54服務獎金」+「62茶資」＋「70佣金差額」＋
    # '「75殺數分紅」＋「80業績分紅」＋「85刷卡獎金」＋「90貴賓卡消費」＋「95收賬分紅」＋「100匯率分紅」＋「105項目分紅」＋
    # '「110尊華殿」＋「115尚品獎金」＋「116出車獎金」＋「117介紹新客戶轉碼分紅」＋「122新春利是」+「127績效獎金」+「132特別茶資」＋「211」＋「212」＋「213」；
    # 貴賓卡消費不需要轉換單位
    def calc_except_for_basic_salary_gross_income(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(48, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(51, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(221, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(56, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(64, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(69, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(74, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(79, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(84, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(89, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(94, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(99, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(104, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(109, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(110, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(111, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(116, user, month_salary_report, salary_type, resignation_record_id) +
            math_add(find_or_create_by(196, user, month_salary_report, salary_type, resignation_record_id))+
            find_or_create_by(197, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(229, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(234, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(198, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 200 '除底薪外_曠工扣減：計算＝「17曠工天數」＊{「42津貼」+「51地區津貼」+「54服務獎金」+「部門制浮動薪金」} /30天＋「17曠工天數」＊1500；最後的金額為扣除「勤工」；
    def calc_except_for_basic_salary_absences_without_official_leave_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(17, user, month_salary_report, salary_type, resignation_record_id) * (
        find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(51, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(221, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)
        ) / 30 +
            find_or_create_by(17, user, month_salary_report, salary_type, resignation_record_id) * 1500 * calculate_attendance_bonus_deduct_percentage(user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 201 '除底薪外_即告扣減：計算＝「19即告天數」＊{「42津貼」+「51地區津貼」+「54服務獎金」+「部門制浮動薪金」} /30天＋「19即告天數」＊1000；最後的金額為扣除「勤工」；
    def calc_except_for_basic_salary_same_day_leave_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(19, user, month_salary_report, salary_type, resignation_record_id) * (
        find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(51, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(221, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)
        ) / 30 +
            find_or_create_by(19, user, month_salary_report, salary_type, resignation_record_id) * 1000 * calculate_attendance_bonus_deduct_percentage(user, month_salary_report, salary_type, resignation_record_id)

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 202 '除底薪外_無薪假扣減：計算＝「18無薪假天數」＊{「42津貼」+「51地區津貼」+「54服務獎金」＋「部門制浮動薪金」} /30天＋「18無薪假天數」＊500；
    # 最後的金額為扣除「勤工」；
    def calc_except_for_basic_salary_unpaid_leave_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(18, user, month_salary_report, salary_type, resignation_record_id) * (
        find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(51, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(221, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)
        ) / 30 +
            find_or_create_by(18, user, month_salary_report, salary_type, resignation_record_id) * 500 * calculate_attendance_bonus_deduct_percentage(user, month_salary_report, salary_type, resignation_record_id)

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 203 '除底薪外_無薪婚假扣減：計算＝「20無薪婚假天數」＊{「42津貼」+「51地區津貼」+「54服務獎金」＋「部門制浮動薪金」} /30天＋「20無薪婚假天數」＊250；
    # 最後的金額為扣除「勤工」；
    def calc_except_for_basic_salary_marriage_leave_without_pay_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(20, user, month_salary_report, salary_type, resignation_record_id) * (
        find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(51, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(221, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)
        ) / 30 +
            find_or_create_by(20, user, month_salary_report, salary_type, resignation_record_id) * 250 * calculate_attendance_bonus_deduct_percentage(user, month_salary_report, salary_type, resignation_record_id)

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 204 '除底薪外_無薪恩恤假扣減：計算＝「21無薪恩恤假天數」＊{「42津貼」+「51地區津貼」+「54服務獎金」＋「部門制浮動薪金」} /30天＋「21無薪恩恤假天數」＊250；
    # 最後的金額為扣除「勤工」；
    def calc_except_for_basic_salary_unpaid_compassionate_leave_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(21, user, month_salary_report, salary_type, resignation_record_id) * (
        find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(51, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(221, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)
        ) / 30 +
            find_or_create_by(21, user, month_salary_report, salary_type, resignation_record_id) * 250 * calculate_attendance_bonus_deduct_percentage(user, month_salary_report, salary_type, resignation_record_id)

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    # id: 236 '除底薪外_有薪分娩假扣減：計算＝「26有薪分娩假天數」＊{「42津貼」+「51地區津貼」+「54服務獎金」＋「45勤工」＋「部門制浮動薪金」} /30天；
    def calc_except_for_basic_salary_maternity_leave_with_pay_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(26, user, month_salary_report, salary_type, resignation_record_id) * (
        find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(51, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(221, user, month_salary_report, salary_type, resignation_record_id)
            _calc_department_bonus(user, month_salary_report)) / 30

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 205 '除底薪外_無薪分娩假扣減：計算＝「25無薪分娩假天數」＊{「42津貼」+「51地區津貼」+「54服務獎金」＋「45勤工」＋「部門制浮動薪金」} /30天；
    def calc_except_for_basic_salary_maternity_leave_withoud_pay_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(25, user, month_salary_report, salary_type, resignation_record_id) * (
        find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(51, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(221, user, month_salary_report, salary_type, resignation_record_id)
        _calc_department_bonus(user, month_salary_report)) / 30 +
            find_or_create_by(25, user, month_salary_report, salary_type, resignation_record_id) *
                find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id) / 30 * calculate_attendance_bonus_deduct_percentage(user, month_salary_report, salary_type, resignation_record_id)

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 206 '除底薪外_懷孕病假扣減：計算＝「22懷孕病假天數」＊{「42津貼」+「51地區津貼」+「54服務獎金」＋「部門制浮動薪金」} /30天；
    def calc_except_for_basic_salary_pregnant_sick_leave_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(22, user, month_salary_report, salary_type, resignation_record_id) * (
        find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(51, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(221, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)
        ) / 30

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 207 '除底薪外_工傷（7天後）扣減：計算＝「28工傷天數(7天後)」＊「部門制浮動薪金」/30天＋「28工傷天數(7天後)」＊{「42津貼」+「51地區津貼」+「54服務獎金」＋「45勤工」} /30天/3；
    def calc_except_for_basic_salary_work_injury_7_days_later_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(28, user, month_salary_report, salary_type, resignation_record_id) * _calc_department_bonus(user, month_salary_report) / 30 +
            find_or_create_by(28, user, month_salary_report, salary_type, resignation_record_id) * find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) / 30 / 3 +
            find_or_create_by(28, user, month_salary_report, salary_type, resignation_record_id) * find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) / 30 / 3 +
            find_or_create_by(28, user, month_salary_report, salary_type, resignation_record_id) * find_or_create_by(221, user, month_salary_report, salary_type, resignation_record_id) / 30 / 3 +
            find_or_create_by(28, user, month_salary_report, salary_type, resignation_record_id) * find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id) / 30 / 3 * calculate_attendance_bonus_deduct_percentage(user, month_salary_report, salary_type, resignation_record_id)

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 208 '除底薪外_停薪留職扣減：計算＝「29停薪留職天數」＊{「42津貼」+「51地區津貼」+「54服務獎金」+「45勤工」＋「所有浮動薪金」} /30天；
    def calc_except_for_basic_salary_leave_without_pay_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(29, user, month_salary_report, salary_type, resignation_record_id) *
            (find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +

                find_or_create_by(51, user, month_salary_report, salary_type, resignation_record_id) +
                find_or_create_by(48, user, month_salary_report, salary_type, resignation_record_id) +
                _calc_all_bonus(user, month_salary_report)
            ) / 30 +
            find_or_create_by(29, user, month_salary_report, salary_type, resignation_record_id) *
                find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id) / 30 * calculate_attendance_bonus_deduct_percentage(user, month_salary_report, salary_type, resignation_record_id)

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 209 除底薪外_有薪病假扣減：計算＝「24有薪病假連off天數」＊500＋「23有薪病假不連off天數」＊250；扣除的金額僅為「勤工」且不能為負數，最小扣到為0；
    def calc_except_for_basic_salary_sick_leave_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = (find_or_create_by(24, user, month_salary_report, salary_type, resignation_record_id) * 500 + find_or_create_by(23, user, month_salary_report, salary_type, resignation_record_id) * 250) *
            calculate_attendance_bonus_deduct_percentage(user, month_salary_report, salary_type, resignation_record_id)

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 210 除底薪外_遲到扣減：= [「31遲到次數(小於等於10)」﹣3]＊250＋「31遲到次數(小於等於20)」＊250＋「32遲到次數(小於等於30)」＊500＋「33遲到次數(大於30)」＊750；
    # 扣除的金額僅為「勤工」且不能為負數，最小扣到為0；
    def calc_except_for_basic_salary_lateness_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        # re = (find_or_create_by(30, user, month_salary_report, salary_type, resignation_record_id) - 3 ) * 250 +
        #   find_or_create_by(31, user, month_salary_report, salary_type, resignation_record_id) * 250 +
        #   find_or_create_by(32, user, month_salary_report, salary_type, resignation_record_id) * 500 +
        #   find_or_create_by(33, user, month_salary_report, salary_type, resignation_record_id) * 750
        re = calculate_210_211_deduct(user, month_salary_report, salary_type, resignation_record_id)[:deduct_210]

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 211 除底薪外_漏打卡上下班扣減：{「10漏打上班次數」＋「11漏打下班次數」﹣1 }＊300；
    # 扣除的金額順序為「勤工」>「津貼」>「部門制浮動薪金」；
    # 所有扣除的金額不能為負數，最小扣到為0；不扣除個人制浮動薪金；
    def calc_except_for_basic_salary_unaccounted_clock_in_out_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        # re = (find_or_create_by(10, user, month_salary_report, salary_type, resignation_record_id) +
        #   find_or_create_by(11, user, month_salary_report, salary_type, resignation_record_id) - 1) * 300
        # re = re < 0 ? BigDecimal(0) : re
        re = calculate_210_211_deduct(user, month_salary_report, salary_type, resignation_record_id)[:deduct_211] || BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 212 除底薪外_處罰通知書扣減：
    # 計算當月剩餘的全部（扣除考勤之後剩餘）「業績分紅」、「殺數分紅」、「佣金差額」、「收賬分紅」、「匯率分紅」、「項目分紅」、「服務獎金」、「績效獎金」；
    # 僅當員工因為當月紀律處分而需要扣的時候按此計算；若員工當月有2條以上記錄時，
    # 從當月開始依次扣除n個月；若當月所有需要扣除的浮動薪金都為0時，當月不進行扣除，延到下個月再扣除；
    # 紀律處分記錄中若「是否出勤欠佳」選擇了否，則正常按照上述規則扣除；
    # 若「是否出勤欠佳」選擇了是，且剩餘的「服務獎金」大於0，則僅扣除剩餘全部的「服務獎金」；
    # 若「是否出勤欠佳」選擇了是，且剩餘的「服務獎金」為0，則扣除剩餘全部的「業績分紅」、「殺數分紅」、「佣金差額」、「收賬分紅」、「匯率分紅」、「項目分紅」、「服務獎金」、「績效獎金」；
    def calc_except_for_basic_salary_disposition_notice_times_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        punishment = Punishment.where(user_id: user.id, salary_deduct_status: :false).order(punishment_date: :asc).first
        # 无处罚记录
        if !punishment
          re = BigDecimal(0)
          return get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
        end
        # 計算當月剩餘的全部（扣除考勤之後剩餘）「業績分紅」、「殺數分紅」、「佣金差額」、「收賬分紅」、「匯率分紅」、「項目分紅」、「服務獎金」、「績效獎金」；
        # 僅當員工因為當月紀律處分而需要扣的時候按此計算；若員工當月有2條以上記錄時，
        # 從當月開始依次扣除n個月；若當月所有需要扣除的浮動薪金都為0時，當月不進行扣除，延到下個月再扣除；
        # 紀律處分記錄中若「是否出勤欠佳」選擇了否，則正常按照上述規則扣除；
        # 若「是否出勤欠佳」選擇了是，且剩餘的「服務獎金」大於0，則僅扣除剩餘全部的「服務獎金」；
        # 若「是否出勤欠佳」選擇了是，且剩餘的「服務獎金」為0，則扣除剩餘全部的「業績分紅」、「殺數分紅」、「佣金差額」、「收賬分紅」、「匯率分紅」、「項目分紅」、「服務獎金」、「績效獎金」；
        if punishment.is_poor_attendance || (find_or_create_by(221, user, month_salary_report, salary_type, resignation_record_id) == 0)
          departmental_float_salary_release =_calc_department_bonus(user, month_salary_report)
          personal_float_salary_release = _calc_all_bonus(user, month_salary_report) -
              _calc_department_bonus(user, month_salary_report)
          departmental_float_salary_deduct = calculate_departmental_float_salary_deduct(user, month_salary_report, salary_type, resignation_record_id) +
              calculate_210_211_deduct(user, month_salary_report, salary_type, resignation_record_id)[:departmental_float_salary_deduct]
          personal_float_salary_deduct = calculate_personal_float_salary_deduct(user, month_salary_report, salary_type, resignation_record_id) +
              calculate_210_211_deduct(user, month_salary_report, salary_type, resignation_record_id)[:personal_float_salary_deduct]
          department_percent = departmental_float_salary_deduct / departmental_float_salary_release
          department_percent = BigDecimal(1) if departmental_float_salary_release == 0
          personal_percent = personal_float_salary_deduct / personal_float_salary_release
          personal_percent = BigDecimal(1) if personal_float_salary_release == 0
          if department_percent + department_percent >= 2
            re = BigDecimal(0)
            return get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
          end
          # 部门浮动薪金总和
          performance_bonus_by_department = _calc_bonus_element_amount_by_type(user, month_salary_report, :performance_bonus, :departmental)
          kill_bonus_by_department = _calc_bonus_element_amount_by_type(user, month_salary_report, :kill_bonus, :departmental)
          commission_margin_by_department = _calc_bonus_element_amount_by_type(user, month_salary_report, :commission_margin, :departmental)
          collect_accounts_bonus_by_department = _calc_bonus_element_amount_by_type(user, month_salary_report, :collect_accounts_bonus, :departmental)
          exchange_rate_bonus_by_department = _calc_bonus_element_amount_by_type(user, month_salary_report, :exchange_rate_bonus, :departmental)
          project_bonus_by_department = _calc_bonus_element_amount_by_type(user, month_salary_report, :project_bonus, :departmental)
          department_total = performance_bonus_by_department + kill_bonus_by_department + commission_margin_by_department + collect_accounts_bonus_by_department + exchange_rate_bonus_by_department +
              project_bonus_by_department
          # 部门制结果 = 应发 - 总数 × 百分比
          departmental_result = department_total - department_total * department_percent
          # 个人浮动薪金总和
          performance_bonus = _calc_bonus_element_amount_by_type(user, month_salary_report, :performance_bonus, :personal)
          kill_bonus = _calc_bonus_element_amount_by_type(user, month_salary_report, :kill_bonus, :personal)
          commission_margin = _calc_bonus_element_amount_by_type(user, month_salary_report, :commission_margin, :personal)
          collect_accounts_bonus = _calc_bonus_element_amount_by_type(user, month_salary_report, :collect_accounts_bonus, :personal)
          exchange_rate_bonus = _calc_bonus_element_amount_by_type(user, month_salary_report, :exchange_rate_bonus, :personal)
          project_bonus = _calc_bonus_element_amount_by_type(user, month_salary_report, :project_bonus, :personal)
          personal_total = performance_bonus + kill_bonus + commission_margin + collect_accounts_bonus + exchange_rate_bonus + project_bonus
          # 结果 = 应发 - 总数 × 百分比
          personal_result = personal_total - personal_total * personal_percent
          # 部门制个人制总和
          re = departmental_result + personal_result
          # 更新处分记录
          punishment.update(salary_deduct_status: :true)
          get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
        else
          re = find_or_create_by(221, user, month_salary_report, salary_type, resignation_record_id)
          get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
        end

      end
    end

    #id: 213 除底薪外_其他扣減：默認為空，支持表格中手動輸入修改；
    def calc_except_for_basic_salary_other_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = nil
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 214 除底薪外_考勤補扣：根據考勤補薪的數據（補薪記錄）自動計算所有相關金額：「215 ~ 227」的補記錄﹣「213」的扣記錄；
    def calc_except_for_basic_salary_attendance_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        # 计算198扣记录
        deduct_total = BigDecimal(0)

        add = find_or_create_add_info_by(36, user, month_salary_report) - find_or_create_deduct_info_by(36, user, month_salary_report)
        add = add < 0 ? add : 0
        add = add * 100 rescue BigDecimal(0)
        deduct_total += add

        # 计算200～211补记录
        add_total = BigDecimal(0)
        add = find_or_create_add_info_by(17, user, month_salary_report) - find_or_create_deduct_info_by(17, user, month_salary_report)
        add = add > 0 ? add : 0
        # 200补 = 矿工200 × (42津贴 + 部门浮动薪金)/30 + 200矿工 × 1500
        add = add *(find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)) / 30 +
            add * 1500
        add_total += add

        add = find_or_create_add_info_by(19, user, month_salary_report) - find_or_create_deduct_info_by(19, user, month_salary_report)
        add = add > 0 ? add : 0
        # 201补 = 即告201补天数 × (42津贴 + 部门浮动薪金) + 即告201补天数 × 1000
        add = add *(find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)) / 30 +
            add * 1000
        add_total += add

        add = find_or_create_add_info_by(18, user, month_salary_report) - find_or_create_deduct_info_by(18, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add *(find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)) / 30 +
            add * 500
        add_total += add

        add = find_or_create_add_info_by(20, user, month_salary_report) - find_or_create_deduct_info_by(20, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add *(find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)) / 30 +
            add * 250
        add_total += add

        add = find_or_create_add_info_by(21, user, month_salary_report) - find_or_create_deduct_info_by(21, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add *(find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)) / 30 +
            add * 250
        add_total += add

        add = find_or_create_add_info_by(25, user, month_salary_report) - find_or_create_deduct_info_by(25, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add *
            (find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
                find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id) +
                _calc_department_bonus(user, month_salary_report)) / 30
        add_total += add

        add = find_or_create_add_info_by(22, user, month_salary_report) - find_or_create_deduct_info_by(22, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add * (find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_department_bonus(user, month_salary_report)) / 30
        add_total += add

        add = find_or_create_add_info_by(28, user, month_salary_report) - find_or_create_deduct_info_by(28, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add * _calc_department_bonus(user, month_salary_report) / 30 +
            add * (find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
                find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id)) / 30 / 3
        add_total += add

        add = find_or_create_add_info_by(29, user, month_salary_report) - find_or_create_deduct_info_by(17, user, month_salary_report)
        add = add > 0 ? add : 0
        add = add *(find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id)+
            find_or_create_by(51, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(48, user, month_salary_report, salary_type, resignation_record_id) +
            _calc_all_bonus(user, month_salary_report)
        ) / 30
        add_total += add


        add_1 = find_or_create_add_info_by(24, user, month_salary_report) - find_or_create_deduct_info_by(24, user, month_salary_report)
        add_1 = add_1 > 0 ? add_1 : 0
        add_2 = find_or_create_add_info_by(23, user, month_salary_report) - find_or_create_deduct_info_by(23, user, month_salary_report)
        add_2 = add_2 > 0 ? add_2 : 0

        add = add_1 * 500 + add_2 * 250
        add_total += add


        add_1 = find_or_create_add_info_by(30, user, month_salary_report) - find_or_create_deduct_info_by(30, user, month_salary_report)
        add_1 = add_1 > 0 ? add_1 : 0
        add_2 = find_or_create_add_info_by(31, user, month_salary_report) - find_or_create_deduct_info_by(31, user, month_salary_report)
        add_2 = add_2 > 0 ? add_2 : 0
        add_3 = find_or_create_add_info_by(32, user, month_salary_report) - find_or_create_deduct_info_by(32, user, month_salary_report)
        add_3 = add_3 > 0 ? add_3 : 0
        add_4 = find_or_create_add_info_by(33, user, month_salary_report) - find_or_create_deduct_info_by(33, user, month_salary_report)
        add_4 = add_4 > 0 ? add_4 : 0

        add = add_1 * 250 + add_2 * 250 + add_3 * 500 + add_4 * 750
        add_total += add


        add_1 = find_or_create_add_info_by(10, user, month_salary_report) - find_or_create_deduct_info_by(10, user, month_salary_report)
        add_1 = add_1 > 0 ? add_1 : 0
        add_2 = find_or_create_add_info_by(11, user, month_salary_report) - find_or_create_deduct_info_by(11, user, month_salary_report)
        add_2 = add_2 > 0 ? add_2 : 0

        add = (add_1 + add_2) * 300
        add_total += add

        re = deduct_total.abs + add_total.abs

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 215 除底薪外_總扣減：計算＝「215」＋「216」＋「217」＋「218」＋「219」＋「220」＋「221」＋「222」＋「223」＋「224」＋「225」＋「226」＋「227」＋「228」＋「229」+「230」；
    def calc_except_for_basic_salary_total_deduction(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(200, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(201, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(202, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(203, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(204, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(205, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(206, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(207, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(208, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(209, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(210, user, month_salary_report, salary_type, resignation_record_id) +
            find_or_create_by(211, user, month_salary_report, salary_type, resignation_record_id) +
            math_add(find_or_create_by(212, user, month_salary_report, salary_type, resignation_record_id))+
            (math_add(find_or_create_by(213, user, month_salary_report, salary_type, resignation_record_id)) || BigDecimal(0)) +
            find_or_create_by(214, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 216 除底薪外_其他(不納稅)：默認為空，支持表格中手動輸入修改；
    def calc_except_for_basic_salary_other_non_tax(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = nil
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 217 除底薪外_扣其他(不納稅)：默認為空，支持表格中手動輸入修改；
    def calc_except_for_basic_salary_deduct_other_non_tax(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = nil
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 218 除底薪外_總數實發：計算＝「214」﹣「231」＋「232」﹣「233」；
    def calc_except_for_basic_salary_except_for_basic_salary_real_total(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(199, user, month_salary_report, salary_type, resignation_record_id) -
            find_or_create_by(215, user, month_salary_report, salary_type, resignation_record_id) +
            math_add(find_or_create_by(216, user, month_salary_report, salary_type, resignation_record_id))-
            math_add(find_or_create_by(217, user, month_salary_report, salary_type, resignation_record_id))
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end


    #id: 1001： 职位； {152：粮单职位: no_order: 169}
    def calc_pay_slip_1(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(152, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1002： 薪酬期间； {144：薪酬开始日期; no_order: 160}； {145 薪酬结束日期: no_order: 161}
    def calc_pay_slip_2(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        salary_begin = find_or_create_by(144, user, month_salary_report, salary_type, resignation_record_id)
        salary_end = find_or_create_by(145, user, month_salary_report, salary_type, resignation_record_id)
        re = "由 From : #{salary_begin.strftime('%y/%m/%d')}         至 To : #{salary_end.strftime('%y/%m/%d')}" rescue ''
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1003： 底薪（mop）;  {}39:底薪； no_order: 39}
    def calc_pay_slip_3(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = hkd_to_mop(find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id))
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1004： 加班費； {168：底薪_加班費(MOP); no_order:184}
    def calc_pay_slip_4(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(168, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1005: 強制假期補償; {166:底薪_強制性假期補償(MOP): no_order:  182}
    def calc_pay_slip_5(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(166, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1006:公眾假期補償; {167:底薪_公眾假期補償(MOP): no_order: 183}
    def calc_pay_slip_6(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(167, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1007:年假補償; {172:底薪_未享受年假補償(MOP): no_order: 187}
    def calc_pay_slip_7(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(172, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1008:其他薪酬項目; {170:底薪_其他加項(MOP); no_order: 185} {171:底薪_考勤補發(MOP); no_order: 186} {173:底薪_解僱賠償(MOP); no_order: 188} {174:底薪_代通知金(MOP): no_order: 189}
    def calc_pay_slip_8(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = math_add(find_or_create_by(170, user, month_salary_report, salary_type, resignation_record_id)) +
          math_add(find_or_create_by(171, user, month_salary_report, salary_type, resignation_record_id)) +
          math_add(find_or_create_by(173, user, month_salary_report, salary_type, resignation_record_id)) +
          math_add(find_or_create_by(174, user, month_salary_report, salary_type, resignation_record_id))
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1009:總薪酬; {175:總薪酬; no_order: 190} {224:實習津貼: no_order: 57}
    def calc_pay_slip_9(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = math_add(find_or_create_by(175, user, month_salary_report, salary_type, resignation_record_id)) -
          math_add(find_or_create_by(224, user, month_salary_report, salary_type, resignation_record_id))
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1010:曠工; {176:底薪_曠工扣減(MOP); no_order: 191}
    def calc_pay_slip_10(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(176, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1011:即告; {177:底薪_即告扣減(MOP): no_order: 192}
    def calc_pay_slip_11(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(177, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1012:無薪假; {178:底薪_無薪假扣減(MOP): no_order: 193}
    def calc_pay_slip_12(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(178, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end


    #id: 1013:無薪婚假; {179:底薪_無薪婚假扣減(MOP); no_order: 194}
    def calc_pay_slip_13(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(179, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1014:無薪帛事假; {180:底薪_無薪恩恤假扣減(MOP); no_order: 195}
    def calc_pay_slip_14(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(180, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1015:.無薪分娩假; {182:底薪_無薪分娩假扣減(MOP); no_order: 197}
    def calc_pay_slip_15(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(182, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1016:停職; {184:底薪_停薪留職扣減(MOP); no_order: 199}
    def calc_pay_slip_16(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(184, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1017:其他扣減項目; {181:底薪_懷孕病假(MOP); no_order: 196}; {183:底薪_工傷(7天後)扣減(MOP); no_order: 198}; {185:底薪_其他扣減(MOP); no_order: 200}; {186:底薪_考勤補扣(MOP); no_order: 201}
    def calc_pay_slip_17(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = math_add(find_or_create_by(181, user, month_salary_report, salary_type, resignation_record_id))+
          math_add(find_or_create_by(183, user, month_salary_report, salary_type, resignation_record_id))+
          math_add(find_or_create_by(185, user, month_salary_report, salary_type, resignation_record_id))+
          math_add(find_or_create_by(186, user, month_salary_report, salary_type, resignation_record_id))
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1018:總扣減; {187:底薪_總扣減(MOP); no_order: 202}
    def calc_pay_slip_18(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(187, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1019:實習津貼; {224:實習津貼; no_order: 57}
    def calc_pay_slip_19(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = hkd_to_mop(find_or_create_by(224, user, month_salary_report, salary_type, resignation_record_id))
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end


    #id: 1020:醫療報銷; {188:醫療報銷(MOP); no_order: 203}
    def calc_pay_slip_20(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(188, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end


    #id: 1021:其他; {189:其他(不納稅)(MOP); no_order: 204}
    def calc_pay_slip_21(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = math_add(find_or_create_by(189, user, month_salary_report, salary_type, resignation_record_id))
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end


    #id: 1022:醫療福利基金; {191:扣醫療基金(MOP); no_order: 206}
    def calc_pay_slip_22(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(191, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1023:公積金供款; {193:扣公積金(MOP); no_order: 208}
    def calc_pay_slip_23(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(193, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1024:太陽城愛心基金; {190:扣愛心基金(MOP); no_order: 205}
    def calc_pay_slip_24(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(190, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1025:其他; {194:扣其他(不納稅)(MOP); no_order: 209}
    def calc_pay_slip_25(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = math_add(find_or_create_by(194, user, month_salary_report, salary_type, resignation_record_id))
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1026:實收金額; {195:底薪_總數實發(MOP); no_order: 210}
    def calc_pay_slip_26(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(195, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1027津貼; {42津貼; no_order: 42}
    def calc_pay_slip_27(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1028:勤工;{45:勤工; no_order: 45}
    def calc_pay_slip_28(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1029:房屋津貼;{48:房屋津貼; no_order: 48}
    def calc_pay_slip_29(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(48, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1030:地區津貼;{51:地區津貼; no_order: 51}
    def calc_pay_slip_30(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(51, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1031:服務獎金;{221:服務津貼; no_order: 54}
    def calc_pay_slip_31(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(221, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1032:茶資;{56:茶資; no_order: 62}
    def calc_pay_slip_32(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(56, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1033:殺數分紅;{69:殺數分紅; no_order: 75}
    def calc_pay_slip_33(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(69, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1034:業績分紅;{74:業績分紅; no_order: 80}
    def calc_pay_slip_34(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(74, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1035:佣金差額;{64:佣金差額; no_order: 70}
    def calc_pay_slip_35(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(64, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end


    #id: 1036:刷卡獎金;{79:刷卡獎金; no_order: 85}
    def calc_pay_slip_36(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(79, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               re
             else
               mop_to_hkd re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end


    #id: 1037:貴賓卡消費;{84:貴賓卡消費; no_order: 90}
    def calc_pay_slip_37(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(84, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end


    #id: 1038:收賬分紅;{89:收賬分紅; no_order: 95}
    def calc_pay_slip_38(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(89, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1039:匯率分紅;{94:匯率分紅; no_order: 100}
    def calc_pay_slip_39(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(94, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1040:項目分紅;{99:項目分紅; no_order: 105}
    def calc_pay_slip_40(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(99, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1041:績效獎金;{229:績效獎金; no_order: 127}
    def calc_pay_slip_41(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(229, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1042:特別茶資;{234:特別茶資; no_order: 132}
    def calc_pay_slip_42(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(234, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1043:尊華殿獎金;{104:尊華殿; no_order: 110}
    def calc_pay_slip_43(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(104, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1044:尚品獎金;{109:尚品獎金; no_order: 115}
    def calc_pay_slip_44(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(109, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end


        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1045:出車獎金;{110:出車獎金; no_order: 116}
    def calc_pay_slip_45(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(110, user, month_salary_report, salary_type, resignation_record_id)
        if user.company_name == 'suncity_group_commercial_consulting'
          hkd_to_mop(re)
        else
          re
        end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1046:介紹新客戶轉碼分紅;{111:介紹新客戶轉碼分紅; no_order: 117}
    def calc_pay_slip_46(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(111, user, month_salary_report, salary_type, resignation_record_id)
        if user.company_name == 'suncity_group_commercial_consulting'
          hkd_to_mop(re)
        else
          re
        end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1047:其他;{116:新春利是; no_order: 122};{196:除底薪外_其他加項; no_order: 211};{197:除底薪外_考勤補發; no_order: 212};{198:除底薪外_颱風津貼; no_order: 213}
    def calc_pay_slip_47(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(116, user, month_salary_report, salary_type, resignation_record_id) +
          math_add(find_or_create_by(196, user, month_salary_report, salary_type, resignation_record_id))+
          find_or_create_by(197, user, month_salary_report, salary_type, resignation_record_id) +
          (find_or_create_by(198, user, month_salary_report, salary_type, resignation_record_id) || BigDecimal(0))
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1048:總薪酬;{199:除底薪外_總薪酬; no_order: 214}
    def calc_pay_slip_48(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(199, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1049:遲到;{210:除底薪外_遲到扣減; no_order: 226}
    def calc_pay_slip_49(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(210, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1050:曠工;{200:除底薪外_曠工扣減; no_order: 215}
    def calc_pay_slip_50(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(200, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1051:即告;{201:除底薪外_即告扣減; no_order: 216}
    def calc_pay_slip_51(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(201, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1052:無薪假;{202:除底薪外_無薪假扣減; no_order: 217}
    def calc_pay_slip_52(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(202, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1053:無薪婚假;{203:除底薪外_無薪婚假扣減; no_order: 218}
    def calc_pay_slip_53(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(203, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1054:無薪帛事假;{204:除底薪外_無薪恩恤假扣減; no_order: 219}
    def calc_pay_slip_54(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(204, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1055:有薪病假;{209:除底薪外_有薪病假扣減; no_order: 225}
    def calc_pay_slip_55(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(209, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1056:漏打上班/下班;{211:除底薪外_漏打卡上下班扣減; no_order: 227}
    def calc_pay_slip_56(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(211, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end

        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1057:收到處罰通知書;{212:除底薪外_處罰通知書扣減; no_order: 228}
    def calc_pay_slip_57(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(212, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1058:有薪分娩假;{236:除底薪外_有薪分娩假扣減; no_order: 220}
    def calc_pay_slip_58(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(236, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1059:無薪分娩假;{205除底薪外_無薪分娩假扣減; no_order: 221}
    def calc_pay_slip_59(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(205, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1060:停職;{208:除底薪外_停薪留職扣減; no_order: 224}
    def calc_pay_slip_60(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(208, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1061:其他扣減項目;{206:除底薪外_懷孕病假扣減; no_order: 222};{207:除底薪外_工傷(7天後)扣減; no_order: 223};{213:除底薪外_其他扣減; no_order: 229};{214:除底薪外_考勤補扣; no_order: 230}
    def calc_pay_slip_61(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(206, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(207, user, month_salary_report, salary_type, resignation_record_id) +
          math_add(find_or_create_by(213, user, month_salary_report, salary_type, resignation_record_id))+
          find_or_create_by(214, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1062:總扣減;{215:除底薪外_總扣減; no_order: 231}
    def calc_pay_slip_62(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(215, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1063:實收金額;{218:除底薪外_總數實發; no_order: 234}
    def calc_pay_slip_63(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(218, user, month_salary_report, salary_type, resignation_record_id)
        re = if user.company_name == 'suncity_group_commercial_consulting'
               hkd_to_mop(re)
             else
               re
             end
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1064:年假剩餘天數;{12:年假剩余天数; no_order: 12}
    def calc_pay_slip_64(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(12, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1065:有薪病假剩餘天數；{13：有薪病假剩餘天數; no_order: 13}
    def calc_pay_slip_65(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(13, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1066:考勤備註
    def calc_pay_slip_66(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = []
        sign_card_in = find_or_create_by(10, user, month_salary_report, salary_type, resignation_record_id)
        re << (sign_card_in > 0 ? "漏打卡上班#{sign_card_in}次" : '')
        sign_card_out = find_or_create_by(11, user, month_salary_report, salary_type, resignation_record_id)
        re << (sign_card_out > 0 ? "漏打卡下班#{sign_card_out}次" : '')
        mandatory_holiday_days_compensation_leave = find_or_create_by(15, user, month_salary_report, salary_type, resignation_record_id)
        re << (mandatory_holiday_days_compensation_leave > 0 ? "強制性假期(補假)#{mandatory_holiday_days_compensation_leave}天" : '')
        mandatory_holiday_days_compensation_salary = find_or_create_by(14, user, month_salary_report, salary_type, resignation_record_id)
        re << (mandatory_holiday_days_compensation_salary > 0 ? "強制性假期(補薪)#{mandatory_holiday_days_compensation_salary}天" : '')
        public_holiday_days_compensation_salary = find_or_create_by(16, user, month_salary_report, salary_type, resignation_record_id)
        re << (public_holiday_days_compensation_salary > 0 ? "公眾假期(補薪)#{public_holiday_days_compensation_salary}天" : '')
        absenteeism_days = find_or_create_by(17, user, month_salary_report, salary_type, resignation_record_id)
        re << (absenteeism_days > 0 ? "曠工#{absenteeism_days}天" : '')
        no_pay_leave_days = find_or_create_by(18, user, month_salary_report, salary_type, resignation_record_id)
        re << (no_pay_leave_days > 0 ? "無薪假#{no_pay_leave_days}天" : '')
        same_day_leave_days = find_or_create_by(19, user, month_salary_report, salary_type, resignation_record_id)
        re << (same_day_leave_days > 0 ? "即告#{same_day_leave_days}天" : '')
        marriage_leave_without_pay_days = find_or_create_by(20, user, month_salary_report, salary_type, resignation_record_id)
        re << (marriage_leave_without_pay_days > 0 ? "無薪婚假#{marriage_leave_without_pay_days}天" : '')
        unpaid_compassionate_leave_days = find_or_create_by(21, user, month_salary_report, salary_type, resignation_record_id)
        re << (unpaid_compassionate_leave_days > 0 ? "無薪恩恤假#{unpaid_compassionate_leave_days}天" : '')
        pregnant_sick_leave_days = find_or_create_by(22, user, month_salary_report, salary_type, resignation_record_id)
        re << (pregnant_sick_leave_days > 0 ? "懷孕病假#{pregnant_sick_leave_days}天" : '')
        paid_continuous_sick_days = find_or_create_by(24, user, month_salary_report, salary_type, resignation_record_id)
        re << (paid_continuous_sick_days > 0 ? "連off有薪病假#{paid_continuous_sick_days}天" : '')
        paid_discountinous_sick_days = find_or_create_by(23, user, month_salary_report, salary_type, resignation_record_id)
        re << (paid_discountinous_sick_days > 0 ? "不連off有薪病假#{paid_discountinous_sick_days}天" : '')
        maternity_leave_without_pay_days = find_or_create_by(25, user, month_salary_report, salary_type, resignation_record_id)
        re << (maternity_leave_without_pay_days > 0 ? "無薪分娩假#{maternity_leave_without_pay_days}天" : '')
        paid_maternity_leave_days = find_or_create_by(26, user, month_salary_report, salary_type, resignation_record_id)
        re << (paid_maternity_leave_days > 0 ? "有薪分娩假#{paid_maternity_leave_days}天" : '')
        work_injury_days_first_7_days = find_or_create_by(27, user, month_salary_report, salary_type, resignation_record_id)
        re << (work_injury_days_first_7_days > 0 ? "工傷(首7天)#{work_injury_days_first_7_days}天" : '')
        work_injury_days_7_days_later = find_or_create_by(28, user, month_salary_report, salary_type, resignation_record_id)
        re << (work_injury_days_7_days_later > 0 ? "工傷(7天後)#{work_injury_days_7_days_later}天" : '')
        leave_without_pay_days = find_or_create_by(29, user, month_salary_report, salary_type, resignation_record_id)
        re << (leave_without_pay_days > 0 ? "停薪留職#{leave_without_pay_days}天" : '')
        late_times_less_than_or_equal_to_10 = find_or_create_by(30, user, month_salary_report, salary_type, resignation_record_id)
        re << (late_times_less_than_or_equal_to_10 > 0 ? "遲到(小於等於10)#{late_times_less_than_or_equal_to_10}次" : '')
        late_times_less_than_or_equal_to_20 = find_or_create_by(31, user, month_salary_report, salary_type, resignation_record_id)
        re << (late_times_less_than_or_equal_to_20 > 0 ? "遲到(小於等於20)#{late_times_less_than_or_equal_to_20}次" : '')
        late_times_less_than_or_equal_to_30 = find_or_create_by(32, user, month_salary_report, salary_type, resignation_record_id)
        re << (late_times_less_than_or_equal_to_30 > 0 ? "遲到(小於等於30)#{late_times_less_than_or_equal_to_30}次" : '')
        late_times_greater_than_30 = find_or_create_by(33, user, month_salary_report, salary_type, resignation_record_id)
        re << (late_times_greater_than_30 > 0 ? "遲到(大於30)#{late_times_greater_than_30}次" : '')
        weekdays_overtime_hours = find_or_create_by(34, user, month_salary_report, salary_type, resignation_record_id)
        re << (weekdays_overtime_hours > 0 ? "平日加班#{weekdays_overtime_hours}小時" : '')
        holiday_overtime_hours = find_or_create_by(35, user, month_salary_report, salary_type, resignation_record_id)
        re << (holiday_overtime_hours > 0 ? "假日加班#{holiday_overtime_hours}小時" : '')
        typhoon_work_days = find_or_create_by(36, user, month_salary_report, salary_type, resignation_record_id)
        re << (typhoon_work_days > 0 ? "颱風上班#{typhoon_work_days}天" : '')
        re = re.select{|item| item && !item.empty? }.join(',')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1067:考勤補發備註
    def calc_pay_slip_67(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re_add = []
        re_deduct = []
        unless find_or_create_add_info_by(10, user, month_salary_report) == 0
          add = find_or_create_add_info_by(10, user, month_salary_report) - find_or_create_by(10, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_漏打卡上班#{add}次"
          elsif add < 0
            re_deduct << "扣_漏打卡上班#{add.abs}次"
          end
        end

        unless find_or_create_add_info_by(11, user, month_salary_report) == 0
          add = find_or_create_add_info_by(11, user, month_salary_report) - find_or_create_by(11, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_漏打卡下班#{add}次"
          elsif add < 0
            re_deduct << "扣_漏打卡下班#{add.abs}次"
          end
        end


        unless find_or_create_add_info_by(17, user, month_salary_report) == 0
          add = find_or_create_add_info_by(17, user, month_salary_report) - find_or_create_by(17, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_曠工#{add}天"
          elsif add < 0
            re_deduct << "扣_曠工#{add.abs}天"
          end
        end

        unless find_or_create_add_info_by(18, user, month_salary_report) == 0
          add = find_or_create_add_info_by(18, user, month_salary_report) - find_or_create_by(18, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_無薪假#{add}天"
          elsif add < 0
            re_deduct << "扣_無薪假#{add.abs}天"
          end
        end

        unless find_or_create_add_info_by(19, user, month_salary_report) == 0
          add = find_or_create_add_info_by(19, user, month_salary_report) - find_or_create_by(19, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_即告#{add}天"
          elsif add < 0
            re_deduct << "扣_即告#{add.abs}天"
          end
        end

        unless find_or_create_add_info_by(20, user, month_salary_report) == 0
          add = find_or_create_add_info_by(20, user, month_salary_report) - find_or_create_by(20, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_無薪婚假#{add}天"
          elsif add < 0
            re_deduct << "扣_無薪婚假#{add.abs}天"
          end
        end

        unless find_or_create_add_info_by(21, user, month_salary_report) == 0
          add = find_or_create_add_info_by(21, user, month_salary_report) - find_or_create_by(21, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_無薪恩恤假#{add}天"
          elsif add < 0
            re_deduct << "扣_無薪恩恤假#{add.abs}天"
          end
        end


        unless find_or_create_add_info_by(22, user, month_salary_report) == 0
          add = find_or_create_add_info_by(22, user, month_salary_report) - find_or_create_by(22, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_懷孕病假#{add}天"
          elsif add < 0
            re_deduct << "扣_懷孕病假#{add.abs}天"
          end
        end


        unless find_or_create_add_info_by(23, user, month_salary_report) == 0
          add = find_or_create_add_info_by(23, user, month_salary_report) - find_or_create_by(23, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_不連off有薪病假#{add}天"
          elsif add < 0
            re_deduct << "扣_不連off有薪病假#{add.abs}天"
          end
        end


        unless find_or_create_add_info_by(24, user, month_salary_report) == 0
          add = find_or_create_add_info_by(24, user, month_salary_report) - find_or_create_by(24, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_連off有薪病假#{add}天"
          elsif add < 0
            re_deduct << "扣_連off有薪病假#{add.abs}天"
          end
        end


        unless find_or_create_add_info_by(25, user, month_salary_report) == 0
          add = find_or_create_add_info_by(25, user, month_salary_report) - find_or_create_by(25, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_無薪分娩假#{add}天"
          elsif add < 0
            re_deduct << "扣_無薪分娩假#{add.abs}天"
          end
        end

        unless find_or_create_add_info_by(26, user, month_salary_report) == 0
          add = find_or_create_add_info_by(26, user, month_salary_report) - find_or_create_by(26, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_有薪分娩假#{add}天"
          elsif add < 0
            re_deduct << "扣_有薪分娩假#{add.abs}天"
          end
        end


        unless find_or_create_add_info_by(28, user, month_salary_report) == 0
          add = find_or_create_add_info_by(28, user, month_salary_report) - find_or_create_by(28, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_工傷(7天後)#{add}天"
          elsif add < 0
            re_deduct << "扣_工傷(7天後)#{add.abs}天"
          end
        end


        unless find_or_create_add_info_by(29, user, month_salary_report) == 0
          add = find_or_create_add_info_by(29, user, month_salary_report) - find_or_create_by(29, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_停薪留職#{add}天"
          elsif add < 0
            re_deduct << "扣_停薪留職#{add.abs}天"
          end
        end


        unless find_or_create_add_info_by(30, user, month_salary_report) == 0
          add = find_or_create_add_info_by(30, user, month_salary_report) - find_or_create_by(30, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_遲到(小於等於10)#{add}次"
          elsif add < 0
            re_deduct << "扣_遲到(小於等於10)#{add.abs}次"
          end
        end
        unless find_or_create_add_info_by(31, user, month_salary_report) == 0
          add = find_or_create_add_info_by(31, user, month_salary_report) - find_or_create_by(31, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_遲到(小於等於20)#{add}次"
          elsif add < 0
            re_deduct << "扣_遲到(小於等於20)#{add.abs}次"
          end
        end
        unless find_or_create_add_info_by(32, user, month_salary_report) == 0
          add = find_or_create_add_info_by(32, user, month_salary_report) - find_or_create_by(32, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_遲到(小於等於30)#{add}次"
          elsif add < 0
            re_deduct << "扣_遲到(小於等於30)#{add.abs}次"
          end

        end
        unless find_or_create_add_info_by(33, user, month_salary_report) == 0

          add = find_or_create_add_info_by(33, user, month_salary_report) - find_or_create_by(33, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_遲到(大於30)#{add}次"
          elsif add < 0
            re_deduct << "扣_遲到(大於30)#{add.abs}次"
          end
        end
        unless find_or_create_add_info_by(34, user, month_salary_report) == 0

          add = find_or_create_add_info_by(34, user, month_salary_report) - find_or_create_by(34, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_平日加班#{add}小時"
          elsif add < 0
            re_deduct << "扣_平日加班#{add.abs}小時"
          end
        end
        unless find_or_create_add_info_by(35, user, month_salary_report) == 0
          add = find_or_create_add_info_by(35, user, month_salary_report) - find_or_create_by(35, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_假日加班#{add}小時"
          elsif add < 0
            re_deduct << "扣_假日加班#{add.abs}小時"
          end

        end
        unless find_or_create_add_info_by(36, user, month_salary_report) == 0
          add = find_or_create_add_info_by(36, user, month_salary_report) - find_or_create_by(36, user, month_salary_report, salary_type, resignation_record_id)
          if add > 0
            re_add << "補_颱風上班#{add}天"
          elsif add < 0
            re_deduct << "扣_颱風上班#{add.abs}天"
          end
        end

        re = [re_add, re_deduct].flatten.join(',')
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end


    #id: 1068:其他項目備註
    def calc_pay_slip_68(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = nil
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1069:職業稅;{146:職業稅(MOP); no_order: 163}
    def calc_pay_slip_69(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(146, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    #id: 1070:社會保證金員工應繳;{147:社會保障金(MOP); no_order: 164}
    def calc_pay_slip_70(user, month_salary_report, salary_type, salary_column_id, key, value_type, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = find_or_create_by(147, user, month_salary_report, salary_type, resignation_record_id)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    def get_month_attend_days(user, year_month, attribute)
      attend_month_report = user.attend_month_reports.find_by(year: year_month.year, month: year_month.month)
      # TODO 计算中的记录处理
      return  attend_month_report.try(attribute) if attend_month_report
      0
    end

    def get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      create_salary_value(user, month_salary_report, salary_column_id, salary_type, resignation_record_id).update("#{value_type}_value" => re)
      re
    end

    def mop_to_hkd(mop = BigDecimal(0))
      mop / 1.03
    end

    def hkd_to_mop(hkd = BigDecimal(0))
      hkd * 1.03
    end

    def cache_key_prefix(user, month_salary_report, key, resignation_record_id = nil)
      if resignation_record_id
        "#{user.id}/#{month_salary_report.year_month.month}/#{user.updated_at}-#{key}/#{resignation_record_id}"
      else
        "#{user.id}/#{month_salary_report.year_month.month}/#{user.updated_at}-#{key}"
      end

    end

    def cache_key_prefix_by_year_month(user, year_month, key, resignation_record_id = nil)
      if resignation_record_id
        "#{user.id}/#{year_month.month}/#{user.updated_at}-#{key}/#{resignation_record_id}"
      else
        "#{user.id}/#{year_month.month}/#{user.updated_at}-#{key}"
      end
    end

    def find_salary_value(user, month_salary_report, salary_column_id, salary_type, value_type)
      value = "#{value_type}_value".to_sym
      SalaryValue.find_by(user_id: user.id, year_month: month_salary_report.year_month, salary_column_id: salary_column_id, salary_type: salary_type).try(:value)
    end

    def create_salary_value(user, month_salary_report, salary_column_id, salary_type, resignation_record_id)
      SalaryValue.find_or_create_by(user_id: user.id, year_month: month_salary_report.year_month, salary_column_id: salary_column_id, salary_type: salary_type, resignation_record_id: resignation_record_id)
    end

    def get_attend_monthly_report(user, month_salary_report)
      attend_monthly_report = AttendMonthlyReport.find_by(
          user_id: user.id,
          year: month_salary_report.year_month.year,
          month: month_salary_report.year_month.month
      )
      attend_monthly_report
    end

    # 加载考勤相关日期到计算器memory
    def load_attend_days_to_calculator_store(user, month_salary_report, attend_monthly_report = nil)
      attend_monthly_report = get_attend_monthly_report(user, month_salary_report) unless attend_monthly_report
      calc = Dentaku::Calculator.new
      unless attend_monthly_report
        AttendMonthlyReport.create_params.each do |attribute|
          calc.store(attribute => 0)
        end
        return calc
      end
      if attend_monthly_report.status == 2
        calc.store(attend_monthly_report.as_json)
      else
        user_id = attend_monthly_report.user_id
        year = attend_monthly_report.year
        month = attend_monthly_report.month
        {
            # 簽卡漏打卡上班次數
            signcard_forget_to_punch_in_counts: AttendMonthlyReport.get_sign_card_counts_for('forget_to_punch_in', user_id, year, month, start_date = nil, end_date = nil),
            # 簽卡漏打卡下班次數
            signcard_forget_to_punch_out_counts: AttendMonthlyReport.get_sign_card_counts_for('forget_to_punch_out', user_id, year, month, start_date = nil, end_date = nil),
            # 強制性假日補錢天數
            force_holiday_for_money_counts: AttendMonthlyReport.get_holiday_counts('force_holiday', user_id, year, month, start_date = nil, end_date = nil),
            # 強制性假日補假天數
            force_holiday_for_leave_counts: AttendMonthlyReport.get_holiday_counts('force_holiday', user_id, year, month, start_date = nil, end_date = nil),
            # 公眾假日補薪天數
            public_holiday_counts: AttendMonthlyReport.get_holiday_counts('public_holiday', user_id, year, month, start_date = nil, end_date = nil),
            # 遲到超過120次數
            late_mins_more_than_120: AttendMonthlyReport.get_late_counts_between(120, 10080, user_id, year, month),
            # 曠工天數
            absenteeism_counts: AttendMonthlyReport.get_leave_counts_for('absenteeism', user_id, year, month, start_date = nil, end_date = nil),
            # 考勤異常導致曠工天數
            absenteeism_from_exception_counts: AttendMonthlyReport.get_absenteeism_from_exception_counts(user_id, year, month, start_date = nil, end_date = nil),
            # 無薪假天數
            unpaid_leave_counts: AttendMonthlyReport.get_leave_counts_for('unpaid_leave', user_id, year, month, start_date = nil, end_date = nil),
            # 無薪病假天數
            unpaid_sick_leave_counts: AttendMonthlyReport.get_leave_counts_for('unpaid_sick_leave', user_id, year, month, start_date = nil, end_date = nil),
            # 即告天數
            immediate_leave_counts: AttendMonthlyReport.get_leave_counts_for('immediate_leave', user_id, year, month, start_date = nil, end_date = nil),
            # 無薪婚假天數
            unpaid_marriage_leave_counts: AttendMonthlyReport.get_leave_counts_for('unpaid_marriage_leave', user_id, year, month, start_date = nil, end_date = nil),
            # 無薪恩恤假天數
            unpaid_compassionate_leave_counts: AttendMonthlyReport.get_leave_counts_for('unpaid_compassionate_leave', user_id, year, month, start_date = nil, end_date = nil),
            # 懷孕病假天數
            pregnant_sick_leave_counts: AttendMonthlyReport.get_leave_counts_for('pregnant_sick_leave', user_id, year, month, start_date = nil, end_date = nil),
            # 病假不連off天數
            sick_leave_counts_link_off: AttendMonthlyReport.get_sick_leave_counts_link_off(user_id, year, month, start_date = nil, end_date = nil),
            # 病假連off天數天數
            sick_leave_counts_not_link_off: AttendMonthlyReport.get_sick_leave_counts_not_link_off(user_id, year, month, start_date = nil, end_date = nil),
            # 無薪分娩假天數
            unpaid_maternity_leave_counts: AttendMonthlyReport.get_leave_counts_for('unpaid_maternity_leave', user_id, year, month, start_date = nil, end_date = nil),
            # 有薪分娩假天數
            paid_maternity_leave_counts: AttendMonthlyReport.get_leave_counts_for('paid_maternity_leave', user_id, year, month, start_date = nil, end_date = nil),
            # 工傷(首7天)天數
            work_injury_before_7_counts: AttendMonthlyReport.get_work_injury_counts(user_id, year, month, start_date = nil, end_date = nil),
            # 工傷(7天後)天數
            work_injury_after_7_counts: AttendMonthlyReport.get_work_injury_counts(user_id, year, month, start_date = nil, end_date = nil),
            # 停薪留職天數
            unpaid_but_maintain_position_counts: AttendMonthlyReport.get_leave_counts_for('unpaid_but_maintain_position', user_id, year, month, start_date = nil, end_date = nil),
            # 遲到小於10次數
            late_mins_less_than_10: AttendMonthlyReport.get_late_counts_between(0, 10, user_id, year, month, start_date = nil, end_date = nil),
            # 遲到小於20次數
            late_mins_less_than_20: AttendMonthlyReport.get_late_counts_between(10, 20, user_id, year, month, start_date = nil, end_date = nil),
            # 遲到小於30次數
            late_mins_less_than_30: AttendMonthlyReport.get_late_counts_between(20, 30, user_id, year, month, start_date = nil, end_date = nil),
            # 遲到大於30次數
            late_mins_more_than_30: AttendMonthlyReport.get_late_counts_between(30, 120, user_id, year, month, start_date = nil, end_date = nil),
            # 平日加班時數
            weekdays_overtime_hours: AttendMonthlyReport.get_overtime_counts_for('weekdays', user_id, year, month, start_date = nil, end_date = nil),
            # 車務部加班分鐘(換算成小時，餘數不超過半小時捨去，超過半小時進一位)
            vehicle_department_overtime_mins: AttendMonthlyReport.get_vehicle_department_overtime_mins(user_id, year, month, start_date = nil, end_date = nil),
            # 公休加班時數
            general_holiday_overtime_hours: AttendMonthlyReport.get_overtime_counts_for('general_holiday', user_id, year, month, start_date = nil, end_date = nil),
            # 強制性假日加班時數
            force_holiday_overtime_hours: AttendMonthlyReport.get_overtime_counts_for('force_holiday', user_id, year, month, start_date = nil, end_date = nil),
            # 公眾假日加班時數
            public_holiday_overtime_hours: AttendMonthlyReport.get_overtime_counts_for('public_holiday', user_id, year, month, start_date = nil, end_date = nil),
            # 颱風津貼次數
            typhoon_allowance_counts: AttendMonthlyReport.get_typhoon_allowance_counts( user_id, year, month, start_date = nil, end_date = nil)
        }.each do |column_name, value|
          calc.store(column_name => value.with_indifferent_access[column_name] || 0)
        end
      end
      calc
    end

    # '「39底薪」+「57實習津貼」'
    def basic_salary_and_internship_bonus(user, month_salary_report, salary_type, resignation_record_id = nil)
      basic_salary = find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id) || BigDecimal(0)
      internship_bonus = find_or_create_by(224, user, month_salary_report, salary_type, resignation_record_id) || BigDecimal(0)
      hkd_to_mop(basic_salary + internship_bonus)
    end

    # '「42津貼」+「51地區津貼」+「54服務獎金」'
    def service_award(user, month_salary_report, salary_type, resignation_record_id = nil)
      allowance = find_or_create_by(32, user, month_salary_report, salary_type, resignation_record_id) || BigDecimal(0)
      regional_allowance = find_or_create_by(51, user, month_salary_report, salary_type, resignation_record_id) || BigDecimal(0)
      service_award = find_or_create_by(221, user, month_salary_report, salary_type, resignation_record_id) || BigDecimal(0)
      allowance + regional_allowance + service_award
    end

    def departmental_float_salary(user, month_salary_report)
      approved_float_salary = FloatSalaryMonthEntry.where(status: 'approved', year_month: month_salary_report.year_month).first
      return BigDecimal(0) unless approved_float_salary
      bonus_element_item = approved_float_salary.bonus_element_items.find_by(user_id: user.id)
      return BigDecimal(0) unless bonus_element_item
      result = bonus_element_item.bonus_element_item_values.where(value_type: 'departmental').sum(:amount)
      result
    end

    def personal_float_salary(user, month_salary_report)
      approved_float_salary = FloatSalaryMonthEntry.where(status: 'approved', year_month: month_salary_report.year_month).first
      return BigDecimal(0) unless approved_float_salary
      bonus_element_item = approved_float_salary.bonus_element_items.find_by(user_id: user.id)
      return BigDecimal(0) unless bonus_element_item
      result = bonus_element_item.bonus_element_item_values.where(value_type: 'personal').sum(:amount)
      result
    end

    def attend_about_column_ids_to_evaluate(salary_column_id)
      {
          _10: 'signcard_forget_to_punch_in_counts',
          _11: 'signcard_forget_to_punch_out_counts',
          _12: 'null',
          _13: 'null',
          _14: 'force_holiday_for_money_counts',
          _15: 'force_holiday_for_leave_counts',
          _16: 'public_holiday_counts',
          _17: 'late_mins_more_than_120 + absenteeism_counts + absenteeism_from_exception_counts',
          _18: 'unpaid_leave_counts + unpaid_sick_leave_counts',
          _19: 'immediate_leave_counts',
          _20: 'unpaid_marriage_leave_counts',
          _21: 'unpaid_compassionate_leave_counts',
          _22: 'pregnant_sick_leave_counts',
          _23: 'sick_leave_counts_link_off',
          _24: 'sick_leave_counts_not_link_off',
          _25: 'unpaid_maternity_leave_counts',
          _26: 'paid_maternity_leave_counts',
          _27: 'work_injury_before_7_counts',
          _28: 'work_injury_after_7_counts',
          _29: 'unpaid_but_maintain_position_counts',
          _30: 'late_mins_less_than_10',
          _31: 'late_mins_less_than_20',
          _32: 'late_mins_less_than_30',
          _33: 'late_mins_more_than_30',
          _34: 'weekdays_overtime_hours + round(vehicle_department_overtime_mins / 60)',
          _35: 'general_holiday_overtime_hours + force_holiday_overtime_hours + public_holiday_overtime_hours',
          _36: 'typhoon_allowance_counts'
      }.with_indifferent_access["_#{salary_column_id}"]
    end

    # 计算考勤月报相关
    # user, month_salary_report, salary_type, column.id, column.function.match(/[^[calc_]]\w+/).to_s, column.value_type, resignation_record_id
    def calculate_attend_monthly_report_about(salary_column_hash, attend_monthly_report, user, month_salary_report, salary_type, resignation_record_id = nil)
      calculator = load_attend_days_to_calculator_store(user, month_salary_report, attend_monthly_report)
      (10..36).each do  |salary_column_id|
        unless [12, 13].include? salary_column_id
          column = salary_column_hash[salary_column_id]
          key = column.function.match(/[^[calc_]]\w+/).to_s
          Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
            re = calculator.evaluate(attend_about_column_ids_to_evaluate(salary_column_id))
            get_salary_value(user, month_salary_report, salary_type, salary_column_id, column.value_type, resignation_record_id, re)
          end
        end
      end
    end

    def salary_record_about_id_to_key(salary_column_id)
      case salary_column_id
        when 37, 38, 39
          'final_basic_salary'
        when 40, 41, 42
          'final_bonus'
        when 43, 44, 45
          'final_attendance_award'
        when 46, 47, 48
          'final_house_bonus'
        when 49, 50, 51
          'final_region_bonus'
        when 219, 220, 221
          'final_service_award'
        when 222, 223, 224
          'final_internship_bonus'
        when 52, 53, 54
          'final_tea_bonus'
        when 57, 58, 59
          'final_commission_bonus'
        when 65, 66, 67
          'final_kill_bonus'
        when 70, 71, 72
          'final_performance_bonus'
        when 75, 76, 77
          'final_charge_bonus'
        when 80, 81, 82
          'final_guest_card_bonus'
        when 85, 86, 87
          'final_receive_bonus'
        when 90, 91, 92
          'final_exchange_rate_bonus'
        when 95, 96, 97
          'final_project_bonus'
        when 100, 101, 102
          'final_respect_bonus'
        when 105, 106, 107
          'final_product_bonus'
        when 112, 113, 114
          'final_new_year_bonus'
        when 225, 226, 227
          'final_performance_award'
        when 230, 231, 232
          'final_special_tie_bonus'
      end
    end

    def calculate_original_and_current_salary_record_about(salary_column_hash, user, month_salary_report, salary_type, resignation_record_id = nil)
      original = [37, 40, 43, 46, 49, 219, 222, 52, 57, 65, 70, 75, 80, 85, 90, 95, 100, 105, 112, 225, 230]
      current = [38 ,41 ,44 ,47 ,50 ,220 ,223 ,53 ,58 ,66 ,71 ,76 ,81 ,86 ,91 ,96 ,101 ,106 ,113 ,226 ,231]
      result = [39, 42, 45, 48, 51, 221, 224, 54, 59, 67, 72, 77, 82, 87, 92, 97, 102, 107, 114, 227, 232]
      # calculator = Dentaku::Calculator.new
      salary_begin = find_or_create_by(144, user, month_salary_report, 'on_duty')
      salary_end = find_or_create_by(145, user, month_salary_report, 'on_duty')
      original_salary_record = user.salary_records.where('salary_begin <= :date AND (invalid_date >= :date OR invalid_date IS NULL)', date: salary_begin).first
      original_salary_record = ActiveModelSerializers::SerializableResource.new(original_salary_record).serializer_instance rescue nil
      current_salary_record = user.salary_records.where('salary_begin <= :date AND (invalid_date >= :date OR invalid_date IS NULL)', date: salary_end).first
      current_salary_record = ActiveModelSerializers::SerializableResource.new(current_salary_record).serializer_instance rescue nil
      (37..132).each do |salary_column_id|
        attribuate = salary_record_about_id_to_key(salary_column_id)
        if attribuate
          column = salary_column_hash[salary_column_id]
          key = column.function.match(/[^[calc_]]\w+/).to_s
          target = original_salary_record if original.include? salary_column_id
          target = current_salary_record if current.include? salary_column_id
          if target
            Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
              re = target.
              get_salary_value(user, month_salary_report, salary_type, salary_column_id, column.value_type, resignation_record_id, re)
            end
          end
        end
      end
    end

    # 计算薪酬历史相关
    def calculate_salary_record_about(user, month_salary_report, salary_type, resignation_record_id = nil)
      # 薪酬开始日期
      salary_begin = find_or_create_by(144, user, month_salary_report, 'on_duty')
      # 薪酬结束日期 -> 在职员工每月薪酬，不存在离职记录，薪酬结束一定为月末
      salary_end = find_or_create_by(145, user, month_salary_report, 'on_duty')
      # 加载薪酬历史原纪录
      original_salary_record = user.salary_records.where('salary_begin <= :date AND (invalid_date >= :date OR invalid_date IS NULL)', date: salary_begin).first
      original_salary_record = ActiveModelSerializers::SerializableResource.new(original_salary_record).serializer_instance rescue nil
      # 加载薪酬历史现记录
      current_salary_record = user.salary_records.where('salary_begin <= :date AND (invalid_date >= :date OR invalid_date IS NULL)', date: salary_end).first
      current_salary_record = ActiveModelSerializers::SerializableResource.new(current_salary_record).serializer_instance rescue nil
    end


    def generate(month_salary_report)
      users = ProfileService.users4(month_salary_report.year_month)
                  .includes(:salary_records, :resignation_records)
      # 加载考勤月报
      attend_monthly_reports_hash = AttendMonthlyReport.where(
          user_id: users.ids,
          year: month_salary_report.year_month.year,
          month: month_salary_report.year_month.month
      ).map do |monthly_report|
        [monthly_report.user_id, monthly_report]
      end.to_h
      salary_columns_hash = SalaryColumn.where('id < 900').map do |salary_column|
        [salary_column.id, salary_column]
      end.to_h
      # # 加载浮动薪金（当月已经审批过的浮动薪金）
      # float_salary_month_entry = FloatSalaryMonthEntry.where(year_month: month_salary_report.year_month, status: 'president_examine')
      #                                .includes(:bonus_element_items => :bonus_element_item_values).first rescue nil
      total = users.size
      index = 0
      users.each do |user|
        # 计算考勤月报相关 10-36(不包括12, 13)
        index += 1
        calculate_attend_monthly_report_about(salary_columns_hash, attend_monthly_reports_hash[user.id], user, month_salary_report, 'on_duty')
        SalaryColumn.all.each do |column|
          if column.column_type == 'fixed'
            find_or_create_by(
                column.id,
                user,
                month_salary_report,
                'on_duty'
            )
          end
        end
        month_salary_report.update(generate_process: BigDecimal(index) / BigDecimal(total)) if index % [1, total / 10].max == 0 || index == total
      end
    end

    def generate_leaving_salary_record(month_salary_report, user, resignation_record_id)
      SalaryColumn.all.each do |column|
        if column.column_type == 'fixed'
          find_or_create_by(column, user, month_salary_report, 'left', resignation_record_id)
        end
      end
    end

    def update_add_columns(year_month, user, resignation_record_id)
      recalculate_columns = [146, 175, 187, 195, 199, 215, 218, 235]
      SalaryValue.where(salary_column_id: recalculate_columns, user_id: user.id, year_month: year_month, resignation_record_id: resignation_record_id).destroy_all

      SalaryColumn.all.where(id: recalculate_columns).each do |column|
        if column.column_type == 'fixed'
          Rails.cache.delete(cache_key_prefix_by_year_month(user, year_month, column.function.match(/[^[calc_]]\w+/).to_s, resignation_record_id))
        end
      end
      SalaryColumn.all.where(id: recalculate_columns).each do |column|
        if column.column_type == 'fixed'
          create_by(column, user, year_month, 'on_duty', resignation_record_id)
        end
      end

    end

    def find_or_create_by(column, user, month_salary_report, salary_type, resignation_record_id = nil)
      unless column.is_a? SalaryColumn
        column = SalaryColumn.find(column)
      end
      re = Rails.cache.fetch(cache_key_prefix_by_year_month(user, month_salary_report.year_month, column.function.match(/[^[calc_]]\w+/).to_s, resignation_record_id))
      if re.nil?
        if resignation_record_id
          re = SalaryValue.where(salary_column_id: column.id, user_id: user.id, year_month: month_salary_report.year_month, resignation_record_id: resignation_record_id).first
        else
          re = SalaryValue.where(salary_column_id: column.id, user_id: user.id, year_month: month_salary_report.year_month).first
        end

        re.nil? ? self.send(
            column.function, user, month_salary_report, salary_type, column.id, column.function.match(/[^[calc_]]\w+/).to_s, column.value_type, resignation_record_id
        ) :
            Rails.cache.fetch(cache_key_prefix_by_year_month(user, month_salary_report.year_month, column.function.match(/[^[calc_]]\w+/).to_s, resignation_record_id), expires_in: 12.hours) do
              ActiveModelSerializers::SerializableResource.new(re).serializer_instance.value
            end
      else
        re
      end
    end

    def create_by(column, user, year_month, salary_type, resignation_record_id)
      unless column.is_a? SalaryColumn
        column = SalaryColumn.find(column)
      end
      month_salary_report = MonthSalaryReport.find_by(salary_type: salary_type, year_month: year_month)
      if resignation_record_id
        month_salary_report = MonthSalaryReport.find_or_create_by(year_month: year_month.beginning_of_month, salary_type: :left)
      end
      self.send(column.function, user, month_salary_report, salary_type, column.id, column.function.match(/[^[calc_]]\w+/).to_s, column.value_type, resignation_record_id)
    end

    #寻找在职的字段
    def find_by(column, user, year_month, resignation_record_id = nil)
      unless column.is_a? SalaryColumn
        column = SalaryColumn.find(column)
      end
      re = Rails.cache.fetch(cache_key_prefix_by_year_month(user, year_month, column.function.match(/[^[calc_]]\w+/).to_s, resignation_record_id))
      if re.nil?
        re = SalaryValue.where(salary_column_id: column.id, user_id: user.id, year_month: year_month, resignation_record_id: resignation_record_id).first
        re = re.nil? ? re : ActiveModelSerializers::SerializableResource.new(re).serializer_instance.value
      end
      if re.nil?
        column.value_type == 'decimal' ? BigDecimal(0) : nil
      else
        re
      end
    end

    def find_or_create_add_info_by(add_column_id, user, month_salary_report)
      self.send("add_#{add_column_id}".to_sym, user, month_salary_report)
    end


    def find_or_create_deduct_info_by(add_column_id, user, month_salary_report)
      self.send("deduct_#{add_column_id}".to_sym, user, month_salary_report)
    end

    # 获取补薪表中的考勤数据(修订数据)
    def add_10(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_10'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:signcard_forget_to_punch_in_counts)
        re = re.nil? ? 0 : re
      end
    end

    def add_11(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_11'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:signcard_forget_to_punch_out_counts)
        re = re.nil? ? 0 : re
      end
    end

    def add_14(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_14'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:force_holiday_for_money_counts)
        re = re.nil? ? 0 : re
      end
    end

    def add_15(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_15'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:force_holiday_for_leave_counts)
        re = re.nil? ? 0 : re
      end
    end

    def add_16(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_16'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:public_holiday_for_money_counts)
        re = re.nil? ? 0 : re
      end
    end

    def add_17(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_17'), expires_in: 12.hours) do
        absenteeism_counts = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                                 .sum(:absenteeism_counts)
        late_mins_more_than_120 = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                                      .sum(:late_mins_more_than_120)
        re = absenteeism_counts.to_i + late_mins_more_than_120.to_i
      end
    end

    def add_18(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_18'), expires_in: 12.hours) do
        unpaid_leave_counts = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                                  .sum(:unpaid_leave_counts)
        unpaid_sick_leave_counts = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                                       .sum(:unpaid_sick_leave_counts)
        as_a_in_borrow_hours_counts = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                                          .sum(:as_a_in_borrow_hours_counts)
        as_a_in_return_hours_counts = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                                          .sum(:as_a_in_return_hours_counts)

        borrow_time = as_a_in_borrow_hours_counts.to_i - as_a_in_return_hours_counts.to_i
        borrow_time = borrow_time < 0 ? 0 : borrow_time
        re = unpaid_leave_counts + unpaid_sick_leave_counts + borrow_time
      end
    end

    def add_19(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_19'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:signcard_forget_to_punch_in_counts)
        re = re.nil? ? 0 : re
      end
    end

    def add_20(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_20'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:immediate_leave_counts)
        re = re.nil? ? 0 : re
      end
    end

    def add_21(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_21'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:unpaid_marriage_leave_counts)
        re = re.nil? ? 0 : re
      end
    end

    def add_22(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_22'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:pregnant_sick_leave_counts)
        re = re.nil? ? 0 : re
      end
    end

    def add_23(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_23'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:sick_leave_counts_not_link_off)
        re = re.nil? ? 0 : re
      end
    end

    def add_24(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_24'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:sick_leave_counts_link_off)
        re = re.nil? ? 0 : re
      end
    end

    def add_25(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_25'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:paid_maternity_leave_counts)
        re = re.nil? ? 0 : re
      end
    end

    def add_26(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_26'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:unpaid_maternity_leave_counts)
        re = re.nil? ? 0 : re
      end
    end

    def add_28(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, '_calc_work_injury_days_7_days_later'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:work_injury_after_7_counts)
        re = re.nil? ? 0 : re
      end
    end

    def add_29(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_29'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:unpaid_but_maintain_position_counts)
        re = re.nil? ? 0 : re
      end
    end

    def add_30(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_30'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:late_mins_less_than_10)
        re = re.nil? ? 0 : re
      end
    end

    def add_31(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_31'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:late_mins_less_than_20)
        re = re.nil? ? 0 : re
      end
    end

    def add_32(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_32'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:late_mins_less_than_30)
        re = re.nil? ? 0 : re
      end
    end

    def add_33(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_33'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:late_mins_more_than_30)
        re = re.nil? ? 0 : re
      end
    end

    def add_34(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_34'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:weekdays_overtime_hours)
        re = re.nil? ? 0 : re
      end
    end

    def add_35(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_35'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:general_holiday_overtime_hours)
        re = re.nil? ? 0 : re
      end
    end

    def add_36(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'add_36'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :compensate)
                 .sum(:typhoon_allowance_counts)
        re = re.nil? ? 0 : re
      end
    end


    # 获取补薪表中的考勤数据(原紀錄数据)
    def deduct_10(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_10'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:signcard_forget_to_punch_in_counts)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_11(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_11'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:signcard_forget_to_punch_out_counts)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_14(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_14'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:force_holiday_for_money_counts)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_15(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_15'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:force_holiday_for_leave_counts)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_16(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_16'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:public_holiday_for_money_counts)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_17(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_17'), expires_in: 12.hours) do
        absenteeism_counts = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                                 .sum(:absenteeism_counts)
        late_mins_more_than_120 = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                                      .sum(:late_mins_more_than_120)
        re = absenteeism_counts.to_i + late_mins_more_than_120.to_i
      end
    end

    def deduct_18(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_18'), expires_in: 12.hours) do
        unpaid_leave_counts = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                                  .sum(:unpaid_leave_counts)
        unpaid_sick_leave_counts = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                                       .sum(:unpaid_sick_leave_counts)
        as_a_in_borrow_hours_counts = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                                          .sum(:as_a_in_borrow_hours_counts)
        as_a_in_return_hours_counts = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                                          .sum(:as_a_in_return_hours_counts)

        borrow_time = as_a_in_borrow_hours_counts.to_i - as_a_in_return_hours_counts.to_i
        borrow_time = borrow_time < 0 ? 0 : borrow_time
        re = unpaid_leave_counts + unpaid_sick_leave_counts + borrow_time
      end
    end

    def deduct_19(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_19'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:signcard_forget_to_punch_in_counts)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_20(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_20'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:immediate_leave_counts)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_21(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_21'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:unpaid_marriage_leave_counts)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_22(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_22'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:pregnant_sick_leave_counts)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_23(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_23'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:sick_leave_counts_not_link_off)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_24(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_24'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:sick_leave_counts_link_off)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_25(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_25'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:paid_maternity_leave_counts)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_26(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_26'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:unpaid_maternity_leave_counts)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_28(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, '_calc_work_injury_days_7_days_later'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:work_injury_after_7_counts)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_29(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_29'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:unpaid_but_maintain_position_counts)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_30(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_30'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:late_mins_less_than_10)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_31(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_31'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:late_mins_less_than_20)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_32(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_32'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:late_mins_less_than_30)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_33(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_33'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:late_mins_more_than_30)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_34(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_34'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:weekdays_overtime_hours)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_35(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_35'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:general_holiday_overtime_hours)
        re = re.nil? ? 0 : re
      end
    end

    def deduct_36(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_36'), expires_in: 12.hours) do
        re = CompensateReport.where(user_id: user.id, year_month: month_salary_report.year_month.strftime('%Y%m').to_i, record_type: :original)
                 .sum(:typhoon_allowance_counts)
        re = re.nil? ? 0 : re
      end
    end


    def deduct_bonus_cache(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_bonus_cache'), expires_in: 12.hours) do
        BigDecimal(0)
      end
    end


    def deduct_attendance_bonus_cache(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_attendance_bonus_cache'), expires_in: 12.hours) do
        BigDecimal(0)
      end
    end


    def deduct_department_float_salary_cache(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, 'deduct_department_float_salary_cache'), expires_in: 12.hours) do
        BigDecimal(0)
      end
    end

    # 勤工扣减百分比
    def calculate_attendance_bonus_deduct_percentage(user, month_salary_report, salary_type, resignation_record_id = nil)
      attendance_bonus = SalaryCalculatorService.find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id)
      deduct_200 = SalaryCalculatorService.find_or_create_by(17, user, month_salary_report, salary_type, resignation_record_id) * 1500
      deduct_201 = SalaryCalculatorService.find_or_create_by(19, user, month_salary_report, salary_type, resignation_record_id) * 1000
      deduct_202 = SalaryCalculatorService.find_or_create_by(18, user, month_salary_report, salary_type, resignation_record_id) * 500
      deduct_203 = SalaryCalculatorService.find_or_create_by(20, user, month_salary_report, salary_type, resignation_record_id) * 250
      deduct_204 = SalaryCalculatorService.find_or_create_by(21, user, month_salary_report, salary_type, resignation_record_id) * 250
      deduct_205 = SalaryCalculatorService.find_or_create_by(25, user, month_salary_report, salary_type, resignation_record_id) * attendance_bonus / 30
      deduct_207 = SalaryCalculatorService.find_or_create_by(28, user, month_salary_report, salary_type, resignation_record_id) * attendance_bonus / 30 / 3
      deduct_208 = SalaryCalculatorService.find_or_create_by(29, user, month_salary_report, salary_type, resignation_record_id) * attendance_bonus / 30
      deduct_209 = SalaryCalculatorService.find_or_create_by(24, user, month_salary_report, salary_type, resignation_record_id) * 500 + SalaryCalculatorService.find_or_create_by(23, user, month_salary_report, salary_type, resignation_record_id) * 250
      total_deduct = deduct_200 + deduct_201 + deduct_202 + deduct_203 + deduct_204 + deduct_205 + deduct_207 + deduct_208 + deduct_209
      if total_deduct == BigDecimal(0)
        return BigDecimal(1)
      end
      deduct_percentage = attendance_bonus / total_deduct
      # 比例 > 1 总数大于扣减 按照扣间的100%扣 else 各项按照比例平均扣减
      return deduct_percentage > 1 ? BigDecimal(1) : deduct_percentage
    end

    # 勤工合计扣减
    def calculate_attendance_bonus_deduct(user, month_salary_report, salary_type, resignation_record_id = nil)
      attendance_bonus = find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id)
      deduct_200 = find_or_create_by(17, user, month_salary_report, salary_type, resignation_record_id) * 1500
      deduct_201 = find_or_create_by(19, user, month_salary_report, salary_type, resignation_record_id) * 1000
      deduct_202 = find_or_create_by(18, user, month_salary_report, salary_type, resignation_record_id) * 500
      deduct_203 = find_or_create_by(20, user, month_salary_report, salary_type, resignation_record_id) * 250
      deduct_204 = find_or_create_by(21, user, month_salary_report, salary_type, resignation_record_id) * 250
      deduct_205 = find_or_create_by(25, user, month_salary_report, salary_type, resignation_record_id) * attendance_bonus / 30
      # deduct_206 = find_or_create_by(28, user, month_salary_report, salary_type, resignation_record_id)
      deduct_207 = find_or_create_by(17, user, month_salary_report, salary_type, resignation_record_id) * attendance_bonus / 30 / 3
      deduct_208 = find_or_create_by(39, user, month_salary_report, salary_type, resignation_record_id) * attendance_bonus / 30
      deduct_209 = find_or_create_by(24, user, month_salary_report, salary_type, resignation_record_id) * 500 + find_or_create_by(23, user, month_salary_report, salary_type, resignation_record_id) * 250
      total_deduct = deduct_200 + deduct_201 + deduct_202 + deduct_203 + deduct_204 + deduct_205 + deduct_207 + deduct_208 + deduct_209
      return total_deduct > attendance_bonus ? attendance_bonus : total_deduct
    end

    # 津贴合计扣减
    def calculate_allowance_deduct(user, month_salary_report, salary_type, resignation_record_id = nil)
      allowance = find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id)
      days = find_or_create_by(17, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(19, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(18, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(20, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(21, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(25, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(22, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(29, user, month_salary_report, salary_type, resignation_record_id)
      allowance_deduct = allowance * days / 30
      allowance_deduct += find_or_create_by(28, user, month_salary_report, salary_type, resignation_record_id) * allowance / 30 / 3
      allowance_deduct
    end

    # 部门制浮动薪金合计扣减
    def calculate_departmental_float_salary_deduct(user, month_salary_report, salary_type, resignation_record_id = nil)
      days = find_or_create_by(17, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(19, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(18, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(20, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(21, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(25, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(22, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(28, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(29, user, month_salary_report, salary_type, resignation_record_id)
      departmental_float_salary_deduct = _calc_department_bonus(user, month_salary_report) * days / 30
      departmental_float_salary_deduct
    end

    # 个人制浮动薪金扣减
    def calculate_personal_float_salary_deduct(user, month_salary_report, salary_type, resignation_record_id = nil)
      all_float_salary = _calc_all_bonus(user, month_salary_report)
      departmental_float_salary = _calc_department_bonus(user, month_salary_report)
      personal_float_salary = all_float_salary - departmental_float_salary
      days = find_or_create_by(29, user, month_salary_report, salary_type, resignation_record_id)
      personal_float_salary_deduct = personal_float_salary * days / 30
      personal_float_salary_deduct
    end

    # 210 211 顺序扣减计算
    def calculate_210_211_deduct(user, month_salary_report, salary_type, resignation_record_id = nil)
      attendance_bonus_surplus = find_or_create_by(45, user, month_salary_report, salary_type, resignation_record_id) - calculate_attendance_bonus_deduct(user, month_salary_report, salary_type, resignation_record_id)
      allowance_surplus = find_or_create_by(42, user, month_salary_report, salary_type, resignation_record_id) - calculate_allowance_deduct(user, month_salary_report, salary_type, resignation_record_id)
      departmental_float_salary_surplus = _calc_department_bonus(user, month_salary_report) - calculate_departmental_float_salary_deduct(user, month_salary_report, salary_type, resignation_record_id)
      personal_float_salary_surplus = _calc_all_bonus(user, month_salary_report) -
          _calc_department_bonus(user, month_salary_report) -
          calculate_personal_float_salary_deduct(user, month_salary_report, salary_type, resignation_record_id)

      times_30 = find_or_create_by(30, user, month_salary_report, salary_type, resignation_record_id) - 3
      times_30 = times_30 < 0 ? 0 : times_30
      deduct_210 = (times_30) * 250 +
          find_or_create_by(31, user, month_salary_report, salary_type, resignation_record_id) * 250 +
          find_or_create_by(32, user, month_salary_report, salary_type, resignation_record_id) * 500 +
          find_or_create_by(33, user, month_salary_report, salary_type, resignation_record_id) * 750

      tiems_10_and_11 = (find_or_create_by(10, user, month_salary_report, salary_type, resignation_record_id) +
          find_or_create_by(11, user, month_salary_report, salary_type, resignation_record_id) - 1)
      tiems_10_and_11 = tiems_10_and_11 < 0 ? 0 : tiems_10_and_11
      deduct_211 = tiems_10_and_11 * 300

      percentage_210 = deduct_210 / (deduct_210 + deduct_211) rescue BigDecimal(0)
      percentage_211 = deduct_210 / (deduct_210 + deduct_211) rescue BigDecimal(0)

      has_deduct_210 = BigDecimal(0)
      has_deduct_211 = BigDecimal(0)
      deduct_210_surplus = deduct_210
      deduct_211_surplus = deduct_211

      if attendance_bonus_surplus > (deduct_210_surplus + deduct_211_surplus)
        return {
            deduct_210: deduct_210,
            deduct_211: deduct_211,
            attendance_bonus_deduct: deduct_210 + deduct_211,
            allowance_deduct: BigDecimal(0),
            departmental_float_salary_deduct: BigDecimal(0),
            personal_float_salary_deduct: BigDecimal(0)
        }
      else
        has_deduct_210 += attendance_bonus_surplus * percentage_210
        has_deduct_211 += attendance_bonus_surplus * percentage_211
        deduct_210_surplus = deduct_210 - has_deduct_210
        deduct_211_surplus = deduct_211 - has_deduct_211
      end

      if allowance_surplus > (deduct_210_surplus + deduct_211_surplus)
        return {
            deduct_210: deduct_210,
            deduct_211: deduct_211,
            attendance_bonus_deduct: attendance_bonus_surplus,
            allowance_deduct: deduct_210+ deduct_211 - attendance_bonus_surplus,
            departmental_float_salary_deduct: BigDecimal(0),
            personal_float_salary_deduct: BigDecimal(0)
        }
      else
        has_deduct_210 += allowance_surplus * percentage_210
        has_deduct_211 += allowance_surplus * percentage_211
        deduct_210_surplus = deduct_210 - has_deduct_210
        deduct_211_surplus = deduct_211 - has_deduct_211
      end

      if departmental_float_salary_surplus > (deduct_210_surplus + deduct_211_surplus)
        return {
            deduct_210: deduct_210,
            deduct_211: deduct_211,
            attendance_bonus_deduct: attendance_bonus_surplus,
            allowance_deduct: allowance_surplus,
            departmental_float_salary_deduct: deduct_210 + deduct_211 - attendance_bonus_surplus - allowance_surplus,
            personal_float_salary_deduct: BigDecimal(0)
        }
      else
        has_deduct_210 += departmental_float_salary_surplus * percentage_210
        has_deduct_211 += departmental_float_salary_surplus * percentage_211
        deduct_210_surplus = deduct_210 - has_deduct_210
        deduct_211_surplus = deduct_211 - has_deduct_211
      end

      if personal_float_salary_surplus > deduct_210_surplus
        return {
            deduct_210: deduct_210,
            deduct_211: deduct_211,
            attendance_bonus_deduct: attendance_bonus_surplus,
            allowance_deduct: allowance_surplus,
            departmental_float_salary_deduct: departmental_float_salary_surplus,
            personal_float_salary_deduct: deduct_210 - attendance_bonus_surplus - allowance_surplus - departmental_float_salary_surplus
        }
      else
        has_deduct_210 += personal_float_salary_surplus * percentage_210
        has_deduct_211 += personal_float_salary_surplus * percentage_211
        deduct_210_surplus = deduct_210 - has_deduct_210
        deduct_211_surplus = deduct_211 - has_deduct_211
        return {
            deduct_210: has_deduct_210,
            deduct_211: has_deduct_211,
            attendance_bonus_deduct: attendance_bonus_surplus,
            allowance_deduct: allowance_surplus,
            departmental_float_salary_deduct: departmental_float_salary_surplus,
            personal_float_salary_deduct: personal_float_salary_surplus
        }
      end

    end

    def math_add(sum)
      BigDecimal(sum) rescue BigDecimal(0)
    end

    def year_tax_mop(mop)
      calculate_tax(mop, 1)
    end

    def season_tax_mop(mop)
      calculate_tax(mop, 4)
    end

    def month_tax_mop(mop)
      calculate_tax(mop, 12)
    end

    def calculate_tax(mop, multiple)
      setting = OccupationTaxSetting.first
      range = setting.ranges
      amount = mop * (BigDecimal(100) - BigDecimal(setting.favorable_percent)) / 100
      tax = BigDecimal(0)

      # range添加下限金额
      for iterator in 0..range.size - 1
        if iterator == 0
          range[iterator]['base'] = '0'
        else
          range[iterator]['base'] = range[iterator - 1]['limit']
        end
      end
      # 计算职业税
      range.each do |r|
        if r['limit'] != nil
          # not第七区间
          # limit < base
          if BigDecimal(r['limit']) / multiple <= amount
            # (上限 - 下限) × 税率
            tax += (BigDecimal(r['limit']) - BigDecimal(r['base'])) / multiple * BigDecimal(r['tax_rate']) / 100
          end

          if BigDecimal(r['base']) / multiple < amount && amount < BigDecimal(r['limit']) / multiple
            tax += (amount - BigDecimal(r['base']) / multiple) * BigDecimal(r['tax_rate']) / 100
          end

        else
          if BigDecimal(r['base']) / multiple < amount
            tax += (amount - BigDecimal(r['base']) / multiple) * BigDecimal(r['tax_rate']) / 100
          end
        end
      end
      tax = tax * (BigDecimal(100) - BigDecimal(setting.deduct_percent)) / 100
      tax
    end

    def _calc_salary_element_raw(user, year_month, client_attribute)
      sum = BigDecimal(0)
      month_begin = year_month.beginning_of_month
      month_end = year_month.end_of_month
      resigned_date = user.resignation_records.where(resigned_date: year_month.month_range).maximum(:resigned_date)
      targets = user.salary_records.where('salary_begin < :to AND invalid_date > :from', from: month_begin, to: month_end).order_by(:salary_begin, :asc)
      return sum if targets.empty?
      targets.each do |salary_record|
        salary_begin = salary_record.salary_begin.beginning_of_day
        salary_end = salary_record.invalid_date.end_of_day
        _begin = [salary_begin, month_begin].compact.max
        _end = [salary_end, month_end, resigned_date].compact.min
        diff = ((_end - _begin) / 1.day).round
        diff = 0 if diff < 0
        salary_basic = ActiveModelSerializers::SerializableResource.new(salary_record).serializer_instance.send(client_attribute) rescue 0
        sum += BigDecimal(salary_basic.to_s) * diff
      end
      sum / (((month_end - month_begin) / 1.day).round)
    end

    private

    def get_annual_award_report_item(user, month_salary_report)
      annual_award_report_id = AnnualAwardReport.where("award_date >= :month_begin AND award_date <= :month_end", month_begin: month_salary_report.year_month, month_end: month_salary_report.year_month.end_of_month).order(year_month: :desc).limit(1)&.first&.id
      AnnualAwardReportItem.where(user_id: user.id, annual_award_report_id: annual_award_report_id).first
    end


    def _calc_origin_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, client_attribute, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        salary_record = SalaryRecord
                            .where(user_id: user.id)
                            .by_salary_date(month_salary_report.year_month.beginning_of_month)
                            .order(salary_begin: :desc)
                            .first
        re = ActiveModelSerializers::SerializableResource.new(salary_record).serializer_instance
                 .send(client_attribute) rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    def _calc_present_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, client_attribute, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        salary_record = SalaryRecord
                            .where(user_id: user.id)
                            .by_salary_date(month_salary_report.year_month.end_of_month)
                            .order(salary_begin: :desc)
                            .first
        re = ActiveModelSerializers::SerializableResource.new(salary_record).serializer_instance
                 .send(client_attribute) rescue BigDecimal(0)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    def _calc_salary_element(user, month_salary_report, salary_type, salary_column_id, key, value_type, client_attribute, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = _calc_salary_element_raw(user, month_salary_report.year_month, client_attribute)
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end


    def _calc_bonus_element_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, bonus_key, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = _get_bonus_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, bonus_key)
        re = re.nil? ? BigDecimal(0) : re
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    def _calc_bonus_element_per_share(user, month_salary_report, salary_type, salary_column_id, key, value_type, bonus_key, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = _get_bonus_per_share(user, month_salary_report, bonus_key)
        re = re.nil? ? BigDecimal(0) : re
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    def _calc_bonus_element_amount(user, month_salary_report, salary_type, salary_column_id, key, value_type, bonus_key, resignation_record_id)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, key, resignation_record_id), expires_in: 12.hours) do
        re = _get_bonus_amount(user, month_salary_report, bonus_key)
        re = re.nil? ? BigDecimal(0) : re
        get_salary_value(user, month_salary_report, salary_type, salary_column_id, value_type, resignation_record_id, re)
      end
    end

    def _calc_bonus_element_amount_by_type(user, month_salary_report, bonus_key, bonus_type = nil)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, bonus_key.to_s + bonus_type.to_s), expires_in: 12.hours) do
        re = _get_bonus_amount(user, month_salary_report, bonus_key, bonus_type)
        re.nil? ? BigDecimal(0) : re
      end
    end

    def _calc_all_bonus(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, :all_bonus), expires_in: 12.hours) do
        re = _get_all_bonus(user, month_salary_report)
        re.nil? ? BigDecimal(0) : re
      end
    end

    def _calc_department_bonus(user, month_salary_report)
      Rails.cache.fetch(cache_key_prefix(user, month_salary_report, :department_bonus), expires_in: 12.hours) do
        re = _get_department_bonus(user, month_salary_report)
        re.nil? ? BigDecimal(0) : re
      end
    end


    # 浮动薪金的KEY
    def _all_bonus_keys
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
    def _get_bonus_element_item(user, year_month_date)
      float_salary_month_entry = FloatSalaryMonthEntry.where(status: 'approved', year_month: year_month_date.month_range).first
      return nil if float_salary_month_entry.nil?
      BonusElementItem.where(user_id: user.id, float_salary_month_entry_id: float_salary_month_entry.id).first
    end

    def _get_bonus_shares(user, month_salary_report, salary_type, salary_column_id, key, value_type, bonus_key)
      bonus_element_item = _get_bonus_element_item(user, month_salary_report.year_month)
      if bonus_element_item.nil?
        return nil
      end
      bonus_element = BonusElement.find_by_key(bonus_key)

      bonus_element_item_value = bonus_element_item
                                     .bonus_element_item_values
                                     .where(bonus_element_id: bonus_element.id)
                                     .first
      if bonus_element_item_value.nil? || bonus_element_item_value.value_type == 'personal'
        return nil
      end
      bonus_element_item_value.shares
    end

    def _get_bonus_per_share(user, month_salary_report, bonus_key, subtype = nil)
      bonus_element_item = _get_bonus_element_item(user, month_salary_report.year_month)
      if bonus_element_item.nil?
        return nil
      end
      bonus_element = BonusElement.find_by_key(bonus_key)

      bonus_element_item_value = bonus_element_item
                                     .bonus_element_item_values
                                     .where(bonus_element_id: bonus_element.id, subtype: subtype)
                                     .first

      if bonus_element_item_value.nil? || bonus_element_item_value.value_type == 'personal'
        return nil
      end
      bonus_element_item_value.per_share
    end

    def _get_bonus_amount(user, month_salary_report, bonus_key, bonus_type = nil)
      bonus_element_item = _get_bonus_element_item(user, month_salary_report.year_month)
      if bonus_element_item.nil?
        return nil
      end
      bonus_element = BonusElement.find_by(key: bonus_key)
      bonus_element_item_value = bonus_element_item.bonus_element_item_values.find_by(bonus_element_id: bonus_element.id)
      amount = bonus_element_item_value.amount.presence rescue nil
      amount
    end

    def _get_department_bonus(user, month_salary_report)
      bonus_element_item = _get_bonus_element_item(user, month_salary_report.year_month)
      if bonus_element_item.nil?
        return BigDecimal(0)
      end
      #贵宾卡消费转化为hkd
      FloatSalaryMonthEntry.where(year_month: month_salary_report.year_month).first.bonus_element_items.where(user_id: user.id).first.bonus_element_item_values.where(value_type: :departmental).map do |item|
        item.calc_amount
      end.sum rescue BigDecimal(0)
    end

    def _get_all_bonus(user, month_salary_report)
      bonus_element_item = _get_bonus_element_item(user, month_salary_report.year_month)
      if bonus_element_item.nil?
        return BigDecimal(0)
      end
      #贵宾卡消费转化为hkd
      FloatSalaryMonthEntry.where(year_month: month_salary_report.year_month).first.bonus_element_items.where(user_id: user.id).first.bonus_element_item_values.map do |item|
        item.calc_amount
      end.sum rescue BigDecimal(0)
    end
  end
end
