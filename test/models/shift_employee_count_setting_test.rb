# == Schema Information
#
# Table name: shift_employee_count_settings
#
#  id         :integer          not null, primary key
#  grade_tag  :integer
#  max_number :integer
#  min_number :integer
#  date       :date
#  shift_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  roster_id  :integer
#

require 'test_helper'

class ShiftEmployeeCountSettingTest < ActiveSupport::TestCase
  test "grade_tags is the same as shift_setting_grade select" do
    assert_equal ShiftEmployeeCountSetting.grade_tags.keys, Select.find('shift_setting_grade').as_json.fetch('options').map{|opt| opt['key']}
  end
end
