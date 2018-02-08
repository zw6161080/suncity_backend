class QuestionnairePolicy < ApplicationPolicy

  def index?
    can? :manage
  end

  def show?
    can? :manage
  end

  def update?
    can? :manage
  end

  def edit?
    can? :manage
  end

  def destroy?
    can? :manage
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
