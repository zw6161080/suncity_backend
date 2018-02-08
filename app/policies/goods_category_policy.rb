class GoodsCategoryPolicy < ApplicationPolicy
  def index?
    can? :data
  end

  def options?
    can? :data
  end

  def columns?
    can? :data
  end

  def create?
    can? :data
  end

  def update?
    can? :data
  end

  def destroy?
    can? :data
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
