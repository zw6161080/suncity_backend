require 'test_helper'

class RosterListPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :shift, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterListPolicy.new(user, RosterList).index?
  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :shift, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterListPolicy.new(user, RosterList).show?

  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :shift, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterListPolicy.new(user, RosterList).create?
  end

  def test_destroy
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :shift, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterListPolicy.new(user, RosterList).destroy?
  end

  def test_import_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :shift, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterListPolicy.new(user, RosterList).import_xlsx?
  end

  def test_roster_objects_export_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :shift, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterListPolicy.new(user, RosterList).roster_objects_export_xlsx?
  end

  def test_objects_batch_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :shift, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterListPolicy.new(user, RosterList).object_batch_update?
  end

  def test_to_draft
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :shift, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterListPolicy.new(user, RosterList).to_draft?
  end

  def test_to_sealed
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :shift, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterListPolicy.new(user, RosterList).to_sealed?
  end

  def test_to_public
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :shift, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterListPolicy.new(user, RosterList).to_public?
  end

  def test_query_roster_objects?
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_search, :RosterList, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterListPolicy.new(user, RosterList).query_roster_objects?
  end

  def test_query_roster_objects_export_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_for_search, :RosterList, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterListPolicy.new(user, RosterList).query_roster_objects_export_xlsx?
  end

  def test_department_roster_objects
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :RosterList, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterListPolicy.new(user, RosterList).department_roster_objects?
  end


end
