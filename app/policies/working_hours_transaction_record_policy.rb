require_relative '../../app/policies/concerns/attend_record_policies'
class WorkingHoursTransactionRecordPolicy < ApplicationPolicy
  include AttendRecordPolicies

  class Scope < Scope
    def resolve
      scope
    end
  end
end
