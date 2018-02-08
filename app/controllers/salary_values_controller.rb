class SalaryValuesController < ApplicationController
  before_action :set_salary_value, only: [:update_value]

  def update_value
    render json: {data: @salary_value.update_value(params[:value])}
  end

  private
  def set_salary_value
    @salary_value =  SalaryValue.find(params[:id])
  end
end
