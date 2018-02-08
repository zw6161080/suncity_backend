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

FactoryGirl.define do
  factory :shift_employee_count_setting do
    
  end
end
