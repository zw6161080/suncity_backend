require 'test_helper'

class SignCardReasonPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :sign_card, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert SignCardReasonPolicy.new(user, SignCardReason).create?
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :sign_card, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert SignCardReasonPolicy.new(user, SignCardReason).update?
  end

  def test_destroy
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :sign_card, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert SignCardReasonPolicy.new(user, SignCardReason).destroy?
  end
end
