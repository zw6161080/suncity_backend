class ApplicantPositionPolicy < ApplicationPolicy
  def show?
    can? :show
  end

  def update_status?
    can? :update_status
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
