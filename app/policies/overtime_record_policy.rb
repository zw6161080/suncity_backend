require_relative '../../app/policies/concerns/attend_record_policies'
require_relative '../../app/policies/concerns/attend_report_policies'
class OvertimeRecordPolicy < ApplicationPolicy
  include AttendReportPolicies
  include AttendRecordPolicies
  class Scope < Scope
    def resolve
      scope
    end
  end
end
