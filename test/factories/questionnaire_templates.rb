# coding: utf-8
FactoryGirl.define do
  factory :questionnaire_template do
    id 1
    region 'macau'
    chinese_name '測試 1'
    english_name 'test 1'
    simple_chinese_name '测试 1'
    template_type 'other'
    template_introduction 'template introduction'
    creator_id 1
    comment 'comment'
  end
end
