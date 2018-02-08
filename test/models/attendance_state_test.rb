# == Schema Information
#
# Table name: attendance_states
#
#  id           :integer          not null, primary key
#  code         :string
#  chinese_name :string
#  english_name :string
#  comment      :text
#  parent_id    :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class AttendanceStateTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
