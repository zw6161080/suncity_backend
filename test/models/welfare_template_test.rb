# == Schema Information
#
# Table name: welfare_templates
#
#  id                           :integer          not null, primary key
#  template_chinese_name        :string           not null
#  template_english_name        :string           not null
#  annual_leave                 :integer          not null
#  sick_leave                   :integer          not null
#  office_holiday               :float            not null
#  holiday_type                 :integer          not null
#  probation                    :integer          not null
#  notice_period                :integer          not null
#  double_pay                   :boolean          not null
#  reduce_salary_for_sick       :boolean          not null
#  provide_airfare              :boolean          not null
#  provide_accommodation        :boolean          not null
#  provide_uniform              :boolean          not null
#  salary_composition           :boolean          not null
#  over_time_salary             :integer          not null
#  comment                      :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  belongs_to                   :jsonb
#  template_simple_chinese_name :string
#

require 'test_helper'

class WelfareTemplateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
