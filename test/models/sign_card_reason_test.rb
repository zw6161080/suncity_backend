require "test_helper"

class SignCardReasonTest < ActiveSupport::TestCase
  def sign_card_reason
    @sign_card_reason ||= SignCardReason.new
  end

  def test_valid
    assert sign_card_reason.valid?
  end
end
