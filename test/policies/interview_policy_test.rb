require 'test_helper'

class InterviewPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_completed
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:complete, :Interview, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert InterviewPolicy.new(user, Interview).completed?
  end

  def test_cancelled
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:cancel, :Interview, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert InterviewPolicy.new(user, Interview).cancelled?
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Interview, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert InterviewPolicy.new(user, Interview).create?
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update, :Interview, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert InterviewPolicy.new(user, Interview).update?
  end

  def test_destroy
  end
end
