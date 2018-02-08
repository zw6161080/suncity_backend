require "test_helper"

class AppraisalBasicSettingTest < ActiveSupport::TestCase
  def appraisal_basic_setting
    @appraisal_basic_setting ||= AppraisalBasicSetting.new
  end

  def test_valid
    assert appraisal_basic_setting.valid?
  end
end
