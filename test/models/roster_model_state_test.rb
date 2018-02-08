require "test_helper"

class RosterModelStateTest < ActiveSupport::TestCase
  def roster_model_state
    @roster_model_state ||= RosterModelState.new
  end

  def test_valid
    assert roster_model_state.valid?
  end
end
