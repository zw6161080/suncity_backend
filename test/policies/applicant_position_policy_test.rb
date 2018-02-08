require 'test_helper'

class ApplicantPositionPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:show, :ApplicantPosition, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ApplicantPositionPolicy.new(user, ApplicantPosition).show?
  end

  def test_update_status
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update_status, :ApplicantPosition, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ApplicantPositionPolicy.new(user, ApplicantPosition).update_status?
  end

  def test_create
  end

  def test_update
  end

  def test_destroy
  end
end
