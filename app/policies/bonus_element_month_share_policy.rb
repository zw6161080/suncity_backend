class BonusElementMonthSharePolicy < ApplicationPolicy
  def index?
    can? :data
  end

  def update?
    can? :data
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
