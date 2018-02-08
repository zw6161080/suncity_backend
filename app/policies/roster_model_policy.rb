class RosterModelPolicy < ApplicationPolicy
  def index?
    (can? :manage) || (can? :roster_instruction, :Profile)
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

  def export_xlsx?
    can? :manage
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
