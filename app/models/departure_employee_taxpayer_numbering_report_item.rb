# == Schema Information
#
# Table name: departure_employee_taxpayer_numbering_report_items
#
#  id                              :integer          not null, primary key
#  year_month                      :datetime
#  user_id                         :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  beneficiary_name                :string
#  deployer_retirement_fund_number :string
#
# Indexes
#
#  departure_employee_taxpayer_on_user_id  (user_id)
#

class DepartureEmployeeTaxpayerNumberingReportItem < ApplicationRecord
  include StatementAble
  belongs_to :user

  scope :order_default, lambda{
    order('year_month asc, users.empoid asc')
  }

  scope :by_year_month, lambda{|year_month|
    where(year_month: year_month.map{|year_month|
      Time.zone.parse(year_month) }) if year_month
  }
  class << self



    def extra_joined_association_names
      [{user: {profile: :provident_fund}}]
    end

    def generate(user, year_month_date)
      year_month = year_month_date.beginning_of_month
      calc_params = self.create_params - %w(user_id year_month beneficiary_name deployer_retirement_fund_number)
      self.where(user: user, year_month:year_month..year_month.end_of_month)
          .first_or_create(user:user, year_month: year_month, beneficiary_name: user.chinese_name, deployer_retirement_fund_number: get_right_number(user.company_name))
          .update(
              calc_params.map { |param|
                [param, self.send("calc_#{param}", user, year_month)]
              }.to_h
          )
    end

    def generate_all(year_month_date)
      User.find_each do |user|
        generate(user, year_month_date)
      end
    end

    def get_right_number(company_name)
      case company_name
      when 'suncity_gaming_promotion_company_limited'
        '12012011'
      when 'suncity_group_commercial_consulting'
        '12022013'
      when 'suncity_group_tourism_limited'
        '12032016'
      when 'tian_mao_yi_hang'
        '20012014'
      end
    end
  end

end
