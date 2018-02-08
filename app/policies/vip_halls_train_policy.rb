class VipHallsTrainPolicy < ApplicationPolicy

  def index?
    can? :view
  end

  def lock?
    can? :view
  end

  def create?
    (can? :view_from_department) || (can? :view)
  end


  class Scope < Scope
    def resolve
      scope
    end
  end
end
