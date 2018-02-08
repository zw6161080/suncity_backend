require 'test_helper'

class PunchCardStatePolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_report
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_report, :PunchCardState, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert PunchCardStatePolicy.new(user, PunchCardState).report?
  end

  def test_report_export_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_report, :PunchCardState, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert PunchCardStatePolicy.new(user, PunchCardState).report_export_xlsx?
  end

  def test_create
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update, :RosterInstruction, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert PunchCardStatePolicy.new(user, PunchCardState).update?
  end

  def test_destroy
  end
end
