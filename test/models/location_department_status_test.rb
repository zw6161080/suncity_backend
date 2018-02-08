require "test_helper"

class LocationDepartmentStatusTest < ActiveSupport::TestCase
  def location_department_status
    @location_department_status ||= LocationDepartmentStatus.new
  end

  def test_valid
    assert location_department_status.valid?
  end
end
