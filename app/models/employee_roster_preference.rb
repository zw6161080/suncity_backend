# == Schema Information
#
# Table name: employee_roster_preferences
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  employee_preference_id :integer
#  date_range             :string
#  start_date             :date
#  end_date               :date
#  class_setting_group    :integer          default([]), is an Array
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_employee_roster_preferences_on_employee_preference_id  (employee_preference_id)
#

class EmployeeRosterPreference < ApplicationRecord
  belongs_to :employee_preference
end
