# == Schema Information
#
# Table name: over_times
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
#  record_type :string           default("over_time"), not null
#

require 'test_helper'

class OverTimeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
