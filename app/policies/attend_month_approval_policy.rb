class AttendMonthApprovalPolicy < ApplicationPolicy
  def index?
    can? :view
  end

  def create?
    can? :view
  end

  def export_xlsx?
    can? :view
  end

  def approval?
    can? :view
  end

  def cancel_approval?
    can? :view
  end


  class Scope < Scope
    def resolve
      scope
    end
  end
end
