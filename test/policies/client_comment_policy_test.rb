require 'test_helper'

class ClientCommentPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :client_comment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ClientCommentPolicy.new(user, ClientComment).show?

  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :client_comment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ClientCommentPolicy.new(user, ClientComment).create?

  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :client_comment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ClientCommentPolicy.new(user, ClientComment).update?

  end

  def test_show_tracker
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :client_comment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ClientCommentPolicy.new(user, ClientComment).show_tracker?

  end

  def test_columns
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :client_comment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ClientCommentPolicy.new(user, ClientComment).columns?

  end

  def test_options
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :client_comment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ClientCommentPolicy.new(user, ClientComment).options?

  end
end
