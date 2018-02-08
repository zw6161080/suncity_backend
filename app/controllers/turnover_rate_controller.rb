class TurnoverRateController < ApplicationController
  include SalaryRecordHelper
  include MineCheckHelper
  include ActionController::MimeResponds
  include SortParamsHelper

  def index
    # user_query = User.all
    # user_query = user_query.where(location_id: query_params[:location_id]) if query_params[:location_id]
    # user_query = user_query.where(department_id: query_params[:department_id]) if query_params[:department_id]
    # user_query = user_query.where(company_name: query_params[:company_name]) if query_params[:company_name]
    # resignation_records_query = ResignationRecord.all
    # resignation_records_query = resignation_records_query.where(resigned_reason: query_params[:resigned_reason]) if query_params[:resigned_reason]
    result = TurnoverRateService.calculate_turnover_rate(query_params)
    render json: { data: result, meta: { total_count: result['all']['both']['leave'] } }
  end

  def columns
    statement_field_columns = Config.get('statements').fetch(('turnover_rate'), { 'columns' => [] })['columns']
    columns_array = statement_field_columns.map do |column|
      key = column['key']
      column['data_index'] = column['data_index'].presence || key
      scope = [:statement_columns, :turnover_rate]
      column_names = {
          'chinese_name' => I18n.t(key, locale: 'zh-HK', scope: scope, default: ''),
          'english_name' => I18n.t(key, locale: 'en', scope: scope, default: ''),
          'simple_chinese_name' => I18n.t(key, locale: 'zh-CN', scope: scope, default: '')
      }
      column['children'] = get_sub_columns(key) unless key == 'years'
      column.merge(column_names)
    end
    client_attributes = Config.get('report_column_client_attributes').fetch('attributes', [])
    columns_array = columns_array.as_json.map { |col| col.slice(*client_attributes) }
    render json: columns_array
  end

  def options
    render json: {
        resigned_reason: Config.get_all_option_from_selects(:resigned_reason),
        company_name: Config.get_all_option_from_selects(:company_name),
        department_id: Department.where.not(id: 1),
        location_id: Location.all
    }
  end

  private
  def query_params
    params.require(:resigned_reason)
    params.require(:date_begin)
    params.require(:date_end)
    params.permit(:date_begin, :date_end, :company_name => [], :location_id => [], :department_id => [], :resigned_reason => [])
  end

  def get_sub_columns(type)
    sub_columns_keys = Config.get('statements').fetch('turnover_rate', { 'sub_columns' => [] })['sub_columns']
    scope = [:sub_columns, :turnover_rate]
    sub_columns_keys.map do |sub_column|
      child_column_name = {
          'chinese_name' => I18n.t(sub_column['key'], locale: 'zh-HK', scope: scope, default: ''),
          'english_name' => I18n.t(sub_column['key'], locale: 'en', scope: scope, default: ''),
          'simple_chinese_name' => I18n.t(sub_column['key'], locale: 'zh-CN', scope: scope, default: '')
      }
      data_index = "#{type}.#{sub_column['key']}"
      sub_column['data_index'] = data_index
      key = "#{type}_#{sub_column['key']}"
      sub_column.merge(child_column_name).merge(key: key)
    end
  end
end
