# == Schema Information
#
# Table name: attendance_month_report_items
#
#  id                                   :integer          not null, primary key
#  user_id                              :integer
#  year_month                           :datetime
#  normal_overtime_hours                :decimal(10, 2)
#  holiday_overtime_hours               :decimal(10, 2)
#  compulsion_holiday_compensation_days :decimal(10, 2)
#  public_holiday_compensation_days     :decimal(10, 2)
#  absenteeism_days                     :decimal(10, 2)
#  immediate_leave_days                 :decimal(10, 2)
#  unpaid_leave_days                    :decimal(10, 2)
#  paid_sick_leave_days                 :decimal(10, 2)
#  unpaid_marriage_leave_days           :decimal(10, 2)
#  unpaid_compassionate_leave_days      :decimal(10, 2)
#  unpaid_maternity_leave_days          :decimal(10, 2)
#  paid_maternity_leave_days            :decimal(10, 2)
#  pregnant_sick_leave_days             :decimal(10, 2)
#  occupational_injury_days             :decimal(10, 2)
#  late_0_10_min_times                  :integer
#  late_10_20_min_times                 :integer
#  late_20_30_min_times                 :integer
#  late_30_120_min_times                :integer
#  missing_punch_times                  :integer
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#
# Indexes
#
#  index_attendance_month_report_items_on_user_id     (user_id)
#  index_attendance_month_report_items_on_year_month  (year_month)
#
# Foreign Keys
#
#  fk_rails_5c56a20806  (user_id => users.id)
#

class AttendanceMonthReportItem < ApplicationRecord
  include StatementAble

  belongs_to :user

  scope :by_year_month, -> (year_month) {
    where(year_month: Time.zone.parse(year_month).month_range)
  }

  class << self

    def year_month_options
      self.all.select(:year_month).distinct.pluck(:year_month)
    end

    def generate(user, year_month_date)
      year_month = year_month_date.beginning_of_month
      calc_params = self.create_params - %w(user_id year_month)
      self.where(user: user, year_month:year_month..year_month.end_of_month)
        .first_or_create(user: user, year_month: year_month)
        .update(
          calc_params.map { |param|
            [param, AttendanceCalculationService.send(param, user, year_month)]
          }.to_h
        )
    end

    def generate_all(year_month_date)
      User.find_each do |user|
        generate(user, year_month_date)
      end
    end

  end
end
