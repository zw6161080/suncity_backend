class ApplicantProfilePolicy < ApplicationPolicy


  def index?
    can? :index
  end

  def show?
    can? :index
  end

  def create?
    can? :update
  end

  def update?
    can? :update
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
