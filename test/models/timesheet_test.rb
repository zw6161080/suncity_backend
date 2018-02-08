# == Schema Information
#
# Table name: timesheets
#
#  id            :integer          not null, primary key
#  year          :string
#  month         :string
#  department_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  roster_id     :integer
#

require 'test_helper'

class TimesheetTest < ActiveSupport::TestCase
  test '创建考勤表' do
    roster = rostered_roster
    create_timesheet_date_with_roster roster
  end
end
