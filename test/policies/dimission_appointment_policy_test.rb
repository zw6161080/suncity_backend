require 'test_helper'

class DimissionAppointmentPolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_index

    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :DimissionAppointment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert DimissionAppointmentPolicy.new(user, DimissionAppointment).destroy?

  end

  def test_show

    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :DimissionAppointment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert DimissionAppointmentPolicy.new(user, DimissionAppointment).destroy?

  end

  def test_create

    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :DimissionAppointment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert DimissionAppointmentPolicy.new(user, DimissionAppointment).destroy?

  end

  def test_update


    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :DimissionAppointment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert DimissionAppointmentPolicy.new(user, DimissionAppointment).destroy?
  end

  def test_destroy

    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :DimissionAppointment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert DimissionAppointmentPolicy.new(user, DimissionAppointment).destroy?
  end

  def test_statistics

    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :DimissionAppointment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert DimissionAppointmentPolicy.new(user, DimissionAppointment).destroy?

  end

  def test_send_content

    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :DimissionAppointment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert DimissionAppointmentPolicy.new(user, DimissionAppointment).destroy?

  end

  def test_export_xlsx

    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:manage, :DimissionAppointment, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert DimissionAppointmentPolicy.new(user, DimissionAppointment).destroy?

  end
end
