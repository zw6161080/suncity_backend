class RosterModelStatePolicy < ApplicationPolicy
  def update?
    can? :update
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
