require 'test_helper'

class MessageTest < ActiveSupport::TestCase
  test 'create message' do
    m = Message.new
    assert_equal Message::USER_TARGET, m.target_type
  end
end