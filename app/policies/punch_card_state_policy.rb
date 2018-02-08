class PunchCardStatePolicy < ApplicationPolicy

  def report?
    can? :view_for_report
  end

  def report_export_xlsx?
    can? :view_for_report
  end

  def update?
    can? :update
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
