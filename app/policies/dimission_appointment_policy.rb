class DimissionAppointmentPolicy < ApplicationPolicy
  def index?
    can? :manage
  end

  def show?
    can? :manage
  end

  def create?
    can? :manage
  end

  def update?
    can? :manage
  end

  def destroy?
    can? :manage
  end

  def statistics?
    can? :manage
  end

  def send_content?
    can? :manage
  end

  def export_xlsx?
    can? :manage
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
