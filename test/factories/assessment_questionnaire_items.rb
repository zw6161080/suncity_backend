# == Schema Information
#
# Table name: assessment_questionnaire_items
#
#  id                          :integer          not null, primary key
#  region                      :string
#  assessment_questionnaire_id :integer
#  chinese_name                :string
#  english_name                :string
#  simple_chinese_name         :string
#  group_chinese_name          :string
#  group_english_name          :string
#  group_simple_chinese_name   :string
#  order_no                    :integer
#  score                       :integer
#  explain                     :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

FactoryGirl.define do
  factory :assessment_questionnaire_item do
    
  end
end
