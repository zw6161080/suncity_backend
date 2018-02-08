require "test_helper"

class AppraisalEmployeeSettingTest < ActiveSupport::TestCase
  def appraisal_employee_setting
    @appraisal_employee_setting ||= AppraisalEmployeeSetting.new
  end

  def test_valid
    assert appraisal_employee_setting.valid?
  end
end
