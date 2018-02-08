require 'test_helper'

class AirTicketReimbursementPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
  end

  def test_create
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update_information, :AirTicketReimbursement, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AirTicketReimbursementPolicy.new(user, AirTicketReimbursement).create?
  end

  def test_update
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update_information, :AirTicketReimbursement, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AirTicketReimbursementPolicy.new(user, AirTicketReimbursement).update?
  end

  def test_destroy
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:update_information, :AirTicketReimbursement, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AirTicketReimbursementPolicy.new(user, AirTicketReimbursement).destroy?
  end

  def test_index_by_user
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:information, :AirTicketReimbursement, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert AirTicketReimbursementPolicy.new(user, AirTicketReimbursement).index_by_user?
  end
end
