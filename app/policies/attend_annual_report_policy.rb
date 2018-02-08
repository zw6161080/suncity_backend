class AttendAnnualReportPolicy < ApplicationPolicy
  def index?
    can? :view_for_report
  end

  def export_xlsx?
    can? :view_for_report
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
