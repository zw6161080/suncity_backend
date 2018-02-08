class ApprovedJobPolicy < ApplicationPolicy
  def index?
    can? :view
  end

  def create?
    can? :view
  end


  class Scope < Scope
    def resolve
      scope
    end
  end
end
