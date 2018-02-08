class SalaryElementFactorsController < ApplicationController
  before_action :set_salary_element_factor, only: [:show, :update, :destroy]

  # GET /salary_element_factors
  def index
    @salary_element_factors = SalaryElementFactor.all

    render json: @salary_element_factors
  end

  # GET /salary_element_factors/1
  def show
    render json: @salary_element_factor
  end

  # POST /salary_element_factors
  def create
    @salary_element_factor = SalaryElementFactor.new(salary_element_factor_params)

    if @salary_element_factor.save
      render json: @salary_element_factor, status: :created, location: @salary_element_factor
    else
      render json: @salary_element_factor.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /salary_element_factors/1
  def update
    if @salary_element_factor.update(salary_element_factor_update_params)
      render json: @salary_element_factor
    else
      render json: @salary_element_factor.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /salary_element_factors
  def batch_update
    SalaryElementFactor.batch_update(salary_element_factor_batch_update_params[:updates])
    response_json
  end

  # DELETE /salary_element_factors/1
  def destroy
    @salary_element_factor.destroy
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_salary_element_factor
    @salary_element_factor = SalaryElementFactor.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def salary_element_factor_params
    params.permit(SalaryElementFactor.create_params)
  end

  def salary_element_factor_update_params
    params.permit(:numerator, :denominator, :value)
  end

  def salary_element_factor_batch_update_params
    params.permit(updates: [:id, :numerator, :denominator, :value])
  end
end