require 'test_helper'

class SupervisorAssessmentPolicyTest < ActiveSupport::TestCase

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :train, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert SupervisorAssessmentPolicy.new(user, SupervisorAssessment).index?
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
