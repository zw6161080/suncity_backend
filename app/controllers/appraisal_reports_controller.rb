class AppraisalReportsController < ApplicationController
  include StatementBaseActions

  before_action :set_appraisal_report, only: [:show, :update, :destroy]
  before_action :set_appraisal, only: [:show, :side_bar_options, :index, :index_by_department, :index_by_mine]

  def after_query(query = search_query)
    sort_column = sort_column_sym(params[:sort_column], :empoid)
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = query.order_by(sort_column , sort_direction)
    query = query.where(appraisal_id: params[:appraisal_id])
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
        render json: query, root: 'data', meta: meta, include: '**'
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        appraisal_report_number_tag = Rails.cache.fetch('appraisal_report_number_tag', :expires_in => 24.hours) do
          1
        end
        Rails.cache.write('appraisal_report_number_tag', appraisal_report_number_tag + 1)
        export_id = ("0000"+ appraisal_report_number_tag.to_s).match(/\d{4}$/)[0]
        file_name = "#{@appraisal.appraisal_name}#{@appraisal.date_begin.strftime('%Y/%m/%d')}~#{@appraisal.date_end.strftime('%Y/%m/%d')}_#{I18n.t(self.controller_name+'.file_name')}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: controller_name, statement_columns: model.statement_columns_base("appraisal_reports"), options: JSON.parse(model.options.to_json), my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def index
    # authorize AppraisalReport
    query = @appraisal.appraisal_reports
    query = search_query(query)
    after_query(query)
  end

  def index_by_department
    query = @appraisal.appraisal_reports.joins(:appraisal_participator => :user).where(:users => { department_id: current_user.department_id })
    query = search_query(query)
    after_query(query)
  end

  def index_by_mine
    query = @appraisal.appraisal_reports.joins(:appraisal_participator).where(:appraisal_participators => { user_id: current_user.id })
    query = search_query(query)
    after_query(query)
  end

  # GET /appraisal_reports/1
  def show
    # authorize AppraisalReport
    render json: @appraisal_report, include: '**'
  end

  def side_bar_options
    # authorize AppraisalReport
    query = @appraisal.appraisal_reports.joins(:appraisal_participator => :user)
    data = [
      {
        key: 'all',
        chinese_name: '全部',
        english_name: 'All',
        simple_chinese_name: '全部',
        count: query.count
      }
    ]

    # locations = Location.where(id: query.select('users.location_id'))
    Location.where.not(id: 32).each do |location|
      departments = location.departments.where.not(id: 1).map do |department|
        department.as_json.merge(member_count: query.where(:users => { location_id: location.id, department_id: department.id }).count)
      end
      data.push(location.as_json.merge(departments: departments, member_count: query.where(:users => { location_id: location.id}).count))
    end
    render json: { side_bar_options: data }
  end

  def record_options
    authorize Appraisal
    render json: AppraisalEmployeeSetting.field_options , root: 'data'
  end

  def all_appraisal_report_record_columns
    authorize Appraisal
    render json: model.statement_columns('appraisal_records').concat(get_dynamic_columns)
  end

  def all_appraisal_report_record
    sort_column = sort_column_sym(params[:sort_column], :created_at)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = AppraisalEmployeeSetting.all
    respond_to do |format|
      format.json {
        query = AppraisalEmployeeSetting.query(
            queries: query_params,
            sort_column: sort_column,
            sort_direction: sort_direction,
            page: params.fetch(:page, 1),
            per_page: 20,
            path_param: params[:path_param]
        )
        # query = query.joins(:appraisal_participator => :appraisal)
        #             .where(:appraisals => { appraisal_status: %w(completed performance_interview)})
        meta = {
            total_count: query.total_count,
            current_page: query.current_page,
            total_pages: query.total_pages,
            sort_column: sort_column.to_s,
            sort_direction: sort_direction.to_s,
        }
        render json: query, root: 'data', meta: meta, each_serializer: AppraisalRecordSerializer, include: '**'
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        file_name = send_export(query)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: 'AppraisalEmployeeSetting', statement_columns: model.statement_columns('appraisal_records').concat(get_dynamic_columns), options: JSON.parse(model.options('appraisal_records').to_json), serializer: 'AppraisalRecordSerializer', my_attachment: my_attachment, add_title: 'add_appraisal_report_title')
        render json: my_attachment
      }

    end
  end

  private

  def get_dynamic_columns
    columns = []
    Appraisal.where(appraisal_status: %w(completed performance_interview)).each do |appraisal|
      name = "#{appraisal.appraisal_name} (#{appraisal.date_begin.strftime('%Y/%m/%d') rescue nil} ~ #{appraisal.date_end.strftime('%Y/%m/%d') rescue nil})"
      column = {
        'chinese_name' => name,
        'english_name' => name,
        'simple_chinese_name' => name,
        key: "appraisal_#{appraisal.id}"
      }
      column['children'] = get_sub_columns(appraisal.id)
      columns << column
    end
    columns
  end

  def get_sub_columns(appraisal_id = nil)
    sub_columns_keys = Config.get('statements').fetch('appraisal_records', { 'sub_columns' => [] })['sub_columns']
    scope = [:sub_columns, :appraisal_records]
    sub_columns_keys.map do |sub_column|
      children_column_names = {
        'chinese_name' => I18n.t(sub_column['key'], locale: 'zh-HK', scope: scope, default: ''),
        'english_name' => I18n.t(sub_column['key'], locale: 'en', scope: scope, default: ''),
        'simple_chinese_name' => I18n.t(sub_column['key'], locale: 'zh-CN', scope: scope, default: '')
      }
      data_index = "appraisal_reports.appraisal_#{appraisal_id}.#{sub_column['key']}"
      if %w(superior_count colleague_count subordinate_count assessor_count).include?(sub_column['key'])
        data_index = "appraisal_reports.appraisal_#{appraisal_id}.report_detail.#{sub_column['key']}"
      end
      sub_column['data_index'] = data_index
      key = "appraisal_#{appraisal_id}_#{sub_column['key']}"
      sub_column.merge(children_column_names).merge(key: key)
    end
  end

  def send_json(query, meta)
    render json: query, meta: meta, each_serializer: AppraisalReportForDetailSerializer, include: '**'
  end

  def filter(query)
    query.where(appraisal_id: params[:appraisal_id])
  end

  def set_appraisal
    @appraisal = Appraisal.find(params['appraisal_id'])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_appraisal_report
    @appraisal_report = AppraisalReport.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def appraisal_report_params
    params.fetch(:appraisal_report, {})
  end

  def search_query(query = AppraisalReport.all)
    query = query.joins({:appraisal_participator => {:user => :profile} }, :appraisal)
    %w(empoid employee_id name location department position grade division_of_job date_of_employment count_of_assessor).each do  |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    query
  end

end
