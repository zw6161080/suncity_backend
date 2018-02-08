# == Schema Information
#
# Table name: attendance_items
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  position_id         :integer
#  department_id       :integer
#  attendance_id       :integer
#  shift_id            :integer
#  attendance_date     :datetime
#  start_working_time  :datetime
#  end_working_time    :datetime
#  comment             :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  states              :string           default("")
#  region              :string
#  location_id         :integer
#  updated_states_from :string
#  roster_item_id      :integer
#  plan_start_time     :datetime
#  plan_end_time       :datetime
#  is_modified         :boolean
#  overtime_count      :integer
#  leave_type          :string
#

FactoryGirl.define do
  factory :attendance_item do
    
  end
end
