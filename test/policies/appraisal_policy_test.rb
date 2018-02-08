require 'test_helper'

class AppraisalPolicyTest < ActiveSupport::TestCase

  def test_scope
  end


  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :appraisal, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AppraisalPolicy.new(user, Appraisal).index?
  end

  def test_view_from_department
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :appraisal, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AppraisalPolicy.new(user, Appraisal).show?
    assert AppraisalPolicy.new(user, Appraisal).update?
    assert AppraisalPolicy.new(user, Appraisal).destroy?
    assert AppraisalPolicy.new(user, Appraisal).initiate?
    assert AppraisalPolicy.new(user, Appraisal).complete?
    assert AppraisalPolicy.new(user, Appraisal).performance_interview?
    assert AppraisalPolicy.new(user, Appraisal).performance_interview_check?
    assert AppraisalPolicy.new(user, Appraisal).download?
    assert AppraisalPolicy.new(user, Appraisal).not_filled_participators?
    assert AppraisalPolicy.new(user, Appraisal).departmental_confirm?
    assert AppraisalPolicy.new(user, Appraisal).can_add_to_participator_list?
    assert AppraisalPolicy.new(user, Appraisal).create?
    assert AppraisalPolicy.new(user, Appraisal).create_assessor?
    assert AppraisalPolicy.new(user, Appraisal).destroy_assessor?
    assert AppraisalPolicy.new(user, Appraisal).auto_assign?
    assert AppraisalPolicy.new(user, Appraisal).columns?
    assert AppraisalPolicy.new(user, Appraisal).options?
    assert AppraisalPolicy.new(user, Appraisal).save?
    assert AppraisalPolicy.new(user, Appraisal).submit?
    assert AppraisalPolicy.new(user, Appraisal).revise?
    assert AppraisalPolicy.new(user, Appraisal).side_bar_options?
    assert AppraisalPolicy.new(user, Appraisal).record_options?
    assert AppraisalPolicy.new(user, Appraisal).all_appraisal_report_record_columns?
    assert AppraisalPolicy.new(user, Appraisal).all_appraisal_report_record?
    assert AppraisalPolicy.new(user, Appraisal).completed?
    assert AppraisalPolicy.new(user, Appraisal).complete_or_no?
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
