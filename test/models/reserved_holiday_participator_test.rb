require "test_helper"

class ReservedHolidayParticipatorTest < ActiveSupport::TestCase
  def reserved_holiday_participator
    @reserved_holiday_participator ||= ReservedHolidayParticipator.new
  end

  def test_valid
    assert reserved_holiday_participator.valid?
  end
end
