# == Schema Information
#
# Table name: annual_work_awards
#
#  id                 :integer          not null, primary key
#  award_chinese_name :string           not null
#  award_english_name :string           not null
#  begin_date         :string           not null
#  end_date           :string           not null
#  num_of_award       :integer          not null
#  has_paid           :integer          default("false"), not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

FactoryGirl.define do
  factory :annual_work_award do
    
  end
end
