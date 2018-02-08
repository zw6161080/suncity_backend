require 'test_helper'

class VipHallsTrainerPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :vip_hall, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert VipHallsTrainerPolicy.new(user, VipHallsTrainer).create?

  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :vip_hall, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert VipHallsTrainerPolicy.new(user, VipHallsTrainer).create?

  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :vip_hall, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert VipHallsTrainerPolicy.new(user, VipHallsTrainer).create?

  end

  def test_destroy
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view_from_department, :vip_hall, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert VipHallsTrainerPolicy.new(user, VipHallsTrainer).create?

  end

  def test_export

  end
end
