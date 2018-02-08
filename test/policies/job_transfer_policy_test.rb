require 'test_helper'

class JobTransferPolicyTest < ActiveSupport::TestCase

  def test_scope
  end


  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :job_transfer, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert JobTransferPolicy.new(user, JobTransfer).index?
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
