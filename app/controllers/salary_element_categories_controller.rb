class SalaryElementCategoriesController < ApplicationController
  # before_action :set_salary_element_category, only: [:show, :update, :destroy]

  # GET /salary_element_categories
  def index
    @salary_element_categories = SalaryElementCategory.all
    render json: @salary_element_categories, status: 200, include: '**'
  end

  # GET /salary_element_categories/1
  def show
    render json: @salary_element_category, status: 200, include: '**'
  end

  # POST /salary_element_categories
  def create
    @salary_element_category = SalaryElementCategory.new(salary_element_category_params)

    if @salary_element_category.save
      render json: @salary_element_category, status: :created, location: @salary_element_category
    else
      render json: @salary_element_category.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /salary_element_categories/1
  def update
    if @salary_element_category.update(salary_element_category_params)
      render json: @salary_element_category
    else
      render json: @salary_element_category.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /salary_element_categories/reset
  def reset
    SalaryElementCategory.reset_predefined
    render json: { success: true }, status: :ok
  end

  # DELETE /salary_element_categories/1
  def destroy
    @salary_element_category.destroy
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_salary_element_category
    @salary_element_category = SalaryElementCategory.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def salary_element_category_params
    params.fetch(:salary_element_category, {})
  end
end
