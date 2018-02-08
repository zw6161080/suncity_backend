# == Schema Information
#
# Table name: holiday_switches
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  user_b_id   :integer
#  creator_id  :integer
#  status      :integer          default("approved"), not null
#  comment     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  record_type :string           default("holiday_switch"), not null
#

FactoryGirl.define do
  factory :holiday_switch do
    
  end
end
