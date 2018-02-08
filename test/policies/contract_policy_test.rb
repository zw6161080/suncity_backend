require 'test_helper'

class ContractPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Contract, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ContractPolicy.new(user, Contract).create?
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update, :Contract, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ContractPolicy.new(user, Contract).update?
  end

  def test_cancel
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:cancel, :Contract, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ContractPolicy.new(user, Contract).cancel?
  end

  def test_destroy
  end
end
