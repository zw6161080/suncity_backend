# == Schema Information
#
# Table name: attendance_item_logs
#
#  id                 :integer          not null, primary key
#  attendance_item_id :integer
#  user_id            :integer
#  log_time           :datetime
#  log_type           :string
#  log_type_id        :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

require 'test_helper'

class AttendanceItemLogTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
