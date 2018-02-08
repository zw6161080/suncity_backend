class ContributionReportItemPolicy < ApplicationPolicy
  def index?
    can? :data
  end

  def columns?
    can? :data
  end

  def options?
    can? :data
  end

  class Scope < Scope
    def resolve
      if (can? :data, :vp)
        scope
      else
        scope.where(grade: [3, 4, 5, 6])
      end
    end
  end
end
