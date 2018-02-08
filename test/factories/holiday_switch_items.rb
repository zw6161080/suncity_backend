# == Schema Information
#
# Table name: holiday_switch_items
#
#  id                :integer          not null, primary key
#  holiday_switch_id :integer
#  type              :integer
#  user_id           :integer
#  user_b_id         :integer
#  a_date            :date
#  b_date            :date
#  a_start           :string
#  a_end             :string
#  b_start           :string
#  b_end             :string
#  status            :integer          default("approved"), not null
#  comment           :text
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  a_type            :string
#  b_type            :string
#

FactoryGirl.define do
  factory :holiday_switch_item do
    
  end
end
