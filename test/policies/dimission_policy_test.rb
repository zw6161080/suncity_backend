require 'test_helper'

class DimissionPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :Dimission, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert DimissionPolicy.new(user, Dimission).create?

  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :Dimission, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert DimissionPolicy.new(user, Dimission).create?

  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :Dimission, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert DimissionPolicy.new(user, Dimission).create?

  end

  def test_update
  end

  def test_destroy
  end
end
