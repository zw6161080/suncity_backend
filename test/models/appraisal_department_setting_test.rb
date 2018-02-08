require "test_helper"

class AppraisalDepartmentSettingTest < ActiveSupport::TestCase
  def appraisal_department_setting
    @appraisal_department_setting ||= AppraisalDepartmentSetting.new
  end

  def test_valid
    assert appraisal_department_setting.valid?
  end
end
