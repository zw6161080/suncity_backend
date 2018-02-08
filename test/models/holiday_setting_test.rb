require "test_helper"

class HolidaySettingTest < ActiveSupport::TestCase
  def holiday_setting
    @holiday_setting ||= HolidaySetting.new
  end

  def test_valid
    assert holiday_setting.valid?
  end
end
