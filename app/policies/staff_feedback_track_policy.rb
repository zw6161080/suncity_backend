class StaffFeedbackTrackPolicy < ApplicationPolicy
  def index?
    can? :manage
  end

  def create?
    can? :manage
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
