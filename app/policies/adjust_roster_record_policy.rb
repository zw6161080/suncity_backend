require_relative '../../app/policies/concerns/attend_record_policies'
class AdjustRosterRecordPolicy < ApplicationPolicy
  include AttendRecordPolicies

  def report?
    can? :view_for_report
  end

  def report_export_xlsx?
    can? :view_for_report
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
