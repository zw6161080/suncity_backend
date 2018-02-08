require 'test_helper'

class AttendLogPolicyTest < ActiveSupport::TestCase

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :attend, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AttendLogPolicy.new(user, AttendLog).index?
  end

  def test_index_by_department
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :attend, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AttendLogPolicy.new(user, AttendLog).index_by_department?
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
