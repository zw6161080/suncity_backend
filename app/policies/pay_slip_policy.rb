class PaySlipPolicy < ApplicationPolicy
  def index?
    can?(:data_on_pay_slip_by_hr)
  end

  def index_by_department?
    can?(:data_on_pay_slip_by_department)
  end

  def show?
    can?(:data) || can?(:data_on_pay_slip_by_hr) || can?(:data_on_pay_slip_by_department)
  end

  class Scope < Scope
    def resolve(action)
      if(can? :data, :vp)
        scope
      else
        if action == :index || action == :index_by_department
          scope.joins(user: :salary_values).by_action_and_year_month_on_pay_slips.where(salary_values: {salary_column_id: 9}).where(salary_values: {integer_value: [3,4,5,6]})
        else
          scope
        end
      end
    end
  end
end
