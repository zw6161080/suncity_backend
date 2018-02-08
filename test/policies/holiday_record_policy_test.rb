require 'test_helper'
require 'test_policy_helper'
class HolidayRecordPolicyTest < ActiveSupport::TestCase

  include TestPolicyHelper
  def model
    HolidayRecord
  end

  def test_holiday_record_approval_for_employee
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_approve, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).holiday_record_approval_for_employee?
  end

  def test_holiday_record_approval_for_employee_export_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_approve, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).holiday_record_approval_for_employee_export_xlsx?
  end

  def test_holiday_record_approval_for_type
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_approve, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).holiday_record_approval_for_type?
  end

  def test_holiday_record_approval_for_type_export_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_approve, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).holiday_record_approval_for_type_export_xlsx?
  end

  def test_holiday_surplus_query
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_surplus, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).holiday_surplus_query?
  end

  def test_holiday_surplus_query_export_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_surplus, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).holiday_surplus_query_export_xlsx?
  end

  def test_index_for_report
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_report, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).index_for_report?
  end

  def test_export_xlsx_for_report
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_report, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).export_xlsx_for_report?
  end

end
