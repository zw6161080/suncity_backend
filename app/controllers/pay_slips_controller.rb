class PaySlipsController < ApplicationController
  include StatementBaseActions
  include ActionController::MimeResponds
  include GenerateXlsxHelper
  include SortParamsHelper
  include MineCheckHelper
  before_action :set_pay_slip, only: [:show, :update, :destroy]
  before_action :set_user, only: [:index_by_mine]
  before_action :myself?, only:[:index_by_mine]
  before_action :get_user, only:[:show]
  before_action :myself?, only:[:show], if: :entry_from_mine?



  # GET /pay_slips
  def index
    authorize PaySlip
    sort_column = sort_column_sym(final_sort_column(params[:sort_column], 'PaySlip'), :default_order)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = PaySlip.where(id: search_query.ids)
    query =  PaySlipPolicy::Scope.new(current_user, PaySlip.where(id: query.ids)).resolve(:index)
    query = query.by_order(sort_column, sort_direction)
    #权限处理后的结果
    respond_to do |format|
      format.json {
        query = query.page.page(params.fetch(:page, 1)).per(20)
        meta = {
          total_count: query.total_count,
          current_page: query.current_page,
          total_pages: query.total_pages,
          sort_column: sort_column.to_s,
          sort_direction: sort_direction.to_s,
        }
        render json: query, status: 200, root: 'data', meta: meta, include: '**'
      }
    end
  end

  def index_by_department
    authorize PaySlip
    sort_column = sort_column_sym(final_sort_column(params[:sort_column], 'PaySlip'), :default_order)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = PaySlip.where(id: search_query.ids).by_department_id([params[:department_id_index]])
    query = PaySlip.where(id: query.ids).by_order(sort_column, sort_direction)
    query =  PaySlipPolicy::Scope.new(current_user, PaySlip.where(id: query.ids)).resolve(:index_by_department)
    respond_to do |format|
      format.json {
        query = query.page.page(params.fetch(:page, 1)).per(20)
        meta = {
          department: Department.where(id: params[:department_id_index]).first,
          total_count: query.total_count,
          current_page: query.current_page,
          total_pages: query.total_pages,
          sort_column: sort_column.to_s,
          sort_direction: sort_direction.to_s,
        }
        render json: query, status: 200, root: 'data', meta: meta, include: '**'
      }
    end
  end

  def index_by_mine
    sort_column = sort_column_sym(final_sort_column(params[:sort_column], 'PaySlip'), :default_order)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query.where(user_id: @user)
    query = PaySlip.where(id: query.ids).by_order(sort_column, sort_direction)
    respond_to do |format|
      format.json {
        query = query.page.page(params.fetch(:page, 1)).per(20)
        meta = {
          total_count: query.total_count,
          current_page: query.current_page,
          total_pages: query.total_pages,
          sort_column: sort_column.to_s,
          sort_direction: sort_direction.to_s,
        }
        render json: query, status: 200, root: 'data', meta: meta, include: '**'
      }
    end
  end

  # GET /pay_slips/1
  def show
    @user = User.find(@pay_slip.user_id)
    #权限处理后的结果
    authorize PaySlip unless  entry_from_mine? || @pay_slip.without_grade_limition?
    render json: @pay_slip, include: '**'
  end


  def options
    render json: PaySlip.options
  end

  def columns
    render json: PaySlip.statement_columns
  end

  private
    def get_user
      @user = @pay_slip.user
    end

    def set_user
      @user = User.find(params[:user_id])
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_pay_slip
      @pay_slip = PaySlip.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def pay_slip_params
      params.fetch(:pay_slip, {})
    end

    def search_query
      salary_begin_begin = Time.zone.parse(params[:salary_begin][:begin]).beginning_of_day rescue nil
      salary_begin_end = Time.zone.parse(params[:salary_begin][:end]).end_of_day rescue nil
      salary_end_begin = Time.zone.parse(params[:salary_end][:begin]).beginning_of_day rescue nil
      salary_end_end = Time.zone.parse(params[:salary_end][:end]).end_of_day rescue nil
      PaySlip.joins_user
        .by_year_month(params[:year_month])
        .by_salary_begin(salary_begin_begin, salary_begin_end)
        .by_salary_end(salary_end_begin, salary_end_end)
        .by_name(params[:name])
        .by_empoid(params[:empoid])
        .by_company_name(params[:company_name])
        .by_department_id(params[:department_id])
        .by_position_id(params[:position_id])
        .by_location_id(params[:location_id])
        .by_entry_on_this_month(params[:entry_on_this_month])
        .by_leave_on_this_month(params[:leave_on_this_month])
    end
end
