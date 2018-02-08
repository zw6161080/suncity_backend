class MuseumRecordPolicy < ApplicationPolicy
  def index_by_user?
    can? :history
  end

  def update?
    can? :update_history
  end

  def create?
    can? :update_history
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
