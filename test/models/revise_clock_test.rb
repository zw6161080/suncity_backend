# == Schema Information
#
# Table name: revise_clocks
#
#  id          :integer          not null, primary key
#  date        :date
#  user_id     :integer
#  creator_id  :integer
#  status      :integer          default("approved"), not null
#  item_count  :integer
#  comment     :text
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  record_type :string           default("revise_clock"), not null
#

require 'test_helper'

class ReviseClockTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
