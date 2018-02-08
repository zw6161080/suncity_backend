require 'test_helper'

class SmsPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_delivery_for_interview
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:delivery_for_interview, :Sms, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert SmsPolicy.new(user, Sms).delivery_for_interview?
  end

  def test_create
  end

  def test_update
  end

  def test_destroy
  end
end
