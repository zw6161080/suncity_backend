class AnnualAwardReportPolicy < ApplicationPolicy
  def index?
    can? :data
  end

  def show?
    can? :data
  end

  def create?
    can? :data
  end

  def destroy?
    can? :data
  end

  def grant?
    can? :data
  end


  class Scope < Scope
    def resolve
      scope
    end
  end
end
