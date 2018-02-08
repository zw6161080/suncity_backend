class AppraisalReportPolicy < ApplicationPolicy

  def index?
    can? :view
  end

  def show?
    can? :view
  end

  def side_bar_options?
    can? :view
  end

  class Scope < Scope
    def resolve
      scope
    end
  end
end
