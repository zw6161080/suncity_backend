require "test_helper"

class SpecialScheduleRemarkTest < ActiveSupport::TestCase
  def special_schedule_remark
    @special_schedule_remark ||= SpecialScheduleRemark.new
  end

  def test_valid
    assert special_schedule_remark.valid?
  end
end
