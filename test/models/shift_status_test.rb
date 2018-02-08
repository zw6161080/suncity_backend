require "test_helper"

class ShiftStatusTest < ActiveSupport::TestCase
  def shift_status
    @shift_status ||= ShiftStatus.new
  end

  def test_valid
    assert shift_status.valid?
  end
end
