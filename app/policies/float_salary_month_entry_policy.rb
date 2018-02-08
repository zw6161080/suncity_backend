class FloatSalaryMonthEntryPolicy < ApplicationPolicy
  def index?
    can? :data
  end

  def create?
    can? :data
  end

  def show?
    can? :data
  end

  def destroy?
    can? :data
  end

  def bonus_element_items?
    can? :data
  end

  def import_amounts?
    can? :data
  end

  def import_bonus_element_items?
    can? :data
  end

  def locations_with_departments?
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
