class LentRecordPolicy < ApplicationPolicy
  def update?
    can? :update_history
  end

  def create?
    can? :update_history
  end
  def index_by_user?
    can? :history
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
