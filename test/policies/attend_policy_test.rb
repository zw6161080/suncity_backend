require 'test_helper'

class AttendPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :attend, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AttendPolicy.new(user, Attend).index?
  end

  def test_import
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :attend, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AttendPolicy.new(user, Attend).import?
  end

  def test_export_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :attend, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AttendPolicy.new(user, Attend).export_xlsx?
  end


  def test_index_by_department?
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :attend, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AttendPolicy.new(user, Attend).index_by_department?
  end

  def test_update
  end

  def test_destroy
  end
end
