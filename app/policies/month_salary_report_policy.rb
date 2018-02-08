class MonthSalaryReportPolicy < ApplicationPolicy
  def index?
    can?(:data_on_all_month_salary)
  end

  def index_by_left?
    can?(:data_on_each_month_salary)
  end

  def index_by_left_export?
    can?(:data_on_each_month_salary)
  end

  def show_export?
    can?(:data_on_each_month_salary)
  end

  def index_export?
    can?(:data_on_all_month_salary)
  end

  def show?
    can?(:data_on_each_month_salary)
  end

  def create?
    can?(:data_on_each_month_salary)
  end

  def update?
    can?(:data_on_each_month_salary)
  end


  def cancel?
    can?(:data) or can?(:data_on_each_month_salary)
  end

  def preliminary_examine?
    can?(:data) or can?(:data_on_each_month_salary)
  end

  def president_examine?
    can?(:data) or can?(:data_on_each_month_salary)
  end

  def update_by_user?
    can?(:data_on_each_month_salary)
  end

  def examine_by_user?
    can?(:data_on_each_month_salary)
  end

  class Scope < Scope
    def resolve(action, year_month = nil)
      if(can?(:data, :vp))
        scope
      else
        scope.joins(user: :salary_values).by_action_and_year_month_on_salary_values_users(action, year_month).where(salary_values_users: {salary_column_id: 9}).where(salary_values_users: {integer_value: [3,4,5,6]})
      end
    end
  end
end
