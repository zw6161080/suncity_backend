class BonusElementSettingPolicy < ApplicationPolicy
  def index?
    can? :data
  end

  def update?
    can? :data
  end

  def reset?
    can? :data
  end


  class Scope < Scope
    def resolve
      scope
    end
  end
end
