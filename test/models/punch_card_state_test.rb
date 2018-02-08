require "test_helper"

class PunchCardStateTest < ActiveSupport::TestCase
  def punch_card_state
    @punch_card_state ||= PunchCardState.new
  end

  def test_valid
    assert punch_card_state.valid?
  end
end
