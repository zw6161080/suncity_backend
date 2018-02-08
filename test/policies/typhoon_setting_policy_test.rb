require 'test_helper'

class TyphoonSettingPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :TyphoonSetting, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TyphoonSettingPolicy.new(user, TyphoonSetting).index?
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :TyphoonSetting, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TyphoonSettingPolicy.new(user, TyphoonSetting).create?
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :TyphoonSetting, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TyphoonSettingPolicy.new(user, TyphoonSetting).update?
  end

  def test_destroy
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :TyphoonSetting, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TyphoonSettingPolicy.new(user, TyphoonSetting).destroy?
  end
end
