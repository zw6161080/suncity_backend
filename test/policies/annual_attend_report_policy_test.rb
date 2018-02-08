require 'test_helper'

class AnnualAttendReportPolicyTest < ActiveSupport::TestCase

  def test_scope
  end


  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_report, :AnnualAttendReport, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AnnualAttendReportPolicy.new(user, AnnualAttendReport).index?
  end

  def test_export_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_report, :AnnualAttendReport, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AnnualAttendReportPolicy.new(user, AnnualAttendReport).export_xlsx?
  end

  def test_show
  end

  def test_create
  end

  def test_update
  end

  def test_destroy
  end
end
