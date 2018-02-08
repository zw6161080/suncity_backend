# == Schema Information
#
# Table name: employee_fund_switching_report_items
#
#  id                                                              :integer          not null, primary key
#  user_id                                                         :integer
#  pension_fund_name_in_employer_contribution                      :string
#  contribution_allocation_percentage_in_employer_contribution     :decimal(10, 2)
#  name_of_fund_to_be_redeemed_in_employer_contribution            :string
#  percentage_in_employer_contribution                             :decimal(10, 2)
#  name_of_fund_to_be_allocated_in_employer_contribution           :string
#  pension_fund_name_in_employer_voluntary_contribution            :string
#  contribution_allocation_percentage_in_employer_voluntary_contri :decimal(10, 2)
#  name_of_fund_to_be_redeemed_in_employer_voluntary_contribution  :string
#  percentage_in_employer_voluntary_contribution                   :decimal(10, 2)
#  name_of_fund_to_be_allocated_in_employer_voluntary_contribution :string
#  pension_fund_name_in_employee_contribution                      :string
#  contribution_allocation_percentage_in_employee_contribution     :decimal(10, 2)
#  name_of_fund_to_be_redeemed_in_employee_contribution            :string
#  percentage_in_employee_contribution                             :decimal(10, 2)
#  name_of_fund_to_be_allocated_in_employee_contribution           :string
#  pension_fund_name_in_employee_voluntary_contribution            :string
#  contribution_allocation_percentage_in_employee_voluntary_contri :decimal(10, 2)
#  name_of_fund_to_be_redeemed_in_employee_voluntary_contribution  :string
#  percentage_in_employee_voluntary_contribution                   :decimal(10, 2)
#  name_of_fund_to_be_allocated_in_employee_voluntary_contribution :string
#  pension_fund_name_in_government_contribution                    :string
#  contribution_allocation_percentage_in_government_contribution   :decimal(10, 2)
#  name_of_fund_to_be_redeemed_in_government_contribution          :string
#  percentage_in_government_contribution                           :decimal(10, 2)
#  name_of_fund_to_be_allocated_in_government_contribution         :string
#  created_at                                                      :datetime         not null
#  updated_at                                                      :datetime         not null
#
# Indexes
#
#  index_employee_fund_switching_report_items_on_user_id  (user_id)
#

class EmployeeFundSwitchingReportItem < ApplicationRecord
  include StatementAble
  belongs_to :user

  scope :order_default, lambda{
    order('users.empoid asc')
  }

  class << self

    def extra_joined_association_names
      [{user: {profile: :provident_fund}}]
    end

    def generate_all
      User.all.find_each do |user|
        generate(user)
      end
    end

    def generate(user)
      self
          .create(user_id: user.id,contribution_allocation_percentage_in_employee_voluntary_contri: BigDecimal.new(user.profile.provident_fund.try(:steady_growth_fund_percentage) || ''),pension_fund_name_in_employee_voluntary_contribution: '平穩增長基金'  )
      self
          .create(user_id: user.id,contribution_allocation_percentage_in_employee_voluntary_contri: BigDecimal.new(user.profile.provident_fund.try(:steady_fund_percentage) || ''),pension_fund_name_in_employee_voluntary_contribution: '穩健基金'  )
      self
          .create(user_id: user.id,contribution_allocation_percentage_in_employee_voluntary_contri: BigDecimal.new(user.profile.provident_fund.try(:a_fund_percentage) || ''),pension_fund_name_in_employee_voluntary_contribution: 'A基金'  )
      self
          .create(user_id: user.id,contribution_allocation_percentage_in_employee_voluntary_contri: BigDecimal.new(user.profile.provident_fund.try(:b_fund_percentage) || ''),pension_fund_name_in_employee_voluntary_contribution: 'B基金'  )
    end

    def delete(user)
      self
          .where(user: user)
          .destroy_all
    end
  end

end
