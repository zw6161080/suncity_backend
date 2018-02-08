require "test_helper"

class AppraisalParticipateDepartmentTest < ActiveSupport::TestCase
  def appraisal_participate_department
    @appraisal_participate_department ||= AppraisalParticipateDepartment.new
  end

  def test_valid
    assert appraisal_participate_department.valid?
  end
end
