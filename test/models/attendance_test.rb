# coding: utf-8
# == Schema Information
#
# Table name: attendances
#
#  id                       :integer          not null, primary key
#  department_id            :integer
#  location_id              :integer
#  year                     :string
#  month                    :string
#  region                   :string
#  snapshot_employees_count :integer
#  rosters                  :integer
#  public_holidays          :integer
#  attendance_record        :integer
#  unusual_attendances      :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  roster_id                :integer
#

require 'test_helper'

class AttendanceTest < ActiveSupport::TestCase
  test "自動生成考勤列表" do

    10.times do
      create(:location)
      create(:department_with_locations)
    end

    assert_equal Attendance.where(year: '2017').where(month: '4').count, 0

    Attendance.generate_attendance_list(2017, 4)

    assert Attendance.where(year: '2017').where(month: '4').count > 0
  end
end
