require "test_helper"

class ForceHolidayWorkingRecordTest < ActiveSupport::TestCase
  def force_holiday_working_record
    @force_holiday_working_record ||= ForceHolidayWorkingRecord.new
  end

  def test_valid
    assert force_holiday_working_record.valid?
  end
end
