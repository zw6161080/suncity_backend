# == Schema Information
#
# Table name: timesheet_items
#
#  id           :integer          not null, primary key
#  timesheet_id :integer
#  uid          :string
#  date         :date
#  clock_in     :datetime
#  clock_off    :datetime
#  init_state   :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_timesheet_items_on_timesheet_id  (timesheet_id)
#

class TimesheetItem < ApplicationRecord
end
