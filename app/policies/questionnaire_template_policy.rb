class QuestionnaireTemplatePolicy < ApplicationPolicy

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

  def destroy?
    can? :manage
  end

  def release?
    can? :manage
  end

  def statistics?
    can? :manage
  end

  def instances?
    can? :manage
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
