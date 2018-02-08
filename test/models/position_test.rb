# == Schema Information
#
# Table name: positions
#
#  id                  :integer          not null, primary key
#  chinese_name        :string
#  english_name        :string
#  number              :string
#  grade               :string
#  comment             :text
#  region_key          :string
#  parent_id           :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  status              :integer          default("enabled")
#  simple_chinese_name :string
#

require 'test_helper'

class PositionTest < ActiveSupport::TestCase
  test "create position" do
    department = create(:department)
    location = create(:location)

    position = Position.new
    position.chinese_name = '太阳城集团行政总裁兼董事'
    position.english_name = 'CEO and Director of Suncity Group'

    position.location_ids = [location.id]
    position.department_ids = [department.id]
    position.comment = 'some comment'
    position.grade = '3'
    assert position.save
  end
end
