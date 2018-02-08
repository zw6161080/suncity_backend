require "test_helper"

class AppraisalForDepartmentTest < ActiveSupport::TestCase
  def appraisal_for_department
    @appraisal_for_department ||= AppraisalForDepartment.new
  end

  def test_valid
    assert appraisal_for_department.valid?
  end
end
