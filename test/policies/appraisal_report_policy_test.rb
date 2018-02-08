require 'test_helper'

class AppraisalReportPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :AppraisalReport, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AppraisalReportPolicy.new(user, AppraisalReport).index?
  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :AppraisalReport, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AppraisalReportPolicy.new(user, AppraisalReport).show?
  end

  def test_side_bar_options
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :AppraisalReport, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AppraisalReportPolicy.new(user, AppraisalReport).side_bar_options?
  end

  def test_export

  end

  def test_create
  end

  def test_update
  end

  def test_destroy
  end
end
