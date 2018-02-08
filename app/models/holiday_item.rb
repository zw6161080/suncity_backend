# == Schema Information
#
# Table name: holiday_items
#
#  id           :integer          not null, primary key
#  holiday_id   :integer
#  creator_id   :integer
#  status       :integer
#  holiday_type :integer
#  start_time   :date
#  end_time     :date
#  duration     :integer
#  comment      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_holiday_items_on_holiday_id  (holiday_id)
#
# Foreign Keys
#
#  fk_rails_0544f91cb1  (holiday_id => holidays.id)
#

class HolidayItem < ApplicationRecord
  belongs_to :holiday
  before_save :set_duration
  enum status: {approved: 1}

  enum holiday_type: {
      annual_holiday: 0,
      birthday_holiday: 1,
      bonus_holiday: 2,
      supplement_holiday: 3,
      paid_illness_leave: 4,
      none_paid_leave: 5,
      paid_marriage_holiday: 6,
      nonepaid_marriage_holiday: 7,
      paid_grace_leave: 8,
      nonepaid_grace_leave: 9,
      awaiting_delivery_leave: 10,
      paid_maternity_leave: 11,
      nonepaid_maternity_leave: 12,
      work_injury_leave: 13,
      without_pay_stay_leave: 14,
      pregnancy_leave: 15,
      best_employee_holiday: 16,
      other_leave: 17
  }

  def set_duration
    self.duration = (self.end_time - self.start_time + 1).to_i unless self.start_time.nil? || self.end_time.nil?
  end

  def calc_count_inside_range(start_d, end_d)
    if self.start_time && self.end_time
      if start_d <= self.start_time && end_d >= self.end_time
        self.duration
      elsif start_d > self.start_time && end_d < self.end_time
        (end_d - start_d + 1).to_i
      elsif start_d < self.start_time && (end_d >= self.start_time && end_d < self.end_time)
        (end_d - self.start_time + 1).to_i
      elsif end_d > self.end_time && (start_d > self.start_time && start_d <= self.end_time)
        (self.end_time - start_d + 1).to_i
      else
        0
      end
    else
      0
    end
  end
end
