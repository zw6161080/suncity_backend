# == Schema Information
#
# Table name: revise_clock_items
#
#  id                   :integer          not null, primary key
#  revise_clock_id      :integer
#  clock_date           :date
#  clock_in_time        :datetime
#  clock_out_time       :datetime
#  attendance_state     :jsonb
#  new_clock_in_time    :datetime
#  new_clock_out_time   :datetime
#  new_attendance_state :jsonb
#  comment              :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :integer
#

FactoryGirl.define do
  factory :revise_clock_item do
    
  end
end
