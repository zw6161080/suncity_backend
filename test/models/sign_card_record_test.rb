require "test_helper"

class SignCardRecordTest < ActiveSupport::TestCase
  def sign_card_record
    @sign_card_record ||= SignCardRecord.new
  end

  def test_valid
    assert sign_card_record.valid?
  end
end
