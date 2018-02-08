require 'test_helper'

class WelfareRecordPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update_history, :WelfareRecord, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert WelfareRecordPolicy.new(user, WelfareRecord).create?
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update_history, :WelfareRecord, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert WelfareRecordPolicy.new(user, WelfareRecord).update?

  end

  def test_destroy
  end

  def test_current_welfare_record_by_user
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:information, :welfare_info, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert WelfareRecordPolicy.new(user, WelfareRecord).current_welfare_record_by_user?
  end
end
