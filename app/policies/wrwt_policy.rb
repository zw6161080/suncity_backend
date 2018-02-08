class WrwtPolicy < ApplicationPolicy
  def current_wrwt_by_user?
    can? :information, :welfare_info
  end

  def update?
    can? :update_information, :welfare_info
  end


  class Scope < Scope
    def resolve
      scope
    end
  end
end
