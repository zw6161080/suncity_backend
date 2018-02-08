require 'test_helper'

class WrwtPolicyTest < ActiveSupport::TestCase
def test_current_wrwt_by_user?
  admin_role = create(:role)
  admin_role.add_permission_by_attribute(:information, :welfare_info, :macau)
  user= create_test_user
  user.add_role(admin_role)

  assert WrwtPolicy.new(user, Wrwt).current_wrwt_by_user?

end

  def test_scope
  end

  def test_show
  end

  def test_create
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update_information, :welfare_info, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert WrwtPolicy.new(user, Wrwt).update?
  end

  def test_destroy
  end
end
