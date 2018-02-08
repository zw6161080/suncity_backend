require 'test_helper'

class ShiftStatusPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_create
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update, :RosterInstruction, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ShiftStatusPolicy.new(user, ShiftStatus).update?
  end

  def test_destroy
  end
end
