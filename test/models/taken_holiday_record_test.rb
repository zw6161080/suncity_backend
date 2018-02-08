require "test_helper"

class TakenHolidayRecordTest < ActiveSupport::TestCase
  def taken_holiday_record
    @taken_holiday_record ||= TakenHolidayRecord.new
  end

  def test_valid
    assert taken_holiday_record.valid?
  end
end
