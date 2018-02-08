require "test_helper"

class SignCardSettingTest < ActiveSupport::TestCase
  def sign_card_setting
    @sign_card_setting ||= SignCardSetting.new
  end

  def test_valid
    assert sign_card_setting.valid?
  end
end
