require 'test_helper'

class ResignationRecordPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update_history, :ResignationRecord, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert ResignationRecordPolicy.new(user, ResignationRecord).create?

  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update_history, :ResignationRecord, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert ResignationRecordPolicy.new(user, ResignationRecord).update?

  end

  def test_destroy
  end
end
