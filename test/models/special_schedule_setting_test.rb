require "test_helper"

class SpecialScheduleSettingTest < ActiveSupport::TestCase
  def special_schedule_setting
    @special_schedule_setting ||= SpecialScheduleSetting.new
  end

  def test_valid
    assert special_schedule_setting.valid?
  end
end
