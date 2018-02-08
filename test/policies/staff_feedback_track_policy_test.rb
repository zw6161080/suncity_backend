require 'test_helper'

class StaffFeedbackTrackPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end


  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :staff_feedback, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert StaffFeedbackTrackPolicy.new(user, StaffFeedbackTrack).index?

  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :staff_feedback, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert StaffFeedbackTrackPolicy.new(user, StaffFeedbackTrack).create?

  end

  def test_update
  end

  def test_destroy
  end
end
