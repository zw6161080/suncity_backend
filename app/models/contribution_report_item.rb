# == Schema Information
#
# Table name: contribution_report_items
#
#  id                                               :integer          not null, primary key
#  user_id                                          :integer
#  year_month                                       :datetime
#  relevant_income                                  :decimal(15, 2)
#  employee_voluntary_contribution_percentage       :decimal(15, 2)
#  employee_voluntary_contribution_amount           :decimal(15, 2)
#  percentage_of_voluntary_contributions_of_members :decimal(15, 2)
#  membership_voluntary_contributions_amount        :decimal(15, 2)
#  employer_contribution_percentage                 :decimal(15, 2)
#  employer_contribution_count                      :decimal(15, 2)
#  percentage_of_contribution_of_members            :decimal(15, 2)
#  percentage_of_contribution_of_governmment        :decimal(15, 2)
#  count_of_contribution_of_governmment             :decimal(15, 2)
#  created_at                                       :datetime         not null
#  updated_at                                       :datetime         not null
#  department_id                                    :integer
#  position_id                                      :integer
#  grade                                            :integer
#  member_retirement_fund_number                    :string
#
# Indexes
#
#  index_contribution_report_items_on_department_id  (department_id)
#  index_contribution_report_items_on_position_id    (position_id)
#  index_contribution_report_items_on_user_id        (user_id)
#

class ContributionReportItem < ApplicationRecord
  include StatementAble
  belongs_to :user
  belongs_to :department
  belongs_to :position

  scope :by_year_month, lambda{|year_month|
     where(year_month: year_month.map{|year_month|
       Time.zone.parse(year_month) }) if year_month
  }

  scope :by_report_year_month, -> (report_year_month) {
    where(year_month: Time.zone.parse(report_year_month).beginning_of_month)
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

    def extra_query_params
      [ { key: 'report_year_month' } ]
    end

    def extra_joined_association_names
      [{user: {profile: :provident_fund}}]
    end

    def year_month_options
       self.joined_query.pluck(:year_month)
    end

    def generate(user, year_month_date, is_leave)
      year_month = year_month_date.beginning_of_month
      calc_params = self.create_params - %w(user_id year_month)
      self.where(user_id: user.id, year_month:year_month)
          .first_or_create(user_id: user.id, year_month: year_month)
          .update(
              calc_params.map { |param|
                [param, self.send("calc_#{param}", user, year_month,is_leave)]
              }.to_h
          )
    end

    def generate_all(year_month_date)
      User.find_each do |user|
        if  user.profile&.provident_fund
          if self.where(user_id: user.id, year_month: year_month_date).count < 1
            generate(user, year_month_date.beginning_of_month, ProfileService.is_leave_in_this_month(user, year_month_date.beginning_of_month))
          end
        else
          next
        end
      end
    end

    def generate_valid_users(year_month_date, users)
      users.find_each do |user|
        if  user.profile&.provident_fund
          if self.where(user_id: user.id, year_month: year_month_date).count < 1
            generate(user, year_month_date.beginning_of_month, ProfileService.is_leave_in_this_month(user, year_month_date.beginning_of_month))
          end
        else
          next
        end
      end
    end

    def calc_department_id(user, year_month_date, is_leave)
      ProfileService.department(user, year_month_date.end_of_year.beginning_of_day)&.id
    end


    def calc_position_id(user, year_month_date, is_leave)
      ProfileService.position(user, year_month_date.end_of_year.beginning_of_day)&.id
    end

    def calc_grade(user, year_month_date, is_leave)
      ProfileService.grade(user, year_month_date.end_of_year.beginning_of_day)
    end

    def calc_member_retirement_fund_number(user, year_month_date, is_leave)
      user.provident_fund&.member_retirement_fund_number
    end

    def calc_relevant_income(user, year_month_date,is_leave)
      if is_leave
        BigDecimal(0)
      else
        get_basic_salary(user, year_month_date)&.round(0)
      end
    end

    def calc_employee_voluntary_contribution_percentage(user, year_month_date, is_leave)
      if is_leave
        BigDecimal(0)
      else
        get_cal_percentage(user)&.round(2)
      end
    end


    def calc_employee_voluntary_contribution_amount(user, year_month_date,is_leave)
      if is_leave
        BigDecimal(0)
      else
        (get_basic_salary(user, year_month_date) * get_cal_percentage(user) * 0.01).round(0)
      end
    end

    def calc_percentage_of_voluntary_contributions_of_members(user, year_month_date, is_leave)
      if is_leave
        BigDecimal(0)
      else
        get_cal_percentage(user)&.round(2)
      end
    end

    def calc_membership_voluntary_contributions_amount(user, year_month_date, is_leave)
      if is_leave
        BigDecimal(0)
      else
        (get_basic_salary(user, year_month_date) * get_cal_percentage(user) * 0.01).round(0)
      end
    end

    def calc_employer_contribution_percentage(user, year_month_date, is_leave)
      nil
    end

    def calc_employer_contribution_count(user, year_month_date, is_leave)
      nil
    end

    def calc_percentage_of_contribution_of_members(user, year_month_date, is_leave)
      nil
    end

    def calc_count_of_contribution_of_members(user, year_month_date, is_leave)
      nil
    end

    def calc_percentage_of_contribution_of_governmment(user, year_month_date, is_leave)
      nil
    end

    def calc_count_of_contribution_of_governmment(user, year_month_date, is_leave)
      nil
    end

    private
    def get_basic_salary(user, year_month_date)
      SalaryCalculatorService.hkd_to_mop(ActiveModelSerializers::SerializableResource.new(SalaryValue.find_by(user_id: user.id, salary_column_id: 39, year_month: year_month_date)).serializer_instance.value) rescue BigDecimal(0)
    end

    def get_cal_percentage(user)
      if [1,2].include? user.grade.to_i
        BigDecimal.new(7)
      elsif [3,4].include? user.grade.to_i
        BigDecimal.new(6)
      elsif user.grade.to_i == 5
        BigDecimal.new(5)
      else
        BigDecimal.new(0)
      end
    end

  end

end
