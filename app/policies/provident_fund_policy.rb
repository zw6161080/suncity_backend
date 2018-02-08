class ProvidentFundPolicy < ApplicationPolicy
  def index?
    can? :data
  end

  def create?
    can? :data
  end

  def update?
    can? :data
  end

  def update_from_profile?
    can? :update_information_from_profile
  end

  def show?
    can? :information
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
