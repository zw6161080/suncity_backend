# == Schema Information
#
# Table name: occupation_tax_items
#
#  id                              :integer          not null, primary key
#  user_id                         :integer
#  year                            :datetime
#  month_1_company                 :string
#  month_1_income_mop              :decimal(15, 2)
#  month_1_tax_mop                 :decimal(15, 2)
#  month_2_company                 :string
#  month_2_income_mop              :decimal(15, 2)
#  month_2_tax_mop                 :decimal(15, 2)
#  month_3_company                 :string
#  month_3_income_mop              :decimal(15, 2)
#  month_3_tax_mop                 :decimal(15, 2)
#  quarter_1_income_mop            :decimal(15, 2)
#  quarter_1_tax_mop_before_adjust :decimal(15, 2)
#  quarter_1_tax_mop_after_adjust  :decimal(15, 2)
#  month_4_company                 :string
#  month_4_income_mop              :decimal(15, 2)
#  month_4_tax_mop                 :decimal(15, 2)
#  month_5_company                 :string
#  month_5_income_mop              :decimal(15, 2)
#  month_5_tax_mop                 :decimal(15, 2)
#  month_6_company                 :string
#  month_6_income_mop              :decimal(15, 2)
#  month_6_tax_mop                 :decimal(15, 2)
#  quarter_2_income_mop            :decimal(15, 2)
#  quarter_2_tax_mop_before_adjust :decimal(15, 2)
#  quarter_2_tax_mop_after_adjust  :decimal(15, 2)
#  month_7_company                 :string
#  month_7_income_mop              :decimal(15, 2)
#  month_7_tax_mop                 :decimal(15, 2)
#  month_8_company                 :string
#  month_8_income_mop              :decimal(15, 2)
#  month_8_tax_mop                 :decimal(15, 2)
#  month_9_company                 :string
#  month_9_income_mop              :decimal(15, 2)
#  month_9_tax_mop                 :decimal(15, 2)
#  quarter_3_income_mop            :decimal(15, 2)
#  quarter_3_tax_mop_before_adjust :decimal(15, 2)
#  quarter_3_tax_mop_after_adjust  :decimal(15, 2)
#  month_10_company                :string
#  month_10_income_mop             :decimal(15, 2)
#  month_10_tax_mop                :decimal(15, 2)
#  month_11_company                :string
#  month_11_income_mop             :decimal(15, 2)
#  month_11_tax_mop                :decimal(15, 2)
#  month_12_company                :string
#  month_12_income_mop             :decimal(15, 2)
#  month_12_tax_mop                :decimal(15, 2)
#  quarter_4_income_mop            :decimal(15, 2)
#  quarter_4_tax_mop_before_adjust :decimal(15, 2)
#  year_income_mop                 :decimal(15, 2)
#  year_payable_tax_mop            :decimal(15, 2)
#  year_paid_tax_mop               :decimal(15, 2)
#  quarter_4_tax_mop_after_adjust  :decimal(15, 2)
#  comment                         :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  double_pay_bonus_and_award      :decimal(15, 2)
#  department_id                   :integer
#  position_id                     :integer
#
# Indexes
#
#  index_occupation_tax_items_on_department_id  (department_id)
#  index_occupation_tax_items_on_position_id    (position_id)
#  index_occupation_tax_items_on_user_id        (user_id)
#
# Foreign Keys
#
#  fk_rails_69a3b76de0  (user_id => users.id)
#

class OccupationTaxItem < ApplicationRecord
  include StatementAble

  belongs_to :user
  belongs_to :department
  belongs_to :position
  after_save :update_d_and_p


  # after_update :re_calculate

  def update_d_and_p
    self.update_columns(
      department_id: ProfileService.department(self.user, self.year.end_of_year.beginning_of_day)&.id,
      position_id: ProfileService.position(self.user, self.year.end_of_year.beginning_of_day)&.id
    )
  end


  def self.headers(language = nil)
    raw_headers =  ["employee_id", "chinese_name", "english_name", "department", "position", "month_1_company", "month_2_company", "month_3_company", "month_4_company", "month_5_company", "month_6_company", "month_7_company", "month_8_company", "month_9_company", "month_10_company", "month_11_company", "month_12_company", "type_of_id", "id_number", "tax_number", "career_entry_date", "resigned_date", "double_pay_bonus_and_award", "month_1_income_mop", "month_1_tax_mop", "month_2_income_mop", "month_2_tax_mop", "month_3_income_mop", "month_3_tax_mop", "quarter_1_income_mop", "quarter_1_tax_mop_before_adjust", "quarter_1_tax_mop_after_adjust", "month_4_income_mop", "month_4_tax_mop", "month_5_income_mop", "month_5_tax_mop", "month_6_income_mop", "month_6_tax_mop", "quarter_2_income_mop", "quarter_2_tax_mop_before_adjust", "quarter_2_tax_mop_after_adjust", "month_7_income_mop", "month_7_tax_mop", "month_8_income_mop", "month_8_tax_mop", "month_9_income_mop", "month_9_tax_mop", "quarter_3_income_mop", "quarter_3_tax_mop_before_adjust", "quarter_3_tax_mop_after_adjust", "month_10_income_mop", "month_10_tax_mop", "month_11_income_mop", "month_11_tax_mop", "month_12_income_mop", "month_12_tax_mop", "quarter_4_income_mop", "quarter_4_tax_mop_before_adjust", "year_income_mop", "year_payable_tax_mop", "year_paid_tax_mop", "quarter_4_tax_mop_after_adjust", "comment"]
    transfer_headers = raw_headers.map{|item| I18n.t "statement_columns.occupation_tax_items.#{item}", locale: (language || I18n.locale)}
    [raw_headers, transfer_headers].transpose.to_h
  end

  def self.edit_headers(language = nil)
    raw_headers = ['quarter_1_tax_mop_before_adjust', 'quarter_2_tax_mop_before_adjust', 'quarter_3_tax_mop_before_adjust', 'comment']
    transfer_headers = raw_headers.map{|item| I18n.t "statement_columns.occupation_tax_items.#{item}", locale: (language || I18n.locale)}
    [raw_headers, transfer_headers].transpose.to_h
  end


  def self.get_locale_hash
    hash = {}
    Dir[Rails.root.join('config', 'locales', 'models', 'statement_columns', 'occupation_tax_items', '*.yml')].each{|item| hash.merge!(YAML.load_file(item))}
    hash
  end

  def self.import_xlsx(file, year)
    xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    sheet = xlsx.sheet(xlsx.sheets.first)
    header = sheet.row(1)

    language = if get_locale_hash['zh-CN']['statement_columns']['occupation_tax_items'].values.include?(header.first)
                 :'zh-CN'
               elsif get_locale_hash['en']['statement_columns']['occupation_tax_items'].values.include?(header.first)
                 :en
               else
                 :'zh-HK'
               end
    I18n.locale == language
    headers(language).values.each do |key|
      raise LogicError, "缺少表頭：#{key}" unless header.include?(key)
    end
    (2..sheet.last_row).each do |index|
      row = [header, sheet.row(index)].transpose.to_h
      empoid = row['員工編號']
      user_chinese_name = row['中文姓名']
      user_english_name = row['外文姓名']
      department_chinese_name = row['部門']
      position_chinese_name = row['職位']

      user = User.where(empoid: empoid).first
      raise LogicError, "沒有這個員工：#{empoid}" if user.nil?
      user = User.where(chinese_name: user_chinese_name).first
      raise LogicError, "沒有這個員工：#{user_chinese_name}" if user.nil?
      user = User.where(english_name: user_english_name).first
      raise LogicError, "沒有這個員工：#{user_english_name}" if user.nil?
      department = Department.where(select_language => department_chinese_name).first
      raise LogicError, "沒有這個部門：#{department_chinese_name}" if department.nil?
      position = Position.where(select_language =>position_chinese_name).first
      raise LogicError, "沒有這個職位：#{position_chinese_name}" if position.nil?

      occupation_tax_item = OccupationTaxItem.where(user_id: user.id, year: year).first
      raise LogicError, "沒有這個員工記錄：#{user.id}" if occupation_tax_item.nil?
      edit_headers(language).each do |key, value|
        next if row[value].nil?
        if occupation_tax_item.send(key).nil?
          occupation_tax_item.send("#{key}=", row[value])
          occupation_tax_item.save
        end
      end
    end
  end

  def add_month_info(user, year_month)
    # 更寻月度课税金额 & 每月職業稅
    self["month_#{year_month.month}_income_mop"] = SalaryCalculatorService.find_by(235, user, year_month)
    self["month_#{year_month.month}_tax_mop"] = SalaryCalculatorService.find_by(146, user, year_month)
    self["month_#{year_month.month}_company"] = user.company_name
    self.save

    # 更新季度
    case year_month.month
    when 3
      amount = (self['month_1_income_mop'] || BigDecimal(0)) + (self['month_2_income_mop'] || BigDecimal(0)) + (self['month_3_income_mop'] || BigDecimal(0))
      self['quarter_1_income_mop'] = amount
      self.save
      # 季度税
      self['quarter_1_tax_mop_before_adjust'] = SalaryCalculatorService.season_tax_mop(amount)
    when 6
      amount = (self['month_4_income_mop'] || BigDecimal(0)) + (self['month_5_income_mop'] || BigDecimal(0)) + (self['month_6_income_mop'] || BigDecimal(0))
      self['quarter_2_income_mop'] = amount
      self['quarter_2_tax_mop_before_adjust'] = SalaryCalculatorService.season_tax_mop(amount)
      self.save
    when 9
      amount = (self['month_7_income_mop'] || BigDecimal(0)) + (self['month_8_income_mop'] || BigDecimal(0)) + (self['month_9_income_mop'] || BigDecimal(0))
      self['quarter_3_income_mop'] = amount
      self['quarter_3_tax_mop_before_adjust'] = SalaryCalculatorService.season_tax_mop(amount)
      self.save
    when 12
      amount = (self['month_10_income_mop'] || BigDecimal(0)) + (self['month_11_income_mop'] || BigDecimal(0)) + (self['month_12_income_mop'] || BigDecimal(0))
      self['quarter_4_income_mop'] = amount
      self['quarter_4_tax_mop_before_adjust'] = SalaryCalculatorService.season_tax_mop(amount)

      # 更新年度总和
      year_income = BigDecimal(0)
      for i in 1..12
        year_income += (self["month_#{i}_income_mop"] || BigDecimal(0))
      end
      # 全年總薪金
      year_amount = year_income + (self['double_pay_bonus_and_award'] || BigDecimal(0))
      self['year_income_mop'] = year_amount
      # 全年應繳
      year_tax = SalaryCalculatorService.year_tax_mop(year_amount)
      self['year_payable_tax_mop'] = year_tax
      # 已繳納稅款
      year_paid_tax_mop = (self['quarter_1_tax_mop_after_adjust'] || BigDecimal(0)) + (self['quarter_2_tax_mop_after_adjust'] || BigDecimal(0)) + (self['quarter_3_tax_mop_after_adjust'] || BigDecimal(0))
      self['year_paid_tax_mop'] = year_paid_tax_mop
      # 第四季度職業稅（調整后）＝全年應繳﹣已繳納稅款
      quarter_4_tax_mop_after_adjust = year_tax - year_paid_tax_mop
      self['quarter_4_tax_mop_after_adjust'] = quarter_4_tax_mop_after_adjust
      self.save
    end
    self.save
  end

  def add_annual_award_info(annual_award_report_item)
     self.double_pay_bonus_and_award = SalaryCalculatorService.hkd_to_mop([annual_award_report_item.double_pay_final_hkd, annual_award_report_item.end_bonus_final_hkd , annual_award_report_item.annual_at_duty_final_hkd].compact.sum)
     self.save
  end

  def re_calculate
    self.quarter_1_income_mop = [self.month_1_income_mop , self.month_2_income_mop , self.month_3_income_mop].compact.sum if self.month_3_income_mop
    self.quarter_1_tax_mop_before_adjust = SalaryCalculatorService.season_tax_mop(self.quarter_1_income_mop) if self.month_3_income_mop
    self.quarter_2_income_mop = [self.month_4_income_mop , self.month_5_income_mop , self.month_6_income_mop].compact.sum if self.month_6_income_mop
    self.quarter_2_tax_mop_before_adjust = SalaryCalculatorService.season_tax_mop(self.quarter_2_income_mop) if self.month_3_income_mop
    self.quarter_3_income_mop = [self.month_7_income_mop , self.month_8_income_mop , self.month_9_income_mop].compact.sum if self.month_9_income_mop
    self.quarter_3_tax_mop_before_adjust = SalaryCalculatorService.season_tax_mop(self.quarter_3_income_mop) if self.month_9_income_mop
    self.quarter_4_income_mop = [self.month_10_income_mop , self.month_11_income_mop , self.month_12_income_mop].compact.sum if self.month_12_income_mop
    self.quarter_4_tax_mop_before_adjust = SalaryCalculatorService.season_tax_mop(self.quarter_4_income_mop) if self.month_12_income_mop
    year_income_mop = BigDecimal(0)
    12.times{|i|year_income_mop += SalaryCalculatorService.math_add(self["month_#{1+i}_income_mop"])}
    self.year_income_mop = year_income_mop if self.month_12_income_mop
    self.year_payable_tax_mop = SalaryCalculatorService.year_tax_mop(self.year_income_mop) if self.month_12_income_mop
    self.year_paid_tax_mop = [self.quarter_1_tax_mop_after_adjust, self.quarter_2_tax_mop_after_adjust, self.quarter_3_tax_mop_after_adjust].compact.sum if self.month_12_income_mop
    self.quarter_4_tax_mop_after_adjust = self.year_payable_tax_mop - self.year_paid_tax_mop if self.month_12_income_mop
    self.update_columns(
      quarter_1_income_mop:  self.quarter_1_income_mop, quarter_1_tax_mop_before_adjust: self.quarter_1_tax_mop_after_adjust,
      quarter_2_income_mop: self.quarter_2_income_mop, quarter_2_tax_mop_before_adjust: self.quarter_2_tax_mop_before_adjust,
      quarter_3_income_mop: self.quarter_3_income_mop, quarter_3_tax_mop_before_adjust: self.quarter_3_tax_mop_before_adjust,
      quarter_4_income_mop: self.quarter_4_income_mop, quarter_4_tax_mop_before_adjust: self.quarter_4_tax_mop_before_adjust,
      year_income_mop: self.year_income_mop, year_payable_tax_mop: self.year_paid_tax_mop, year_paid_tax_mop: self.year_paid_tax_mop,
      quarter_4_tax_mop_after_adjust: self.quarter_4_tax_mop_after_adjust
    )
  end

  scope :order_default, lambda{
    order('users.empoid asc')
  }

  scope :by_year_month, -> (year_month) {
    where(year: Time.zone.parse(year_month).beginning_of_year)
  }


  scope :by_chinese_name, -> (name) {
    where('users.chinese_name = :name', name: name)
  }

  scope :by_english_name, -> (name) {
    where('users.english_name = :name' , name: name)
  }

  scope :order_chinese_name, -> (sort_direction) {
    order("users.chinese_name #{sort_direction.first}")
  }

  scope :order_english_name, -> (sort_direction) {
    order("users.english_name #{sort_direction.first}")
  }

  class << self

    def year_options
      self.select(:year).distinct.map{|item| item['year']}
    end

    def extra_query_params
      [ { key: 'year', search_type: 'year_range' }, { key: 'year_month' } ]
    end

    def generate(user, year_date)
      year = year_date.beginning_of_year
      calc_params = self.create_params - %w(user_id year comment department_id position_id)
      self.where(user: user, year: year..year.end_of_year)
        .first_or_create(user: user, year: year)
        .update(calc_params.map { |param| [param, self.send("calc_#{param}", user, year)] }.to_h)
    end

    def generate_all(year_date)
      # User.salary_calculation_users.each do |user|
      User.all.find_each(batch_size: 50) do |user|
        generate(user, year_date)
      end
    end

    def tax_mop(user, year_date, month)
      mop = actual_mop(user, year_date, month)
      setting = OccupationTaxSetting.first
      r = setting.ranges.find { |r| r['limit'].nil? || BigDecimal(r['limit']) >= mop }
      r.nil? ? BigDecimal('0') : BigDecimal(r['tax_rate']) * mop * 0.7
    end

    def actual_mop(user, year_date, month)
      year_month = Time.zone.local(year_date.year, month)
      amount_for_tax = SalaryCalculatorService.find_or_create_by(175, user, month_salary_report, salary_type) -
        SalaryCalculatorService.find_by(187, user, year_date.beginning_of_year + month.month)  +
        SalaryCalculatorService.find_by(199, user, year_date.beginning_of_year + month.month) -
        SalaryCalculatorService.find_by(215, user, year_date.beginning_of_year + month.month)
      housing_allowance = SalaryCalculatorService.find_by(48, user, year_date.beginning_of_year + month.month)
      house_deduct =  housing_allowance > 500 ? (housing_allowance - BigDecimal(500)) : BigDecimal(0)
      (amount_for_tax - house_deduct) * 0.8
    end

    #for test
    def check_month(user, year_date, month)
      false
    end
    def calc_double_pay_bonus_and_award(user, year_date)

    end

    def calc_month_1_company(user, year_date)
      check_month(user, year_date, 1) ? user.company_name : nil
    end

    def calc_month_1_income_mop(user, year_date)
      check_month(user, year_date, 1) ? actual_mop(user, year_date, 1) : nil
    end

    def calc_month_1_tax_mop(user, year_date)
      check_month(user, year_date, 1) ? tax_mop(user, year_date, 1) : nil
    end

    def calc_month_2_company(user, year_date)
      check_month(user, year_date, 2) ? user.company_name : nil
    end

    def calc_month_2_income_mop(user, year_date)
      check_month(user, year_date, 2) ? actual_mop(user, year_date, 2) : nil
    end

    def calc_month_2_tax_mop(user, year_date)
      check_month(user, year_date, 2) ? tax_mop(user, year_date, 2) : nil
    end

    def calc_month_3_company(user, year_date)
      check_month(user, year_date, 3) ? user.company_name : nil
    end

    def calc_month_3_income_mop(user, year_date)
      check_month(user, year_date, 3) ? actual_mop(user, year_date, 3) : nil
    end

    def calc_month_3_tax_mop(user, year_date)
      check_month(user, year_date, 3) ? tax_mop(user, year_date, 3) : nil
    end

    def calc_quarter_1_income_mop(user, year_date)
      check_month(user, year_date, 3) ? actual_mop(user, year_date, 1) + actual_mop(user, year_date, 2) + actual_mop(user, year_date, 3) : nil
    end

    def calc_quarter_1_tax_mop_before_adjust(user, year_date)
      check_month(user, year_date, 3) ? tax_mop(user, year_date, 1) + tax_mop(user, year_date, 2) + tax_mop(user, year_date, 3) : nil
    end

    def calc_quarter_1_tax_mop_after_adjust(user, year_date)
      check_month(user, year_date, 3) ? tax_mop(user, year_date, 1) + tax_mop(user, year_date, 2) + tax_mop(user, year_date, 3) : nil
    end

    def calc_month_4_company(user, year_date)
      check_month(user, year_date, 4) ? user.company_name : nil
    end

    def calc_month_4_income_mop(user, year_date)
      check_month(user, year_date, 4) ? actual_mop(user, year_date, 4) : nil
    end

    def calc_month_4_tax_mop(user, year_date)
      check_month(user, year_date, 4) ? tax_mop(user, year_date, 4) : nil
    end

    def calc_month_5_company(user, year_date)
      check_month(user, year_date, 5) ? user.company_name : nil
    end

    def calc_month_5_income_mop(user, year_date)
      check_month(user, year_date, 5) ? actual_mop(user, year_date, 5) : nil
    end

    def calc_month_5_tax_mop(user, year_date)
      check_month(user, year_date, 5) ? tax_mop(user, year_date, 5) : nil
    end

    def calc_month_6_company(user, year_date)
      check_month(user, year_date, 6) ? user.company_name : nil
    end

    def calc_month_6_income_mop(user, year_date)
      check_month(user, year_date, 6) ? actual_mop(user, year_date, 6) : nil
    end

    def calc_month_6_tax_mop(user, year_date)
      check_month(user, year_date, 6) ? tax_mop(user, year_date, 6) : nil
    end

    def calc_quarter_2_income_mop(user, year_date)
      check_month(user, year_date, 6) ? actual_mop(user, year_date, 4) + actual_mop(user, year_date, 5) + actual_mop(user, year_date, 6) : nil
    end

    def calc_quarter_2_tax_mop_before_adjust(user, year_date)
      check_month(user, year_date, 6) ? tax_mop(user, year_date, 4) + tax_mop(user, year_date, 5) + tax_mop(user, year_date, 6) : nil
    end

    def calc_quarter_2_tax_mop_after_adjust(user, year_date)
      check_month(user, year_date, 6) ? tax_mop(user, year_date, 4) + tax_mop(user, year_date, 5) + tax_mop(user, year_date, 6) : nil
    end

    def calc_month_7_company(user, year_date)
      check_month(user, year_date, 7) ? user.company_name : nil
    end

    def calc_month_7_income_mop(user, year_date)
      check_month(user, year_date, 7) ? actual_mop(user, year_date, 7) : nil
    end

    def calc_month_7_tax_mop(user, year_date)
      check_month(user, year_date, 7) ? tax_mop(user, year_date, 7) : nil
    end

    def calc_month_8_company(user, year_date)
      check_month(user, year_date, 8) ? user.company_name : nil
    end

    def calc_month_8_income_mop(user, year_date)
      check_month(user, year_date, 8) ? actual_mop(user, year_date, 8) : nil
    end

    def calc_month_8_tax_mop(user, year_date)
      check_month(user, year_date, 8) ? tax_mop(user, year_date, 8) : nil
    end

    def calc_month_9_company(user, year_date)
      check_month(user, year_date, 9) ? user.company_name : nil
    end

    def calc_month_9_income_mop(user, year_date)
      check_month(user, year_date, 9) ? actual_mop(user, year_date, 9) : nil
    end

    def calc_month_9_tax_mop(user, year_date)
      check_month(user, year_date, 9) ? tax_mop(user, year_date, 9) : nil
    end

    def calc_quarter_3_income_mop(user, year_date)
      check_month(user, year_date, 9) ? actual_mop(user, year_date, 7) + actual_mop(user, year_date, 8) + actual_mop(user, year_date, 9) : nil
    end

    def calc_quarter_3_tax_mop_before_adjust(user, year_date)
      check_month(user, year_date, 9) ? tax_mop(user, year_date, 7) + tax_mop(user, year_date, 8) + tax_mop(user, year_date, 9) : nil
    end

    def calc_quarter_3_tax_mop_after_adjust(user, year_date)
      check_month(user, year_date, 9) ? tax_mop(user, year_date, 7) + tax_mop(user, year_date, 8) + tax_mop(user, year_date, 9) : nil
    end

    def calc_month_10_company(user, year_date)
      check_month(user, year_date, 9) ? user.company_name : nil
    end

    def calc_month_10_income_mop(user, year_date)
      check_month(user, year_date, 10) ? actual_mop(user, year_date, 10) : nil
    end

    def calc_month_10_tax_mop(user, year_date)
      check_month(user, year_date, 10) ? tax_mop(user, year_date, 10) : nil
    end

    def calc_month_11_company(user, year_date)
      check_month(user, year_date, 11) ? user.company_name : nil
    end

    def calc_month_11_income_mop(user, year_date)
      check_month(user, year_date, 11) ? actual_mop(user, year_date, 11) : nil
    end

    def calc_month_11_tax_mop(user, year_date)
      check_month(user, year_date, 11) ? tax_mop(user, year_date, 11) : nil
    end

    def calc_month_12_company(user, year_date)
      check_month(user, year_date, 12) ? user.company_name : nil
    end

    def calc_month_12_income_mop(user, year_date)
      check_month(user, year_date, 12) ? actual_mop(user, year_date, 12) : nil
    end

    def calc_month_12_tax_mop(user, year_date)
      check_month(user, year_date, 12) ? tax_mop(user, year_date, 12) : nil
    end

    def calc_quarter_4_income_mop(user, year_date)
      check_month(user, year_date, 12) ? actual_mop(user, year_date, 10) + actual_mop(user, year_date, 11) + actual_mop(user, year_date, 12) : nil
    end

    def calc_quarter_4_tax_mop_before_adjust(user, year_date)
      check_month(user, year_date, 12) ? tax_mop(user, year_date, 10) + tax_mop(user, year_date, 11) + tax_mop(user, year_date, 12) : nil
    end

    def calc_year_income_mop(user, year_date)
      if check_month(user, year_date, 12)
        #雙糧/花紅/全年勤工(MOP)
        others = BigDecimal(0)
        item = AnnualAwardReportItem.where(user_id: user.id, year_month: year_date.beginning_of_year)
                 .first
        if item&.annual_award_report&.method_of_settling_accounts == 'single-handed'
           others = SalaryCalculatorService.hkd_to_mop(
             item.double_pay_final_hkd + item.end_bonus_final_hkd + item.annual_at_duty_final_hkd)
        end
        (1..12).inject(BigDecimal(0)) do |sum, month|
          sum + actual_mop(user, year_date, month)
        end + others
      else
        nil
      end
    end

    def calc_year_payable_tax_mop(user, year_date)
      if check_month(user, year_date, 12)
        (1..12).inject(BigDecimal(0)) do |sum, month|
          sum + tax_mop(user, year_date, month)
        end
      else
        nil
      end
    end

    def calc_year_paid_tax_mop(user, year_date)
      if check_month(user, year_date, 12)
        (1..12).inject(BigDecimal(0)) do |sum, month|
          sum + self.send("month_#{month}_tax_mop")
        end
      else
        nil
      end
    end

    def calc_quarter_4_tax_mop_after_adjust(user, year_date)
      check_month(user, year_date, 12) ? self.year_payable_tax_mop - self.year_paid_tax_mop : nil
    end

  end
end
