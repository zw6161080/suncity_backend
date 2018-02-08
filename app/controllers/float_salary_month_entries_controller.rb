class FloatSalaryMonthEntriesController < ApplicationController
  include GenerateXlsxHelper
  before_action :set_float_salary_month_entry, only: [:show, :bonus_element_items, :import_amounts, :update, :destroy, :locations_with_departments, :show_for_search ]

  def locations_with_departments
    authorize FloatSalaryMonthEntry
    render json: ActiveModelSerializers::SerializableResource.new(@float_salary_month_entry).serializer_instance.locations_with_departments
  end

  # GET /float_salary_month_entries
  def index
    authorize FloatSalaryMonthEntry
    year_month = Time.zone.parse(params[:year_month]) rescue nil
    query = FloatSalaryMonthEntry
              .query(year_month)
              .order(year_month: :desc)
              .page
              .page(params.fetch(:page, 1))
              .per(10)

    meta = {
      total_count: query.total_count,
      current_page: query.current_page,
      total_pages: query.total_pages,
    }

    response_json query, meta: meta
  end

  # GET /float_salary_month_entries/year_month_options
  def year_month_options
    res = FloatSalaryMonthEntry.year_month_options
    render json: res, adapter: :attributes
  end

  # GET /float_salary_month_entries/approved_year_month_options
  def approved_year_month_options
    render json: FloatSalaryMonthEntry.approved_year_month_options
  end

  # GET /float_salary_month_entries/1
  def show
    authorize FloatSalaryMonthEntry
    render json: @float_salary_month_entry, adapter: :attributes
  end
  #用于列表页查询状态
  # GET /float_salary_month_entries/1/show_for_search
  def show_for_search
    render json: {id: @float_salary_month_entry.id, status: @float_salary_month_entry.status}
  end

  # GET /float_salary_month_entries/check
  # def check
  #   res = { data: FloatSalaryMonthEntry.exists_by_year_month?(params[:year_month]) }
  #   render json: res
  # end

  # POST /float_salary_month_entries
  def create
    authorize FloatSalaryMonthEntry
    @float_salary_month_entry = FloatSalaryMonthEntry.create_by_year_month(params[:year_month])
    if @float_salary_month_entry.nil?
      render status: :conflict
    else
      render json: @float_salary_month_entry.id
    end
  end

  # POST /float_salary_month_entries/1/bonus_element_items
  def bonus_element_items
    authorize FloatSalaryMonthEntry
    if @float_salary_month_entry.nil?
      render status: :bad_request
    else
      # 更新员工基数
      @float_salary_month_entry.update_per_shares_to_items
      # BonusElementItem.generate_all(@float_salary_month_entry.year_month)
      render json: { success: true }, status: :created
    end
  end

  # POST /float_salary_month_entries/1/import_amounts
  def import_amounts
    authorize FloatSalaryMonthEntry
    begin
      BonusElementMonthAmount.import_xlsx(params[:file], params[:id])
      render json: { success: true }, status: :ok
    rescue LogicError => error
      render json: { message: error.message }, status: :unprocessable_entity
    end
  end


  # POST /float_salary_month_entries/1/import_bonus_element_items
  def import_bonus_element_items
    authorize FloatSalaryMonthEntry
    begin
      BonusElementItem.import_xlsx(params[:file], params[:id])
      render json: { success: true }, status: :ok
    rescue LogicError => error
      render json: { message: error.message }, status: :unprocessable_entity
    end
  end



  # PATCH/PUT /float_salary_month_entries/1
  def update
    authorize FloatSalaryMonthEntry
    if @float_salary_month_entry.update(float_salary_month_entry_params)
      render json: @float_salary_month_entry, adapter: :attributes
    else
      render json: @float_salary_month_entry.errors, status: :unprocessable_entity
    end
  end

  # DELETE /float_salary_month_entries/1
  def destroy
    authorize FloatSalaryMonthEntry
    @float_salary_month_entry.destroy
    render json: { success: true }, status: :ok
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_float_salary_month_entry
      @float_salary_month_entry = FloatSalaryMonthEntry.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def float_salary_month_entry_params
      params.permit(:status)
    end
end
