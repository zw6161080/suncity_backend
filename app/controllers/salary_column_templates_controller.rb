class SalaryColumnTemplatesController < ApplicationController
  before_action :set_salary_column_template, only: [:show, :update, :destroy, :set_default]

  # GET /salary_column_templates
  def index
    @salary_column_templates = SalaryColumnTemplate.all

    render json: @salary_column_templates
  end

  # GET /salary_column_templates/1
  def show
    render json: @salary_column_template
  end

  # POST /salary_column_templates
  def create
    @salary_column_template = SalaryColumnTemplate.new(salary_column_template_params.except(:column_array))
    if @salary_column_template.save
      @salary_column_template.add_salary_column(salary_column_template_params[:column_array]) if salary_column_template_params[:column_array]
      render json: @salary_column_template, status: :created, location: @salary_column_template
    else
      render json: @salary_column_template.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /salary_column_templates/1
  def update
    if @salary_column_template.update(salary_column_template_params.except(:column_array))
      @salary_column_template.update_salary_column(salary_column_template_params[:column_array]) if salary_column_template_params[:column_array]
      render json: @salary_column_template
    else
      render json: @salary_column_template.errors, status: :unprocessable_entity
    end
  end

  # DELETE /salary_column_templates/1
  def destroy
    render json: @salary_column_template.destroy
  end

  # get /salary_column_templates/all_columns
  def all_columns
    render json: SalaryColumn.all.where.not(id: 0).where.not('id > 1000')
  end

  def set_default
    render json: @salary_column_template.set_default_template
  end

  def get_default_template
    render json: SalaryColumnTemplate.find_by_default(true)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_salary_column_template
      @salary_column_template = SalaryColumnTemplate.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def salary_column_template_params
      params.fetch(:salary_column_template, {}).permit(*SalaryColumnTemplate.create_params + [{column_array: []}])
    end
end
