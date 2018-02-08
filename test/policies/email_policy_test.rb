require 'test_helper'

class EmailPolicyTest < ActiveSupport::TestCase

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

  def test_delivery_for_interview
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:delivery_for_interview, :EmailObject, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert EmailObjectPolicy.new(user, EmailObject).delivery_for_interview?
  end
end
