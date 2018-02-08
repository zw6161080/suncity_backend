require 'test_helper'

class EntryListPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :train, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert EntryListPolicy.new(user, EntryList).create?
  end

  def test_batch_update_and_to_final_lists?
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :train, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert EntryListPolicy.new(user, EntryList).batch_update_and_to_final_lists?
  end

  def test_update
  end

  def test_destroy
  end
end
