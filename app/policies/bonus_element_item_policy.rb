class BonusElementItemPolicy < ApplicationPolicy
  def index?
    can? :data
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
