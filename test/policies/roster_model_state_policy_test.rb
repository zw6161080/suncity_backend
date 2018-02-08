require 'test_helper'

class RosterModelStatePolicyTest < ActiveSupport::TestCase

  def test_scope
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update, :RosterInstruction, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert RosterModelStatePolicy.new(user, RosterModelState).update?
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
