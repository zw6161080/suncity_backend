require 'test_helper'

class ProfilePolicyTest < ActiveSupport::TestCase

  def test_export_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:export, :Profile, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert ProfilePolicy.new(user, Profile).export_xlsx?
  end

  def test_manage
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Profile, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert user.can? :manage, :Profile
  end

  def test_scope
  end

  def test_template
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Profile, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert ProfilePolicy.new(user, Profile).template?
  end

  def test_show
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:create, :Profile, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert ProfilePolicy.new(user, Profile).create?
  end

  def test_update_personal_information
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update_personal_information, :Profile, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert user.can?(:update_personal_information, :Profile)
  end

  def test_roster_instruction
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:roster_instruction, :Profile, :macau)
    user= create_test_user
    user.add_role(admin_role)

    assert user.can?(:roster_instruction, :Profile)
  end


  def test_index_by_department
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :department_profile, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ProfilePolicy.new(user, Profile).index_by_department?
  end

  def test_attachment_missing
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage_missing, :Profile, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ProfilePolicy.new(user, Profile).attachment_missing?
  end

  def test_update

  end

  def test_destroy
  end
end
