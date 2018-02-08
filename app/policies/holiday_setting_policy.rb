class HolidaySettingPolicy < ApplicationPolicy

  def index?
    can? :setting
  end

  def create?
    can? :setting
  end

  def update?
    can? :setting
  end

  def destroy?
    can? :setting
  end

  def batch_create?
    can? :setting
  end


  class Scope < Scope
    def resolve
      scope
    end
  end
end
