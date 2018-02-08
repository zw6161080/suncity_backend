require "test_helper"

class ClassSettingTest < ActiveSupport::TestCase
  def class_setting
    @class_setting ||= ClassSetting.new
  end

  def test_valid
    assert class_setting.valid?
  end
end
