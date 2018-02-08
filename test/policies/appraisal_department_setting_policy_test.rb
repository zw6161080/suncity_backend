require 'test_helper'

class AppraisalDepartmentSettingPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:appraisal_setting, :appraisal, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AppraisalDepartmentSettingPolicy.new(user, AppraisalDepartmentSetting).index?

  end

  def test_batch_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:appraisal_setting, :appraisal, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AppraisalDepartmentSettingPolicy.new(user, AppraisalDepartmentSetting).batch_update?

  end

  def test_create
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:appraisal_setting, :appraisal, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AppraisalDepartmentSettingPolicy.new(user, AppraisalDepartmentSetting).update?
  end

  def test_destroy
  end
end
