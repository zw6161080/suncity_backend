# == Schema Information
#
# Table name: roster_settings
#
#  id                  :integer          not null, primary key
#  roster_id           :integer
#  shift_interval_hour :jsonb
#  rest_number         :jsonb
#  rest_interval_day   :jsonb
#  shift_type_number   :jsonb
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

FactoryGirl.define do
  factory :roster_setting do
    
  end
end
