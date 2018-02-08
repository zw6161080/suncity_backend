# == Schema Information
#
# Table name: roster_items
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  shift_id    :integer
#  roster_id   :integer
#  date        :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  leave_type  :string
#  start_time  :datetime
#  end_time    :datetime
#  state       :integer          default("default")
#  is_modified :boolean
#

require 'test_helper'

class RosterItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
