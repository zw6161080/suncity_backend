require 'test_helper'

class AttendMonthApprovalPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :AttendMonthApproval, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AttendMonthApprovalPolicy.new(user, AttendMonthApproval).create?
  end

  def test_update
  end

  def test_destroy
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :AttendMonthApproval, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AttendMonthApprovalPolicy.new(user, AttendMonthApproval).index?

  end

  def test_approval
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :AttendMonthApproval, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AttendMonthApprovalPolicy.new(user, AttendMonthApproval).approval?
  end

  def test_cancel_approval
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :AttendMonthApproval, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AttendMonthApprovalPolicy.new(user, AttendMonthApproval).cancel_approval?
  end

  def  test_export_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :AttendMonthApproval, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AttendMonthApprovalPolicy.new(user, AttendMonthApproval).export_xlsx?
  end

end
