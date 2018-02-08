# == Schema Information
#
# Table name: message_infos
#
#  id          :integer          not null, primary key
#  content     :string
#  target_type :string
#  namespace   :string
#  targets     :integer          is an Array
#  sender_id   :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'test_helper'

class MessageInfoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
