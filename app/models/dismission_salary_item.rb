# == Schema Information
#
# Table name: dismission_salary_items
#
#  id                                         :integer          not null, primary key
#  user_id                                    :integer
#  dimission_id                               :integer
#  base_salary_hkd                            :decimal(15, 2)
#  benefits_hkd                               :decimal(15, 2)
#  annual_incentive_hkd                       :decimal(15, 2)
#  housing_benefits_hkd                       :decimal(15, 2)
#  seniority_compensation_hkd                 :decimal(15, 2)
#  dismission_annual_holiday_compensation_hkd :decimal(15, 2)
#  created_at                                 :datetime         not null
#  updated_at                                 :datetime         not null
#  dismission_inform_period_compensation_hkd  :decimal(15, 2)
#  has_seniority_compensation                 :boolean
#  has_inform_period_compensation             :boolean
#  approved                                   :boolean
#
# Indexes
#
#  index_dismission_salary_items_on_dimission_id  (dimission_id)
#  index_dismission_salary_items_on_user_id       (user_id)
#
# Foreign Keys
#
#  fk_rails_59ce2b57e0  (dimission_id => dimissions.id)
#  fk_rails_ab167eed00  (user_id => users.id)
#
#todo: remove
class DismissionSalaryItem < ApplicationRecord
  include StatementAble

  belongs_to :user
  belongs_to :dimission

  def approve
    if self.approved
      return false
    end

    ActiveRecord::Base.transaction do
      self.approved = true

      total_hkd_amount = (self.base_salary_hkd +
        self.benefits_hkd +
        self.annual_incentive_hkd +
        self.housing_benefits_hkd +
        self.seniority_compensation_hkd +
        self.dismission_annual_holiday_compensation_hkd +
        self.dismission_inform_period_compensation_hkd)

      BankAutoPayReportItem.create!(
        record_type: :leave_salary,
        year_month: self.dimission.last_work_date.beginning_of_month,
        balance_date: self.dimission.last_work_date,
        user_id: self.dimission.user.id,
        amount_in_mop: BigDecimal('0'),
        amount_in_hkd: total_hkd_amount,
        begin_work_date: self.dimission.last_work_date.beginning_of_month,
        end_work_date: self.dimission.last_work_date,
        cash_or_check: 'cash',
        leave_in_this_month: true
      )
      self.save!
    end

    true
  end

  class << self

    def extra_joined_association_names
      [:dimission]
    end

    def default_query_decorator(query, attr, value)
      if attr =~ /^dimission\.(\w+)$/
        query.where(dimissions: { $1 => value })
      else
        super
      end
    end

    def generate(dimission)
      # 如果最后工作日是当月的最后一天，则正常结算工资
      return if dimission.last_work_date.day == dimission.last_work_date.end_of_month.day

      calc_params = self.create_params - %w(user_id dimission_id)
      self.where(user: dimission.user, dimission: dimission.id)
        .first_or_create(user: dimission.user, dimission: dimission)
        .update(
          calc_params.map { |param|
            [param, self.send("calc_#{param}", dimission)]
          }.to_h
        )
    end

    def calc
      SalaryCalculationService
    end

    def calc_base_salary_hkd(dimission)
      calc.raw_salary_in_date(dimission.user, dimission.last_work_date, 'basic_salary', 'hkd') +
        calc.mop_to_hkd(calc.raw_salary_in_date(dimission.user, dimission.last_work_date, 'basic_salary', 'mop'))
    end

    def calc_benefits_hkd(dimission)
      calc.raw_salary_in_date(dimission.user, dimission.last_work_date, 'bonus', 'hkd') +
        calc.mop_to_hkd(calc.raw_salary_in_date(dimission.user, dimission.last_work_date, 'bonus', 'mop'))
    end

    def calc_annual_incentive_hkd(dimission)
      calc.raw_salary_in_date(dimission.user, dimission.last_work_date, 'attendance_award', 'hkd') +
        calc.mop_to_hkd(calc.raw_salary_in_date(dimission.user, dimission.last_work_date, 'attendance_award', 'mop'))
    end

    def calc_housing_benefits_hkd(dimission)
      calc.raw_salary_in_date(dimission.user, dimission.last_work_date, 'house_bonus', 'hkd') +
        calc.mop_to_hkd(calc.raw_salary_in_date(dimission.user, dimission.last_work_date, 'house_bonus', 'mop'))
    end

    def calc_has_seniority_compensation(dimission)
      dimission.dimission_type == :termination && !dimission.termination_is_reasonable
    end

    def calc_seniority_compensation_hkd(dimission)
      seniority_compensation_days = if dimission.dimission_type == :termination
                                      Dimission.termination_compensation(dimission.user,
                                                                         dimission.termination_is_reasonable,
                                                                         dimission.last_work_date)
                                    else
                                      0
                                    end
      basic_salary_mop = calc.raw_salary_in_date(dimission.user, dimission.last_work_date, 'basic_salary', 'mop')

      seniority_table = Config.get('salary_constants')['seniority_compensation_table']
      seniority_year_steps = seniority_table.keys.sort_by { |year| year.to_f }
      work_years = (dimission.last_work_date.in_time_zone - dimission.user.career_entry_date) / 1.year
      seniority_factor = seniority_table[seniority_year_steps.find { |year| work_years < seniority_table[year].to_f }]

      # 最高補償12個月
      compensation_month_limit = BigDecimal('12')
      # 使用计算的底薪上限为20000 MOP
      basic_salary_mop_limit = BigDecimal('20000')
      # 每月都按照30天計算
      days_in_month = BigDecimal('30')

      basic_salary_mop = [basic_salary_mop, basic_salary_mop_limit].min
      compensation_limit = basic_salary_mop * compensation_month_limit
      seniority_compensation_mop = basic_salary_mop / days_in_month * BigDecimal(seniority_compensation_days) * BigDecimal(seniority_factor)
      calc.mop_to_hkd [compensation_limit,  seniority_compensation_mop].min
    end

    def calc_dismission_annual_holiday_compensation_hkd(dimission)
      # 每月都按照30天計算
      days_in_month = BigDecimal('30')
      basic_salary_mop = calc.raw_salary_in_date(dimission.user, dimission.last_work_date, 'basic_salary', 'mop')
      calc.mop_to_hkd(basic_salary_mop / days_in_month * BigDecimal(dimission.remaining_annual_holidays.presence || 0))
    end

    def calc_has_inform_period_compensation(dimission)
      (dimission.dimission_type == :resignation && !dimission.resignation_is_inform_period_exempted) ||
        (dimission.dimission_type == :termination)
    end

    def calc_dismission_inform_period_compensation_hkd(dimission)
      # 每月都按照30天計算
      days_in_month = BigDecimal('30')

      basic_salary_mop = calc.raw_salary_in_date(dimission.user, dimission.last_work_date, 'basic_salary', 'mop')

      if dimission.dimission_type == :resignation
        if dimission.resignation_is_inform_period_exempted
          BigDecimal('0.0')
        else
          compensation_mop = BigDecimal('-1.0') * basic_salary_mop / days_in_month * BigDecimal(dimission.resignation_inform_period_penalty.presence || 0)
          calc.mop_to_hkd(compensation_mop)
        end
      elsif dimission.dimission_type == :termination
        compensation_mop = basic_salary_mop / days_in_month * BigDecimal(dimission.termination_compensation.presence || 0)
        calc.mop_to_hkd(compensation_mop)
      else
        BigDecimal('0.0')
      end
    end

    def calc_approved(dimission)
      false
    end

  end

end
