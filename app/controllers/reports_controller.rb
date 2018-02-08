class ReportsController < ApplicationController
  include SortParamsHelper

  before_action :set_report, only: [:show, :update, :destroy, :rows]

  # GET /reports
  def index
    @reports = Report.all.order(id: :desc)
    render json: @reports
  end

  # GET /reports/1
  def show
    render json: @report.as_json(methods: :columns)
  end

  # GET /reports/1/rows
  def rows
    query_params = request.query_parameters

    sort_column = sort_column_sym(query_params[:sort_column], :id)
    sort_direction = sort_direction_sym(query_params[:sort_direction], :desc)
    query = @report.query(
      request_queries: query_params,
      order_key: sort_column,
      order: sort_direction,
      page: query_params.fetch(:page, 1),
      page_per: 20
    )
    meta = {
      total_count: query.total_count,
      current_page: query.current_page,
      total_pages: query.total_pages,
      sort_column: sort_column.to_s,
      sort_direction: sort_direction.to_s,
    }
    response_json query, meta: meta
  end

  # POST /reports
  def create
    @report = Report.new(report_params)

    if @report.save
      render json: @report, status: :created, location: @report
    else
      render json: @report.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /reports/1
  def update
    if @report.update(report_params)
      render json: @report
    else
      render json: @report.errors, status: :unprocessable_entity
    end
  end

  # DELETE /reports/1
  def destroy
    @report.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_report
      @report = Report.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def report_params
      params.fetch(:report, {})
    end
end
