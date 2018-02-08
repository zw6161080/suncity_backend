require 'test_helper'

class RolePolicyTest < ActiveSupport::TestCase

  setup do
    @current_user = create(:user)
    RolesController.any_instance.stubs(:current_user).returns(@current_user)
    RolesController.any_instance.stubs(:current_region).returns(:macau)

    @admin_role = create(:role)
    @admin_role.add_permission_by_attribute(:admin, :global, :macau)
  end

  # test 'index?' do
  #   assert_equal RolePolicy.new(@current_user, Role).index?, false

  #   @current_user.add_role(@admin_role)
  #   assert_equal RolePolicy.new(@current_user, Role).index?, true
  # end

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
end
