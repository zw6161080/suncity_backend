require 'test_helper'

class RosterModelPolicyTest < ActiveSupport::TestCase

  def test_scope

  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :RosterModel, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterModelPolicy.new(user, RosterModel).index?
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :RosterModel, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterModelPolicy.new(user, RosterModel).create?
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :RosterModel, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterModelPolicy.new(user, RosterModel).update?

  end

  def test_destroy
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :RosterModel, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterModelPolicy.new(user, RosterModel).destroy?

  end

  def test_export_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :RosterModel, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterModelPolicy.new(user, RosterModel).export_xlsx?

  end
end
