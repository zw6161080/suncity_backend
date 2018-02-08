class LocationPolicy < ApplicationPolicy
  def tree?
    can? :access_company_structure_management, :global
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
