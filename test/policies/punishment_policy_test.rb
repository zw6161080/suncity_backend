require 'test_helper'

class PunishmentPolicyTest < ActiveSupport::TestCase

  def test_scope

  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Punishment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert PunishmentPolicy.new(user, Punishment).destroy?

  end

  def test_export
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Punishment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert PunishmentPolicy.new(user, Punishment).destroy?

  end

  def  test_show_profile
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Punishment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert PunishmentPolicy.new(user, Punishment).destroy?

  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Punishment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert PunishmentPolicy.new(user, Punishment).destroy?

  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Punishment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert PunishmentPolicy.new(user, Punishment).destroy?

  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Punishment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert PunishmentPolicy.new(user, Punishment).destroy?

  end

  def test_destroy
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Punishment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert PunishmentPolicy.new(user, Punishment).destroy?

  end
end
