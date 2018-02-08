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

require 'test_helper'

class SalaryTemplateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
