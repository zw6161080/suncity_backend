class ProfileAttachmentPolicy < ApplicationPolicy
  def create?
    can? :update_history
  end

  def update?
    can? :update_history
  end

  def destroy?
    can? :update_history
  end
  def index?
    can? :history
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
