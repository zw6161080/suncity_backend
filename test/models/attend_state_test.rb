require "test_helper"

class AttendStateTest < ActiveSupport::TestCase
  def attend_state
    @attend_state ||= AttendState.new
  end

  def test_valid
    assert attend_state.valid?
  end
end
