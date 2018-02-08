class TrainTemplatePolicy < ApplicationPolicy
  def index?
    can? :manage
  end

  def show?
    can? :manage
  end

  def create?
    can? :manage
  end

  def update?
    can? :manage
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
