# == Schema Information
#
# Table name: timesheets
#
#  id            :integer          not null, primary key
#  year          :string
#  month         :string
#  department_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  roster_id     :integer
#

FactoryGirl.define do
  factory :timesheet do
    
  end
end
