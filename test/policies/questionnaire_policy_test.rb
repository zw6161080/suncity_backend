require 'test_helper'

class QuestionnairePolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Questionnaire, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert QuestionnairePolicy.new(user, Questionnaire).index?

  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Questionnaire, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert QuestionnairePolicy.new(user, Questionnaire).show?

  end


  def test_edit
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Questionnaire, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert QuestionnairePolicy.new(user, Questionnaire).edit?

  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Questionnaire, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert QuestionnairePolicy.new(user, Questionnaire).update?

  end

  def test_destroy
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :Questionnaire, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert QuestionnairePolicy.new(user, Questionnaire).destroy?

  end
end
