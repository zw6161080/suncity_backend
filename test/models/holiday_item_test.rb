# == Schema Information
#
# Table name: holiday_items
#
#  id           :integer          not null, primary key
#  holiday_id   :integer
#  creator_id   :integer
#  status       :integer
#  holiday_type :integer
#  start_time   :date
#  end_time     :date
#  duration     :integer
#  comment      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

require 'test_helper'

class HolidayItemTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
