class OccupationTaxItemPolicy < ApplicationPolicy
  def index?
    can? :data
  end

  def columns?
    can? :data
  end

  def options?
    can? :data
  end

  def import?
    can? :data
  end

  def update_comment?
    can? :data
  end


  class Scope < Scope
    def resolve
      if (can? :data, :vp)
        scope
      else
        scope.where(users: {grade: [3, 4, 5, 6]})
      end
    end
  end
end
