class MonthSalaryReportsController < ApplicationController
  include ActionController::MimeResponds
  include GenerateXlsxHelper
  include SortParamsHelper
  before_action :set_month_salary_report, only: [
    :show, :update, :destroy, :president_examine, :preliminary_examine,
    :cancel, :show_by_options, :show_export]
  before_action :set_user, only: [:examine_by_user, :update_by_user]

  before_action :set_month_salary_report_left, only: [:examine_by_user, :update_by_user]

  def index_options
    render json: MonthSalaryReport.index_options
  end

  def index_by_left_options
    render json: MonthSalaryReport.index_by_left_options
  end

  def show_by_options
    render json: @month_salary_report.show_by_options
  end


  # GET /month_salary_reports
  def index
    authorize MonthSalaryReport
    search_result = search_index
    query = search_result[:query]
    page = search_result[:page]

    total_count = query.as_json.count
    total_pages = total_count % 20 == 0 ? total_count / 20 : total_count / 20 + 1
    page = 1 if page.to_i > total_pages
    query = query.offset((page.to_i - 1) * 20).limit(20)

    #权限处理后的query
    respond_to do |format|
      format.json {
        render json: {
          month_salary_report: @month_salary_report,
          salary_values: MonthSalaryReport.salary_value(query),
          user_year_month: query,
          meta: {
            total_count: total_count,
            current_page: page,
            total_pages: total_pages,
          }
        }
      }
    end
  end

  def index_by_left
    authorize MonthSalaryReport
    search_result = search_index_by_left
    query = search_result[:query]
    page = search_result[:page]

    total_count = query.as_json.count
    total_pages = total_count % 20 == 0 ? total_count / 20 : total_count / 20 + 1
    page = 1 if page.to_i > total_pages
    query = query.offset((page.to_i - 1) * 20).limit(20)

    #权限处理后的query
    respond_to do |format|
      format.json {
        render json: {
          month_salary_report: @month_salary_report,
          salary_values: MonthSalaryReport.salary_value(query),
          user_year_month: query,
          meta: {
            total_count: total_count,
            current_page: page,
            total_pages: total_pages,
          }
        }
      }
    end
  end

  def index_by_left_export
    authorize MonthSalaryReport
    search_result = search_index_by_left
    query = search_result[:query]
    month_salary_index_by_left_export_export_num = Rails.cache.fetch('month_salary_index_by_left_export_export_num', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ month_salary_index_by_left_export_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('month_salary_index_by_left_export_export_num', month_salary_index_by_left_export_export_num + 1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{I18n.t(self.controller_name+'.index_by_left.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    MonthSalaryReportGeneratingJobJob.perform_later(query.ids, MonthSalaryReport.raw_salary_value(query).ids, params[:original_column_order], my_attachment, 'index_by_left')
    render json: my_attachment
  end

  def show_export
    authorize MonthSalaryReport
    search_result = search_show
    query = search_result[:query]
    month_salary_show_export_export_num = Rails.cache.fetch('month_salary_show_export_export_num', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ month_salary_show_export_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('month_salary_show_export_export_num', month_salary_show_export_export_num + 1)

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{I18n.t(self.controller_name+'.show.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    MonthSalaryReportGeneratingJobJob.perform_later(
        query.ids,
        MonthSalaryReport.raw_salary_value(query).ids,
        params[:original_column_order],
        my_attachment,
        'show'
    )
    render json: my_attachment
  end


  def index_export
    authorize MonthSalaryReport
    search_result = search_index
    query = search_result[:query]
    month_salary_index_export_export_num = Rails.cache.fetch('month_salary_index_export_export_num', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ month_salary_index_export_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('month_salary_index_export_export_num', month_salary_index_export_export_num + 1)

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{I18n.t(self.controller_name+'.index.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    MonthSalaryReportGeneratingJobJob.perform_later(query.ids, MonthSalaryReport.raw_salary_value(query).ids, params[:original_column_order], my_attachment, 'index')
    render json: my_attachment
  end


  # GET /month_salary_reports/1
  def show
    authorize MonthSalaryReport
    search_result = search_show
    query = search_result[:query]
    page = search_result[:page]

    total_count = query.as_json.count
    total_pages = total_count % 20 == 0 ? total_count / 20 : total_count / 20 + 1
    page = 1 if page.to_i > total_pages.to_i

    query = query.offset((page.to_i - 1) * 20).limit(20)

    #权限处理后的query
    respond_to do |format|
      format.json {
        render json: {
          month_salary_report: @month_salary_report,
          salary_values: MonthSalaryReport.salary_value(query),
          user_year_month: query,
          meta: {
            total_count: total_count,
            current_page: page,
            total_pages: total_pages,
          }
        }
      }
    end
  end

  # POST /month_salary_reports
  def create
    authorize MonthSalaryReport
    @month_salary_report = MonthSalaryReport.new(year_month: year_month, salary_type: :on_duty)
    if @month_salary_report.save
      render json: @month_salary_report, status: :created, location: @month_salary_report
    else
      render json: @month_salary_report.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /month_salary_reports/1
  def update
    authorize MonthSalaryReport
    Rails.cache.clear
    if @month_salary_report.re_calculate_later
      render json: @month_salary_report.reload
    else
      render json: @month_salary_report.errors, status: :unprocessable_entity
    end
  end

  # DELETE /month_salary_reports/1
  # def destroy
  #   @month_salary_report.destroy
  # end

  def president_examine

    authorize MonthSalaryReport

    @month_salary_report.update_salary_value_to_president_examine
    render json:  @month_salary_report.president_examine
  end

  def preliminary_examine
    authorize MonthSalaryReport

    @month_salary_report.update_salary_value_to_preliminary_examine
    render json:  @month_salary_report.preliminary_examine
  end

  def cancel

    authorize MonthSalaryReport

    @month_salary_report.update_salary_value_to_not_granted
    render json:  @month_salary_report.cancel
  end

  def options
    render json: MonthSalaryReport.where(salary_type: :on_duty)
  end

  def update_by_user
    authorize MonthSalaryReport
    Rails.cache.clear
    render json:  @month_salary_report.re_calculate_later_by_user(@user, params[:resignation_record_id])
  end

  def examine_by_user
    authorize MonthSalaryReport
    render json:  {result: @month_salary_report.examine_by_user(@user, params[:resignation_record_id])}
  end

  private
  def search_index_by_left
    page =  (params[:page] || 1)
    sort_column = sort_column_sym(params[:sort_column], :all_left_month_salary_default)
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = MonthSalaryReport.users_by_left
    query =  MonthSalaryReportPolicy::Scope.new(current_user, query).resolve(:left, nil)
    query = search_query(SalaryValue.where(id: query.ids), sort_column, sort_direction, :left)
    {page: page ,query: query}
  end

  def search_show
    page =  (params[:page] || 1)
    sort_column = sort_column_sym(params[:sort_column], :'1')
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = @month_salary_report.users_year_month
    query =  MonthSalaryReportPolicy::Scope.new(current_user, query).resolve(:on_duty, @month_salary_report.year_month)
    query =  search_query(SalaryValue.where(id: query.ids), sort_column, sort_direction, :on_duty)
    {page: page ,query: query}
  end

  def search_index
    page =  (params[:page] || 1)
    sort_column = sort_column_sym(params[:sort_column], :all_month_salary_default)
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = MonthSalaryReport.users_by_all
    query =  MonthSalaryReportPolicy::Scope.new(current_user, query).resolve(:index, nil)
    query = search_query(SalaryValue.where(id: query.ids), sort_column, sort_direction, :index)
    {page: page ,query: query}
  end

  def set_month_salary_report_left
    @month_salary_report = MonthSalaryReport.find_by(year_month: Time.zone.parse(params[:year_month]), salary_type: :left)
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_month_salary_report
    @month_salary_report = MonthSalaryReport.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def month_salary_report_params
    params.fetch(:month_salary_report, {})
  end

  def year_month
    Time.zone.parse(params[:year_month]).beginning_of_month
  end

  def set_user
    @user = User.find(params[:user_id])
  end
  def search_query(salary_value_query, sort_column, sort_direction, action)
    year_month  = @month_salary_report.year_month rescue nil
    {
      :by_empoid => [params[:'1'], action, year_month],
      :by_name => [params[:'2'], action, year_month],
      :by_department_id => [params[:'7'], action, year_month],
      :by_position_id => [params[:'8'], action, year_month],
      :by_location_id => [params[:'6'], action, year_month],
      :by_company_name => [params[:'5'], action, year_month],
      :by_grade => [params[:'9'], action, year_month],
      :by_year => [params[:'3']],
      :by_month => [params[:'4']],
      :by_status => [params[:'0']]

    }.each do |key, value|
      salary_value_query =  salary_value_query.join_user.send(key, *value)
      salary_value_query = SalaryValue.where(id: salary_value_query.ids).join_user
    end



    SalaryValue.where(id: salary_value_query.ids).join_user
      .by_order(sort_column, sort_direction, action, year_month)
  end
end
