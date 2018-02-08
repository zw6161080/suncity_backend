require "test_helper"

class ReservedHolidaySettingTest < ActiveSupport::TestCase
  def reserved_holiday_setting
    @reserved_holiday_setting ||= ReservedHolidaySetting.new
  end

  def test_valid
    assert reserved_holiday_setting.valid?
  end
end
