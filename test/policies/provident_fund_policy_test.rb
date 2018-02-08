require 'test_helper'

class ProvidentFundPolicyTest < ActiveSupport::TestCase
def test_update_from_profile
  admin_role = create(:role)
  admin_role.add_permission_by_attribute(:update_information_from_profile, :ProvidentFund, :macau)
  user= create_test_user
  user.add_role(admin_role)

  assert ProvidentFundPolicy.new(user, ProvidentFund).update_from_profile?
end

  def test_scope
  end

  def test_show
  end

  def test_create
  end

  def test_update
  end

  def test_destroy
  end
end
