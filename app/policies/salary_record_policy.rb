class SalaryRecordPolicy < ApplicationPolicy

  def create?
    can? :update_history
  end

  def update?
    can? :update_history
  end
  def show?
    can? :data, :vp
  end
  def destroy?
    can? :data, :vp
  end

  def current_salary_record_by_user?
    can? :information
  end

  def index_by_user?
    can? :history
  end

  class Scope < Scope
    def resolve
      if (can? :data, :vp)
        scope
      else
        scope.joins(:user).where(users: {grade: [3, 4, 5, 6]})
      end
    end
  end
end
