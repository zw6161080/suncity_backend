require 'test_helper'

class QuestionnaireTemplatePolicyTest < ActiveSupport::TestCase

  def test_scope

  end

  def test_index?
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :QuestionnaireTemplate, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert QuestionnaireTemplatePolicy.new(user, QuestionnaireTemplate).index?

  end

  def test_show

    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :QuestionnaireTemplate, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert QuestionnaireTemplatePolicy.new(user, QuestionnaireTemplate).show?
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :QuestionnaireTemplate, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert QuestionnaireTemplatePolicy.new(user, QuestionnaireTemplate).create?
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :QuestionnaireTemplate, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert QuestionnaireTemplatePolicy.new(user, QuestionnaireTemplate).update?
  end

  def test_destroy
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :QuestionnaireTemplate, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert QuestionnaireTemplatePolicy.new(user, QuestionnaireTemplate).destroy?
  end

  def release?
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :QuestionnaireTemplate, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert QuestionnaireTemplatePolicy.new(user, QuestionnaireTemplate).release?

  end

  def statistics?
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :QuestionnaireTemplate, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert QuestionnaireTemplatePolicy.new(user, QuestionnaireTemplate).statistics?

  end
  def instance?
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :QuestionnaireTemplate, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert QuestionnaireTemplatePolicy.new(user, QuestionnaireTemplate).instance?

  end

end
