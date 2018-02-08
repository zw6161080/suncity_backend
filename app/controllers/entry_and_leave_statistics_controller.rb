class EntryAndLeaveStatisticsController < ApplicationController
  include SalaryRecordHelper
  include MineCheckHelper
  include ActionController::MimeResponds
  include SortParamsHelper

  def index
    data = EntryAndLeaveStatisticsService.calculate_statistics(query_params)
    render json: { data: data, meta: { total_count: data.count } }
  end

  def options
    render json: {
        company_name: Config.get_all_option_from_selects(:company_name),
        department_id: Department.where.not(id: 1),
        location_id: Location.all
    }
  end

  def columns
    statement_field_columns = Config.get('statements').fetch(('entry_and_leave_statistics'), { 'columns' => [] })['columns']
    columns_array = statement_field_columns.map do |column|
      key = column['key']
      column['data_index'] = column['data_index'].presence || key
      scope = [:statement_columns, :entry_and_leave_statistics]
      column_names = {
          'chinese_name' => I18n.t(key, locale: 'zh-HK', scope: scope, default: ''),
          'english_name' => I18n.t(key, locale: 'en', scope: scope, default: ''),
          'simple_chinese_name' => I18n.t(key, locale: 'zh-CN', scope: scope, default: '')
      }
      column.merge(column_names)
    end
    client_attributes = Config.get('report_column_client_attributes').fetch('attributes', [])
    columns_array = columns_array.as_json.map { |col| col.slice(*client_attributes) }
    render json: columns_array
  end

  private
  def query_params
    params.require(:date_begin)
    params.require(:date_end)
    params.permit( :date_begin, :date_end, :company_name => [], :location_id => [], :department_id => [])
  end
end
