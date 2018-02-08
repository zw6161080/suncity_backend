class StaffFeedbackPolicy < ApplicationPolicy
  def index?
    can? :manage
  end

  def index_my_feedbacks?
    can? :manage
  end

  def export_all_feedbacks?
    can? :manage
  end

  def create?
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
