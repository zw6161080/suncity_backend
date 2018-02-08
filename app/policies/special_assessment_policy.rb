require_relative 'concerns/job_transfer_policies'
class SpecialAssessmentPolicy < ApplicationPolicy
  include JobTransferPolicies
  class Scope < Scope
    def resolve
      scope
    end
  end
end
