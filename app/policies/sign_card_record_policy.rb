require_relative '../../app/policies/concerns/attend_record_policies'
require_relative '../../app/policies/concerns/attend_report_policies'
class SignCardRecordPolicy < ApplicationPolicy
  include AttendRecordPolicies
  include AttendReportPolicies
  class Scope < Scope
    def resolve
      scope
    end
  end
end
