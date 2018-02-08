class OccupationTaxSettingPolicy < ApplicationPolicy
  def show?
    can? :data
  end

  def reset?
    can? :data
  end

  def update?
    can? :data
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
