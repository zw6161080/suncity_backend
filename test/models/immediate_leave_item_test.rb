# == Schema Information
#
# Table name: immediate_leave_items
#
#  id                 :integer          not null, primary key
#  immediate_leave_id :integer
#  comment            :text
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  date               :date
#  shift_info         :string
#  work_time          :string
#  come               :string
#  leave              :string
#

require 'test_helper'

class ImmediateLeaveItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
