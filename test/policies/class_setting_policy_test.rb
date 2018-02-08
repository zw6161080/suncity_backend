require 'test_helper'

class ClassSettingPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :ClassSetting, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ClassSettingPolicy.new(user, ClassSetting).index?
  end

  def test_show
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :ClassSetting, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ClassSettingPolicy.new(user, ClassSetting).create?
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :ClassSetting, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ClassSettingPolicy.new(user, ClassSetting).update?
  end

  def test_destroy
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :ClassSetting, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ClassSettingPolicy.new(user, ClassSetting).destroy?
  end
end
