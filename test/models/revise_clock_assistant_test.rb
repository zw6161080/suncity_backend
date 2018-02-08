# == Schema Information
#
# Table name: revise_clock_assistants
#
#  id                   :integer          not null, primary key
#  revise_clock_item_id :integer
#  sign_time            :string
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#

require 'test_helper'

class ReviseClockAssistantTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
