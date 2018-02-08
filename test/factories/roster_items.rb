# == Schema Information
#
# Table name: roster_items
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  shift_id    :integer
#  roster_id   :integer
#  date        :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  leave_type  :string
#  start_time  :datetime
#  end_time    :datetime
#  state       :integer          default("default")
#  is_modified :boolean
#

FactoryGirl.define do
  factory :roster_item do
    
  end
end
