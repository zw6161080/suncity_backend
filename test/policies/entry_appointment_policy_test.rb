require 'test_helper'

class EntryAppointmentPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_index

    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :EntryAppointment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert EntryAppointmentPolicy.new(user, EntryAppointment).index?

  end

  def test_show

    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :EntryAppointment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert EntryAppointmentPolicy.new(user, EntryAppointment).show?

  end

  def test_create

    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :EntryAppointment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert EntryAppointmentPolicy.new(user, EntryAppointment).create?
  end

  def test_update

    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :EntryAppointment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert EntryAppointmentPolicy.new(user, EntryAppointment).update?
  end

  def test_destroy

    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :EntryAppointment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert EntryAppointmentPolicy.new(user, EntryAppointment).destroy?
  end
end
