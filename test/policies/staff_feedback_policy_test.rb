require 'test_helper'

class StaffFeedbackPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :staff_feedback, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert StaffFeedbackPolicy.new(user, StaffFeedback).index?

  end

  def test_my_feedbacks
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :staff_feedback, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert StaffFeedbackPolicy.new(user, StaffFeedback).index?

  end

  def test_export_all_feedbacks
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :staff_feedback, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert StaffFeedbackPolicy.new(user, StaffFeedback).index?

  end

  def test_show
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :staff_feedback, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert StaffFeedbackPolicy.new(user, StaffFeedback).index?

  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :staff_feedback, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert StaffFeedbackPolicy.new(user, StaffFeedback).index?

  end

  def test_destroy
  end
end
