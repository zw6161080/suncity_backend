require 'test_helper'

class ApplicantProfilePolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:index, :ApplicantProfile, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ApplicantProfilePolicy.new(user, ApplicantProfile).index?
  end


  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:index, :ApplicantProfile, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ApplicantProfilePolicy.new(user, ApplicantProfile).show?

  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update, :ApplicantProfile, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ApplicantProfilePolicy.new(user, ApplicantProfile).create?
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update, :ApplicantProfile, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ApplicantProfilePolicy.new(user, ApplicantProfile).update?

  end

  def test_destroy
  end
end
