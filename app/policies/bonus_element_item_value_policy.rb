class BonusElementItemValuePolicy < ApplicationPolicy
  def update?
    can? :data
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
