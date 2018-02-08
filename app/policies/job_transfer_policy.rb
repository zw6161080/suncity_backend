class JobTransferPolicy < ApplicationPolicy

  def index?
    can? :view
  end

  def export_xlsx?
    can? :view
  end


  class Scope < Scope
    def resolve
      scope
    end
  end
end
