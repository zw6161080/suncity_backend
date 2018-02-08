class AttendLogPolicy < ApplicationPolicy
  def index?
    can? :view
  end


  def index_by_department?
    can? :view_from_department
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
