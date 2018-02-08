require 'test_helper'

class LoveFundPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:information, :welfare_info, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert LoveFundPolicy.new(user, LoveFund).show?
  end

  def test_create
  end

  def test_update
  end

  def test_update_from_profile
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update_information, :welfare_info, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert LoveFundPolicy.new(user, LoveFund).update_from_profile?

  end

  def test_destroy
  end
end
