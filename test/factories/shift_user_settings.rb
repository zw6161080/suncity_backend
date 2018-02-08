# == Schema Information
#
# Table name: shift_user_settings
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  roster_id      :integer
#  shift_interval :jsonb
#  shift_special  :jsonb
#  rest_interval  :jsonb
#  rest_special   :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

FactoryGirl.define do
  factory :shift_user_setting do

  end
end
