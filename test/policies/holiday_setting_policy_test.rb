require 'test_helper'

class HolidaySettingPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :HolidaySetting, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert HolidaySettingPolicy.new(user, HolidaySetting).index?
  end

  def test_show
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :HolidaySetting, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert HolidaySettingPolicy.new(user, HolidaySetting).create?
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :HolidaySetting, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert HolidaySettingPolicy.new(user, HolidaySetting).update?
  end

  def test_destroy
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :HolidaySetting, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert HolidaySettingPolicy.new(user, HolidaySetting).destroy?
  end

  def test_batch_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :HolidaySetting, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert HolidaySettingPolicy.new(user, HolidaySetting).batch_create?

  end
end
