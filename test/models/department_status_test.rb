require "test_helper"

class DepartmentStatusTest < ActiveSupport::TestCase
  def department_status
    @department_status ||= DepartmentStatus.new
  end

  def test_valid
    assert department_status.valid?
  end
end
