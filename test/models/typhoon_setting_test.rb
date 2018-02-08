require "test_helper"

class TyphoonSettingTest < ActiveSupport::TestCase
  def typhoon_setting
    @typhoon_setting ||= TyphoonSetting.new
  end

  def test_valid
    assert typhoon_setting.valid?
  end
end
