require 'test_helper'

class ClientCommentTrackPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :client_comment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ClientCommentTrackPolicy.new(user, ClientCommentTrack).show?

  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :client_comment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ClientCommentTrackPolicy.new(user, ClientCommentTrack).create?

  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :client_comment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ClientCommentTrackPolicy.new(user, ClientCommentTrack).update?

  end

  def test_destroy
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :client_comment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert ClientCommentTrackPolicy.new(user, ClientCommentTrack).destroy?

  end
end
