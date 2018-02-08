# == Schema Information
#
# Table name: immediate_leave_items
#
#  id                 :integer          not null, primary key
#  immediate_leave_id :integer
#  comment            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  date               :date
#  shift_info         :string
#  work_time          :string
#  come               :string
#  leave              :string
#

FactoryGirl.define do
  factory :immediate_leave_item do
    
  end
end
