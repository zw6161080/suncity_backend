# == Schema Information
#
# Table name: absenteeism_items
#
#  id             :integer          not null, primary key
#  absenteeism_id :integer
#  comment        :text
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  date           :date
#  shift_info     :string
#  work_time      :string
#  come           :string
#  leave          :string
#

FactoryGirl.define do
  factory :absenteeism_item do
    
  end
end
