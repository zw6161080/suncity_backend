class ProfitConflictInformationPolicy < ApplicationPolicy
  def show?
    can? :information
  end

  def update?
    can? :update_information
  end


  class Scope < Scope
    def resolve
      scope
    end
  end
end
