# == Schema Information
#
# Table name: shift_employee_count_settings
#
#  id         :integer          not null, primary key
#  grade_tag  :integer
#  max_number :integer
#  min_number :integer
#  date       :date
#  shift_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  roster_id  :integer
#
# Indexes
#
#  index_shift_employee_count_settings_on_roster_id  (roster_id)
#  index_shift_employee_count_settings_on_shift_id   (shift_id)
#

class ShiftEmployeeCountSetting < ApplicationRecord
  belongs_to :roster
  belongs_to :shift

  enum grade_tag: { total: 0, 3 => 3, 4 => 4 }
  before_save :validate_max_min_number

  def validate_max_min_number
    raise 'Wrong max/min number' unless self.max_number.to_i >= self.min_number.to_i
  end

end
