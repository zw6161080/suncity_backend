# == Schema Information
#
# Table name: shifts
#
#  id                       :integer          not null, primary key
#  chinese_name             :string
#  start_time               :string
#  end_time                 :string
#  time_length              :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  roster_id                :integer
#  english_name             :string
#  allow_be_late_minute     :integer
#  allow_leave_early_minute :integer
#  is_next                  :boolean
#

require 'test_helper'

class ShiftTest < ActiveSupport::TestCase
  test '创建排班表 无效的时间' do
    roster = create(:roster)
    department = roster.department
    shift = build(:shift,
              start_time: '18:223',
              end_time: '28:242',
              roster_id: roster.id
            )
    assert_not shift.valid?
  end

  test '创建排更表' do
    roster = create(:roster)
    department = roster.department
    shift = create(:shift,
              start_time: '18:23',
              end_time: '28:24',
              roster_id: roster.id
            )
    assert_equal 18, shift.start_hour
    assert_equal 23, shift.start_minute
    assert_equal 28, shift.end_hour
    assert_equal 24, shift.end_minute
    assert_equal 601, shift.time_length
  end
end
