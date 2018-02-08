require 'test_helper'

class VipHallsTrainPolicyTest < ActiveSupport::TestCase

  def test_scope

  end

  def test_show

  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :vip_hall, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert VipHallsTrainPolicy.new(user, VipHallsTrain).create?

  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :vip_hall, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert VipHallsTrainPolicy.new(user, VipHallsTrain).create?
  end


  def test_lock
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :vip_hall, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert VipHallsTrainPolicy.new(user, VipHallsTrain).create?

  end

  def test_update

  end

  def test_destroy

  end
end
