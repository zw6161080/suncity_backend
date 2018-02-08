# coding: utf-8
# == Schema Information
#
# Table name: attendance_items
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  position_id         :integer
#  department_id       :integer
#  attendance_id       :integer
#  shift_id            :integer
#  attendance_date     :datetime
#  start_working_time  :datetime
#  end_working_time    :datetime
#  comment             :text
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  states              :string           default("")
#  region              :string
#  location_id         :integer
#  updated_states_from :string
#  roster_item_id      :integer
#  plan_start_time     :datetime
#  plan_end_time       :datetime
#  is_modified         :boolean
#  overtime_count      :integer
#  leave_type          :string
#

require 'test_helper'

class AttendanceItemTest < ActiveSupport::TestCase
  test "update_working_time" do
    roster = create(:roster, from: '2017-03-06', to: '2017-03-12')
    department = roster.department
    position = create(:position)
    department.positions << position

    create(:shift, roster_id: roster.id, chinese_name: '早班', english_name: 'am', start_time: '06:00', end_time: '12:00', allow_be_late_minute: 15, allow_leave_early_minute: 15)
    create(:shift, roster_id: roster.id, chinese_name: '中班', english_name: 'pm', start_time: '12:00', end_time: '18:00', allow_be_late_minute: 15, allow_leave_early_minute: 15)
    create(:shift, roster_id: roster.id, chinese_name: '晚班', english_name: 'night', start_time: '18:00', end_time: '24:00', allow_be_late_minute: 15, allow_leave_early_minute: 15)

    a_date =  "2017-03-10 23:00:00".in_time_zone
    empoids = RosterEventLog.of_ymd(a_date.year, a_date.month, a_date.day).pluck(:nUserID).uniq

    10.times do
      user = create(:user, position_id: position.id, empoid: empoids.pop)
      department.employees << user
    end

    roster.reload
    roster.start_roster!

    AttendanceItem.update_working_time(a_date)
  end
end
