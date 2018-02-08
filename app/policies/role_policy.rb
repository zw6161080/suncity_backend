class RolePolicy < ApplicationPolicy
  def index?
    can? :admin, :global
  end

  def update?
    can? :admin, :global
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
