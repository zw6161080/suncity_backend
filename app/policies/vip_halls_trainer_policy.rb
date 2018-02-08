class VipHallsTrainerPolicy < ApplicationPolicy
  #支持-部门主管贵宾厅权限
  #支持-普通贵宾厅权限
  def index?
    (can? :view_from_department) || (can? :view)
  end
  #支持-部门主管贵宾厅权限
  #支持-普通贵宾厅权限
  def create?
    (can? :view_from_department) || (can? :view)
  end
  #支持-部门主管贵宾厅权限
  #支持-普通贵宾厅权限
  def update?
    (can? :view_from_department) || (can? :view)
  end
  #支持-部门主管贵宾厅权限
  #支持-普通贵宾厅权限
  def export?
    (can? :view_from_department) || (can? :view)
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
