# == Schema Information
#
# Table name: annual_award_report_items
#
#  id                              :integer          not null, primary key
#  annual_award_report_id          :integer
#  user_id                         :integer
#  add_double_pay                  :boolean
#  double_pay_hkd                  :decimal(15, 2)
#  double_pay_alter_hkd            :decimal(15, 2)
#  double_pay_final_hkd            :decimal(15, 2)
#  add_end_bonus                   :boolean
#  end_bonus_hkd                   :decimal(15, 2)
#  praise_times                    :integer
#  end_bonus_add_hkd               :decimal(15, 2)
#  absence_times                   :integer
#  notice_times                    :integer
#  late_times                      :integer
#  lack_sign_card_times            :integer
#  punishment_times                :integer
#  de_end_bonus_for_absence_hkd    :decimal(15, 2)
#  de_bonus_for_notice_hkd         :decimal(15, 2)
#  de_end_bonus_for_late_hkd       :decimal(15, 2)
#  de_end_bonus_for_sign_card_hkd  :decimal(15, 2)
#  de_end_bonus_for_punishment_hkd :decimal(15, 2)
#  de_bonus_total_hkd              :decimal(15, 2)
#  end_bonus_final_hkd             :decimal(15, 2)
#  present_at_duty_first_half      :boolean
#  annual_at_duty_basic_hkd        :decimal(15, 2)
#  annual_at_duty_final_hkd        :decimal(15, 2)
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  department_id                   :integer
#  position_id                     :integer
#  date_of_employment              :datetime
#  work_days_this_year             :decimal(15, 2)
#  deducted_days                   :decimal(15, 2)
#
# Indexes
#
#  index_annual_award_report_items_on_annual_award_report_id  (annual_award_report_id)
#  index_annual_award_report_items_on_department_id           (department_id)
#  index_annual_award_report_items_on_position_id             (position_id)
#  index_annual_award_report_items_on_user_id                 (user_id)
#

class AnnualAwardReportItem < ApplicationRecord
  include StatementAble
  belongs_to :user
  belongs_to :annual_award_report
  after_create :create_annual_attend_report
  before_update :validate_annual_award_report
  after_update :calc_double_pay_final_hkd
  belongs_to :department
  belongs_to :position

  scope :order_default, lambda{
    order('users.empoid asc')
  }
  scope :by_name, lambda{|name|
    where(users:{ select_language => name}) if name
  }


  scope :order_name, -> (sort_direction) {
    order("users.#{select_language} #{sort_direction.first}")
  }




  def self.joined_query(annual_award_report_id)
    self.where(annual_award_report_id: annual_award_report_id).left_outer_joins(user: [:department, :location, :position, :profile])
  end

  def validate_annual_award_report
    unless self.annual_award_report.status == 'not_granted'
      throw abort: "annual_award_report(id: #{self.annual_award_report.id})" + "can't be modified"
    end
  end

  def calc_double_pay_final_hkd
    self.update_column(:double_pay_final_hkd, SalaryCalculatorService.math_add(self.double_pay_hkd) + SalaryCalculatorService.math_add(self.double_pay_alter_hkd))
  end

  def create_annual_attend_report
    ActiveRecord::Base.transaction do
      year_month = self.annual_award_report.year_month
      annual_award_report = AnnualAwardReport.find_by(id: self.annual_award_report_id)
      AnnualAttendReport.create(user_id: self.user_id,
                                department_id: self.user.department_id,
                                year: year_month.year,
                                is_meet: self.present_at_duty_first_half,
                                settlement_date: annual_award_report&.award_date&.to_date,
                                money_hkd: self.annual_at_duty_final_hkd)
    end
  end
end
