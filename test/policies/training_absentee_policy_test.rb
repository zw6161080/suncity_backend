require 'test_helper'

class TrainingAbsenteePolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :TrainingAbsentee, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainingAbsenteePolicy.new(user, TrainingAbsentee).index?

  end

  def test_columns
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :TrainingAbsentee, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainingAbsenteePolicy.new(user, TrainingAbsentee).columns?

  end

  def test_options
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :TrainingAbsentee, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainingAbsenteePolicy.new(user, TrainingAbsentee).options?

  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :TrainingAbsentee, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainingAbsenteePolicy.new(user, TrainingAbsentee).show?
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :TrainingAbsentee, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainingAbsenteePolicy.new(user, TrainingAbsentee).create?
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :TrainingAbsentee, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainingAbsenteePolicy.new(user, TrainingAbsentee).update?
  end

  def test_destroy
  end
end
