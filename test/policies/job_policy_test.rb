require 'test_helper'

class JobPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:index, :Job, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert JobPolicy.new(user, Job).index?
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update, :Job, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert JobPolicy.new(user, Job).create?
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update, :Job, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert JobPolicy.new(user, Job).update?
  end

  def test_destroy
  end
end
