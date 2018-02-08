class SignCardReasonPolicy < ApplicationPolicy

  def create?
    can? :setting
  end

  def update?
    can? :setting
  end

  def destroy?
    can? :setting
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
