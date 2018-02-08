# == Schema Information
#
# Table name: employee_general_holiday_preferences
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  employee_preference_id :integer
#  date_range             :string
#  start_date             :date
#  end_date               :date
#  day_group              :integer          default([]), is an Array
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  general_holiday_employee_preference_index  (employee_preference_id)
#

class EmployeeGeneralHolidayPreference < ApplicationRecord
  belongs_to :employee_preference
end
