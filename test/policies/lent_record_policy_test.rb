require 'test_helper'

class LentRecordPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update_history, :LentRecord, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert LentRecordPolicy.new(user, LentRecord).create?

  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update_history, :LentRecord, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert LentRecordPolicy.new(user, LentRecord).update?

  end

  def test_destroy
  end
end
