require 'test_helper'
require 'test_policy_helper'
class AdjustRosterRecordPolicyTest < ActiveSupport::TestCase

  include TestPolicyHelper
  def model
    AdjustRosterRecord
  end
  def test_scope
  end


  def test_update
  end

  def test_add_approval
  end

  def test_destroy_approval
  end

  def test_add_attach
  end

  def test_destroy_attach
  end

  def test_report
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_report, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).report?
  end

  def test_report_export_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_report, resource, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert model_policy.new(user, model).report_export_xlsx?

  end
end
