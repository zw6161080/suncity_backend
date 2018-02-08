require_relative 'concerns/job_transfer_policies'
class TransferLocationApplyPolicy < ApplicationPolicy
  include JobTransferPolicies
  class Scope < Scope
    def resolve
      scope
    end
  end
end
