class RosterPreferencePolicy < ApplicationPolicy
  def show?
    can? :view
  end

  def index?
    can? :setting
  end

  def employee_roster_model_state_settings?
    can? :setting
  end

  def employee_roster_model_state_settings_export_xlsx?
    can? :setting
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
