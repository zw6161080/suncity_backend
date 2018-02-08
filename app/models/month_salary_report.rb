# == Schema Information
#
# Table name: month_salary_reports
#
#  id               :integer          not null, primary key
#  status           :string
#  year_month       :datetime
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  salary_type      :string
#  generate_process :decimal(10, 2)
#

class MonthSalaryReport < ApplicationRecord
  include MonthSalaryReportValidators
  validates :status, inclusion: {in: %w(not_calculating calculating completed president_examine preliminary_examine fail)}, unless: :status_is_nil?
  validates :salary_type, inclusion: {in: %w(on_duty left)}
  after_create :set_initial_status
  validates_with SalaryAndYearMonth, on: :create

  def status_is_nil?
    self.status.nil?
  end

  def president_examine
    ActiveRecord::Base.transaction do
      self.users_year_month.each do |salary_value|
        user = salary_value.user
        calc_bank_auto_pay(user, salary_value)
        calc_pay_slip(user, salary_value)
        calc_occupation_tax(user)
      end
      # 公积金供款报表;155: 是否扣公積金
      ContributionReportItem.generate_valid_users(
        self.year_month,
        User.where(id: SalaryValue.where(
          salary_type: :on_duty, year_month: self.year_month, salary_column_id: 155, boolean_value: :true).map{|item| item['user_id']}
        )
      )
      self.update(status: :president_examine)
    end
  end

  def preliminary_examine
    self.update(status: :preliminary_examine) if self.status == 'completed'
  end

  def cancel
    self.update(status: :completed)  if self.status == 'preliminary_examine'
  end

  def self.create_with_params(params)
    self.create(year_month: params[:year_month], salary_type: :on_duty)
  end

  def self.create_with_params_by_left(params)
    self.find_or_create_by(year_month: params[:year_month], salary_type: :left)
  end

  def set_initial_status
    self.update_columns(status: :not_calculating)
    self.calculate_later
  end

  def calculate_later
    # AccountingMonthSalaryReportJob.perform_now(self)
    AccountingMonthSalaryReportJob.perform_later(self)
  end

  def re_calculate_later
    SalaryValue.where(year_month: self.year_month, salary_type: self.salary_type).destroy_all
    self.update_columns(status: :not_calculating)
    self.calculate_later
  end

  def re_calculate_later_by_user(user, resignation_record_id)
    SalaryValue.where(year_month: self.year_month, salary_type: self.salary_type, user_id: user.id, resignation_record_id: resignation_record_id).destroy_all
    self.calculate_leaving_salary_record_by_user(user, resignation_record_id)
  end

  def calculate
    SalaryCalculatorService.generate(self)
    self.update_columns(status: :completed)
  end

  def calculate_leaving_salary_record_by_user(user, resignation_record_id)
    SalaryCalculatorService.generate_leaving_salary_record(self, user, resignation_record_id)
  end

  def update_salary_value_to_president_examine
    SalaryValue.where(year_month: self.year_month, salary_type: self.salary_type, salary_column_id: 0).each do|record|
      record.update_value('president_examine')
    end
  end

  def update_salary_value_to_preliminary_examine
    SalaryValue.where(year_month: self.year_month, salary_type: self.salary_type, salary_column_id: 0).each do|record|
      record.update_value('preliminary_examine')
    end
  end

  def update_salary_value_to_not_granted
    SalaryValue.where(year_month: self.year_month, salary_type: self.salary_type, salary_column_id: 0).each do|record|
      record.update_value('not_granted')
    end
  end

  def examine_by_user(user, resignation_record_id)
    ActiveRecord::Base.transaction do
      salary_value = SalaryValue.find_by(
        user_id: user.id, year_month: self.year_month, salary_column_id: 0, salary_type: self.salary_type, resignation_record_id: resignation_record_id
      ) rescue nil
      calc_bank_auto_pay(user, salary_value)
      calc_pay_slip(user, salary_value)
      calc_occupation_tax(user)
      salary_value.update_value('granted') if salary_value.string_value == 'not_granted'
    end
  end

  def users_year_month
    SalaryValue.where(year_month: self.year_month, salary_type: 'on_duty',salary_column_id: 0)
  end

  def self.salary_value(query)
    tag = 0
    query_string = query.map{|item| "user_id = #{item['user_id']} AND year_month  = :year_month_#{tag += 1}"}.join(" OR ")
    tag = 0
    query_string_2 = query.map{|item| ["year_month_#{tag += 1}".to_sym, item.year_month]}.to_h

   ActiveModelSerializers::SerializableResource.new(tag == 0 ? query : SalaryValue.where(query_string, query_string_2), each_serializer: RawSalaryValueSerializer ).as_json[:salary_values]
  end

  def self.raw_salary_value(query)
    tag = 0
    query_string = query.map{|item| "user_id = #{item['user_id']} AND year_month  = :year_month_#{tag += 1}"}.join(" OR ")
    tag = 0
    query_string_2 = query.map{|item| ["year_month_#{tag += 1}".to_sym, item.year_month]}.to_h
    SalaryValue.where(query_string, query_string_2)
  end

  def self.users_by_left
    SalaryValue.where(salary_column_id: 0, salary_type: 'left')
  end

  def self.users_by_all
    SalaryValue.all.where(salary_column_id: 0,string_value: [:granted, :president_examine])
  end

  def show_by_options
    query = self.users_year_month.join_user
    year =  query.select("extract(year from year_month AT TIME ZONE 'cst +08:00') as year ")
                                 .map{|item| item['year']}.uniq.sort.map{|item| get_multi_language item}
    month =  query.select("extract(month from year_month AT TIME ZONE 'cst +08:00') as month ")
                                  .map{|item| item['month']}.uniq.sort.map{|item| get_multi_language item}
    company_name = Config.get_all_option_from_selects(:company_name)
    grade = Config.get_all_option_from_selects(:grade)
    location_id =  Location.where(id: query.select("users.location_id").map{|item| item['location_id']})
    position_id =  Position.where(id: query.select("users.position_id").map{|item| item['position_id']})
    department_id =  Department.where(id: query.select("users.department_id").map{|item| item['department_id']})
    {
      '3': year,
      '4': month,
      '5': company_name,
      '9': grade,
      '6': location_id,
      '8': position_id,
      '7': department_id,
    }
  end

  def self.index_by_left_options
    query = users_by_left.join_user
    year =  query.select("extract(year from year_month AT TIME ZONE 'cst +08:00') as year ")
              .map{|item| item['year']}.uniq.sort.map{|item| get_multi_language item}
    month =  query.select("extract(month from year_month AT TIME ZONE 'cst +08:00') as month ")
               .map{|item| item['month']}.uniq.sort.map{|item| get_multi_language item}
    company_name = Config.get_all_option_from_selects(:company_name)
    grade = Config.get_all_option_from_selects(:grade)
    location_id =  Location.where(id: query.select("users.location_id").map{|item| item['location_id']})
    position_id =  Position.where(id: query.select("users.position_id").map{|item| item['position_id']})
    department_id =  Department.where(id: query.select("users.department_id").map{|item| item['department_id']})
    status = [
      {
        key: 'granted',
        chinese_name: '已審批',
        english_name: 'Approved',
        simple_chinese_name: '已审批'
      },
      {
        key: 'not_granted',
        chinese_name: '未審批',
        english_name: 'Not approved',
        simple_chinese_name: '未审批'
      }
    ]
    {
      '3': year,
      '4': month,
      '5': company_name,
      '9': grade,
      '6': location_id,
      '8': position_id,
      '7': department_id,
      '0': status
    }
  end

  def self.index_options
    query = users_by_all.join_user
    year =  query.select("extract(year from year_month AT TIME ZONE 'cst +08:00') as year ")
              .map{|item| item['year']}.uniq.sort.map{|item| get_multi_language item}
    month =  query.select("extract(month from year_month AT TIME ZONE 'cst +08:00') as month ")
               .map{|item| item['month']}.uniq.sort.map{|item| get_multi_language item}
    company_name = Config.get_all_option_from_selects(:company_name)
    grade = Config.get_all_option_from_selects(:grade)
    location_id =  Location.where(id: query.select("users.location_id").map{|item| item['location_id']})
    position_id =  Position.where(id: query.select("users.position_id").map{|item| item['position_id']})
    department_id =  Department.where(id: query.select("users.department_id").map{|item| item['department_id']})
    {
      '3': year,
      '4': month,
      '5': company_name,
      '9': grade,
      '6': location_id,
      '8': position_id,
      '7': department_id,
    }
  end

  private

  # 职业税 (需要包括全年在职过的员工)
  def calc_occupation_tax(user)
    occupation_tax_item = OccupationTaxItem.find_or_create_by(user_id: user.id, year: self.year_month.beginning_of_year)
    occupation_tax_item.add_month_info(user, self.year_month)
  end

  def calc_pay_slip(user, salary_value)
    PaySlip.create(year_month: salary_value.year_month,
                   salary_begin: SalaryCalculatorService.find_by(144, user, salary_value.year_month, salary_value.resignation_record_id),
                   salary_end: SalaryCalculatorService.find_by(145, user, salary_value.year_month,salary_value.resignation_record_id),
                   user_id: salary_value.user_id,
                   entry_on_this_month:SalaryCalculatorService.find_by(159, user, salary_value.year_month, salary_value.resignation_record_id),
                   leave_on_this_month:SalaryCalculatorService.find_by(160, user, salary_value.year_month, salary_value.resignation_record_id),
                   comment: SalaryCalculatorService.find_by(165, user, salary_value.year_month, salary_value.resignation_record_id),
                   salary_type: self.salary_type, resignation_record_id: salary_value.resignation_record_id, )
  end

  def calc_bank_auto_pay(user, salary_value)

    amount_in_mop = if user.company_name == 'suncity_group_commercial_consulting'
                      SalaryCalculatorService.find_by(195, user, salary_value.year_month, salary_value.resignation_record_id) +
                        SalaryCalculatorService.hkd_to_mop(SalaryCalculatorService.find_by(218, user, salary_value.year_month, salary_value.resignation_record_id) )+
                        SalaryCalculatorService.hkd_to_mop(SalaryCalculatorService.find_by(123, user, salary_value.year_month, salary_value.resignation_record_id) )+
                        SalaryCalculatorService.hkd_to_mop(SalaryCalculatorService.find_by(139, user, salary_value.year_month, salary_value.resignation_record_id) )+
                        SalaryCalculatorService.hkd_to_mop(SalaryCalculatorService.find_by(142, user, salary_value.year_month, salary_value.resignation_record_id) )
                    else
                      SalaryCalculatorService.find_by(195, user, salary_value.year_month, salary_value.resignation_record_id) +
                        SalaryCalculatorService.hkd_to_mop(SalaryCalculatorService.find_by(123, user, salary_value.year_month, salary_value.resignation_record_id) )
                    end
    amount_in_hkd = if user.company_name == 'suncity_group_commercial_consulting'
                      BigDecimal(0)
                    else
                      SalaryCalculatorService.find_by(218, user, salary_value.year_month, salary_value.resignation_record_id) +
                        SalaryCalculatorService.find_by(139, user, salary_value.year_month, salary_value.resignation_record_id) +
                        SalaryCalculatorService.find_by(142, user, salary_value.year_month, salary_value.resignation_record_id)
                    end
    cash_or_check = SalaryCalculatorService.find_by(160, user, salary_value.year_month, salary_value.resignation_record_id) ?
      'cash' : SalaryCalculatorService.find_by(158,user, salary_value.year_month, salary_value.resignation_record_id)
    # 银行自动转账报表
    BankAutoPayReportItem.create(
      record_type: :salary, year_month: salary_value.year_month,
      balance_date: Time.zone.now.beginning_of_day, user_id: salary_value.user_id,
      amount_in_mop: amount_in_mop, amount_in_hkd: amount_in_hkd,
      cash_or_check: cash_or_check&.send(:[],'key'),
      begin_work_date: SalaryCalculatorService.find_by(144, user, salary_value.year_month, salary_value.resignation_record_id),
      end_work_date: SalaryCalculatorService.find_by(145, user, salary_value.year_month, salary_value.resignation_record_id),
      leave_in_this_month: SalaryCalculatorService.find_by(160, user, salary_value.year_month, salary_value.resignation_record_id),
      company_name: SalaryCalculatorService.find_by(5, user, salary_value.year_month, salary_value.resignation_record_id)&.send(:[],'key'),
      department_id: SalaryCalculatorService.find_by(7, user, salary_value.year_month, salary_value.resignation_record_id)&.send(:[],'id'),
      position_id: SalaryCalculatorService.find_by(8, user, salary_value.year_month, salary_value.resignation_record_id)&.send(:[],'id'),
      position_of_govt_record: ProfileService.position_of_govt_record(user),
      id_number: SalaryCalculatorService.find_by(148, user, salary_value.year_month, salary_value.resignation_record_id),
      bank_of_china_account_mop: SalaryCalculatorService.find_by(161, user, salary_value.year_month, salary_value.resignation_record_id),
      bank_of_china_account_hkd: SalaryCalculatorService.find_by(162, user, salary_value.year_month, salary_value.resignation_record_id),
    )
  end
  def get_multi_language(item)
    {
      key: item,
      chinese_name: item,
      english_name: item,
      simple_chinese_name: item
    }
  end

  def self.get_multi_language(item)
    {
      key: item,
      chinese_name: item,
      english_name: item,
      simple_chinese_name: item
    }
  end
end
