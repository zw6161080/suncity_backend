# == Schema Information
#
# Table name: public_holidays
#
#  id           :integer          not null, primary key
#  chinese_name :string
#  english_name :string
#  category     :integer
#  start_date   :date
#  end_date     :date
#  comment      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

FactoryGirl.define do
  factory :public_holiday do
    
  end
end
