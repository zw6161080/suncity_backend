class MedicalTemplatePolicy < ApplicationPolicy
  def show?
    can? :data
  end

  def create?
    can? :data
  end

  def create_permission?
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
