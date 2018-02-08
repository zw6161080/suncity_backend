class ContractInformationTypePolicy < ApplicationPolicy

  def create?
    can? :information
  end


  def update?
    can? :information
  end

  def destroy?
    can? :information
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
