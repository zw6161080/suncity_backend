# == Schema Information
#
# Table name: departments
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  comment             :text
#  region_key          :string
#  parent_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  status              :integer          default("enabled")
#  head_id             :integer
#  simple_chinese_name :string
#

require 'test_helper'

class DepartmentTest < ActiveSupport::TestCase
  test "create department test" do
    location = create(:location)
    department = Department.new
    department.chinese_name = '中央信贷部'
    department.english_name = 'i dont know how to say in english'
    department.location_ids = [location.id]
    department.comment = 'some comment'
    assert department.save
  end
end
