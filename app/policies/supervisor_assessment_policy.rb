class SupervisorAssessmentPolicy < ApplicationPolicy
  def index?
    show?
  end

  class Scope < Scope
    def resolve
      scope
    end
  end

  private

  def show?
    can? :view_from_department
  end
end
