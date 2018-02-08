# == Schema Information
#
# Table name: paid_sick_leave_report_items
#
#  id                        :integer          not null, primary key
#  paid_sick_leave_report_id :integer
#  year                      :integer
#  department_id             :integer
#  user_id                   :integer
#  entry_date                :date
#  on_duty_days              :integer
#  paid_sick_leave_counts    :integer
#  obtain_counts             :integer
#  is_release                :boolean
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  valid_period              :date
#
# Indexes
#
#  index_paid_sick_leave_report_items_on_paid_sick_leave_report_id  (paid_sick_leave_report_id)
#  index_paid_sick_leave_report_items_on_user_id                    (user_id)
#

class PaidSickLeaveReportItem < ApplicationRecord
  belongs_to :user
  belongs_to :paid_sick_leave_report

  scope :by_year, lambda { |year|
    where(year: year) if year
  }

  scope :by_department_ids, lambda { |department_ids|
    if department_ids
      joins(:user).where(users: { department_id: department_ids })
    end
  }

  scope :by_users, lambda { |user_ids|
    where(user_id: user_ids) if user_ids
  }

  def refresh_data
    year = self.year.to_i

    start_date = Time.zone.local(year, 1, 1).to_date.beginning_of_year
    end_date = Time.zone.local(year, 1, 1).to_date.end_of_year
    records = HolidayRecord.where(user_id: self.user_id,
                                  source_id: nil,
                                  start_date: start_date..end_date,
                                  holiday_type: 'paid_sick_leave',
                                  is_deleted: [false, nil])

    counts = records.inject(0) do |sum, r|
      sum += r.days_count.to_i
    end

    user = self.user
    entry_date_str = user.profile.data['position_information']['field_values']['date_of_employment']

    on_duty_days = 0
    if entry_date_str
      entry_date = entry_date_str.in_time_zone.to_date
      time_now = Time.zone.now.to_date
      # time_now = self.created_at.to_date
      s_date = entry_date.year == year ? entry_date : start_date
      if year == time_now.year
        on_duty_days = (time_now - s_date).to_i + 1
      # elsif year < time_now.year
      #   on_duty_days = (end_date - s_date).to_i + 1
      else
        # on_duty_days = 0
        on_duty_days = (end_date - s_date).to_i + 1
      end
      # on_duty_days = time_now.year == year ? (time_now - s_date).to_i + 1 : (end_date - entry_date).to_i + 1
    end

    o_counts = HolidayRecord.calc_paid_bonus_leave_count(user, year)

    self.paid_sick_leave_counts = counts > 0 ? counts : 0
    self.on_duty_days = on_duty_days > 0 ? on_duty_days : 0
    self.obtain_counts = o_counts > 0 ? o_counts : 0

    self.save!
  end
end
