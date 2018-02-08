class TrainingAbsenteePolicy < ApplicationPolicy
  #支持-部門主管﹣部門的培訓缺席記錄权限
  #支持-普通查看权限
  def index?
    (can? :view_from_department) || (can? :manage)
  end
  #支持-部門主管﹣部門的培訓缺席記錄权限
  #支持-普通查看权限
  def columns?
    (can? :view_from_department) || (can? :manage)
  end
  #支持-部門主管﹣部門的培訓缺席記錄权限
  #支持-普通查看权限
  def options?
    (can? :view_from_department) || (can? :manage)
  end

  def create?
    can? :manage
  end

  def show?
    can? :manage
  end

  def update?
    can? :manage
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
