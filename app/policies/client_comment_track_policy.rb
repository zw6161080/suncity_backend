class ClientCommentTrackPolicy < ApplicationPolicy
  def show?
    can? :view
  end

  def create?
    can? :view
  end

  def update?
    can? :view
  end

  def destroy?
    can? :view
  end




  class Scope < Scope
    def resolve
      scope
    end
  end
end
