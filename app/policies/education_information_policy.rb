class EducationInformationPolicy < ApplicationPolicy
  def index_by_user?
    can? :information
  end
  def create?
    can? :update_information
  end

  def update?
    can? :update_information
  end

  def destroy?
    can? :update_information
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
