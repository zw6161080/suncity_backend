class SalaryColumnsController < ApplicationController
  before_action :set_salary_column, only: [:show, :update, :destroy]

  # GET /salary_columns
  def index
    @salary_columns = SalaryColumn.all

    render json: @salary_columns
  end

  # GET /salary_columns/1
  def show
    render json: @salary_column
  end

  # POST /salary_columns
  def create
    @salary_column = SalaryColumn.new(salary_column_params)

    if @salary_column.save
      render json: @salary_column, status: :created, location: @salary_column
    else
      render json: @salary_column.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /salary_columns/1
  def update
    if @salary_column.update(salary_column_params)
      render json: @salary_column
    else
      render json: @salary_column.errors, status: :unprocessable_entity
    end
  end

  # DELETE /salary_columns/1
  def destroy
    @salary_column.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_salary_column
      @salary_column = SalaryColumn.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def salary_column_params
      params.fetch(:salary_column, {})
    end
end
