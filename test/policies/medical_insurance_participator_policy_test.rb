require 'test_helper'

class MedicalInsuranceParticipatorPolicyTest < ActiveSupport::TestCase

  def test_update_from_profile
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update_information_from_profile, :MedicalInsuranceParticipator, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert MedicalInsuranceParticipatorPolicy.new(user, MedicalInsuranceParticipator).update_from_profile?
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
