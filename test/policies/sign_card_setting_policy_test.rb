require 'test_helper'

class SignCardSettingPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :sign_card, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert SignCardSettingPolicy.new(user, SignCardSetting).index?
  end

  def test_show
  end

  def test_create
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :sign_card, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert SignCardSettingPolicy.new(user, SignCardSetting).update?
  end

  def test_destroy
  end
end
