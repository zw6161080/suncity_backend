class PunishmentPolicy < ApplicationPolicy
  def index?
    can? :manage
  end

  def export?
    can? :manage
  end

  def show?
    can? :manage
  end

  def show_profile?
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

  def profile_index?
    can? :information
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
