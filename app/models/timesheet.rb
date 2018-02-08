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
# Indexes
#
#  index_timesheets_on_department_id  (department_id)
#  index_timesheets_on_roster_id      (roster_id)
#

class Timesheet < ApplicationRecord
  belongs_to :roster
end
