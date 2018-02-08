class LoveFundPolicy < ApplicationPolicy
  def index?
    can? :data
  end

  def export?
    can? :data
  end

  def update?
    can? :data
  end

  def show?
    can? :information, :welfare_info
  end

  def update_from_profile?
    can? :update_information, :welfare_info
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
