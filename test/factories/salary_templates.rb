# coding: utf-8
# == Schema Information
#
# Table name: salary_templates
#
#  id                           :integer          not null, primary key
#  template_chinese_name        :string
#  template_english_name        :string
#  template_simple_chinese_name :string
#  salary_unit                  :string
#  basic_salary                 :integer
#  bonus                        :integer
#  attendance_award             :integer
#  house_bonus                  :integer
#  tea_bonus                    :integer
#  kill_bonus                   :integer
#  performance_bonus            :integer
#  charge_bonus                 :integer
#  commission_bonus             :integer
#  receive_bonus                :integer
#  exchange_rate_bonus          :integer
#  guest_card_bonus             :integer
#  respect_bonus                :integer
#  belongs_to                   :jsonb
#  comment                      :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

FactoryGirl.define do
  factory :salary_template do
    template_chinese_name '薪酬模板 1'
    template_english_name 'salary template 1'
    basic_salary 999999
    bonus 999666
    attendance_award 66666
    house_bonus 100000
    tea_bonus 123456
    kill_bonus 111111
    performance_bonus 222222
    charge_bonus 333333
    commission_bonus 123321
    receive_bonus 321123
    exchange_rate_bonus 112233
    guest_card_bonus 666999
    respect_bonus 654321
    service_award 0
    internship_bonus 0
    performance_award 0
    special_tie_bonus 0
  end
end
