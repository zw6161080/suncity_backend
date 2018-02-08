require 'test_helper'

class RosterPreferencePolicyTest < ActiveSupport::TestCase

  def test_scope
  end

  def test_show
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:view, :shift, :macau)
    user = create_test_user
    user.add_role(admin_role)
    assert RosterPreferencePolicy.new(user, RosterPreference).show?
  end

  def test_index
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :RosterPreference, :macau)
    user = create_test_user
    user.add_role(admin_role)
    assert RosterPreferencePolicy.new(user, RosterPreference).index?
  end

  def test_employee_roster_model_state_settings
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :RosterPreference, :macau)
    user= create_test_user
    user.add_role(admin_role)
    assert RosterPreferencePolicy.new(user, RosterPreference).employee_roster_model_state_settings?
  end

  def test_employee_roster_model_state_settings_export_xlsx
    admin_role = create(:role)
    admin_role.add_permission_by_attribute(:setting, :RosterPreference, :macau)
    user = create_test_user
    user.add_role(admin_role)
    assert RosterPreferencePolicy.new(user, RosterPreference).employee_roster_model_state_settings_export_xlsx?
  end

  def test_create
  end

  def test_update
  end

  def test_destroy
  end
end
