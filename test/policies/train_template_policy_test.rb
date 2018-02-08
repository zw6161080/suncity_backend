require 'test_helper'

class TrainTemplatePolicyTest < ActiveSupport::TestCase

  def test_scope

  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :train_template, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainTemplatePolicy.new(user, TrainTemplate).index?

  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :train_template, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainTemplatePolicy.new(user, TrainTemplate).show?
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :train_template, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainTemplatePolicy.new(user, TrainTemplate).create?
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :train_template, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert TrainTemplatePolicy.new(user, TrainTemplate).update?
  end

end
