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

FactoryGirl.define do
  factory :holiday_item do
    
  end
end
