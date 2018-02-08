# == Schema Information
#
# Table name: bank_auto_pay_report_items
#
#  id                        :integer          not null, primary key
#  record_type               :integer
#  year_month                :datetime
#  balance_date              :datetime
#  user_id                   :integer
#  amount_in_mop             :decimal(15, 2)
#  amount_in_hkd             :decimal(15, 2)
#  begin_work_date           :datetime
#  end_work_date             :datetime
#  cash_or_check             :string
#  leave_in_this_month       :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  company_name              :string
#  department_id             :integer
#  position_id               :integer
#  position_of_govt_record   :string
#  id_number                 :string
#  bank_of_china_account_mop :string
#  bank_of_china_account_hkd :string
#
# Indexes
#
#  index_bank_auto_pay_report_items_on_department_id  (department_id)
#  index_bank_auto_pay_report_items_on_position_id    (position_id)
#  index_bank_auto_pay_report_items_on_user_id        (user_id)
#

class BankAutoPayReportItem < ApplicationRecord
  belongs_to :department
  belongs_to :position

  include StatementAble
  validates :cash_or_check, inclusion: {
      in: ['cash', 'check', nil], message: '%{value} is not a valid cash_or_check'
  }
  belongs_to :user
  enum record_type: {annual_reward: 1, leave_salary: 2, salary: 3 }

  scope :order_default, lambda{
    order('balance_date DESC, record_type ASC, users.empoid ASC')
  }

  scope :by_year_month, lambda{|year_month|
    where(year_month: year_month.map{|year_month|
      Time.zone.parse(year_month) }) if year_month
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
end
