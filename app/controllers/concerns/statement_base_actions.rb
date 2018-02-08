module StatementBaseActions
  include ActionController::MimeResponds
  include GenerateXlsxHelper
  include SortParamsHelper

  def index
    sort_column = sort_column_sym(params[:sort_column], :created_at)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    respond_to do |format|
      format.json {
        query = model.query(
        queries: query_params,
          sort_column: sort_column,
          sort_direction: sort_direction,
          page: params.fetch(:page, 1),
          per_page: 20,
          path_param: params[:path_param]
        )
        query = filter(query)
        meta = {
          total_count: query.total_count,
          current_page: query.current_page,
          total_pages: query.total_pages,
          sort_column: sort_column.to_s,
          sort_direction: sort_direction.to_s,
        }
        send_json(query, meta)
      }

      format.xlsx {
        query = model.query(
          queries: query_params,
          sort_column: sort_column,
          sort_direction: sort_direction,
          path_param: params[:path_param]
        )
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        case model.name
        when 'GoodsSigning'
          good_singing_export_num = Rails.cache.fetch('good_singing_export_number_tag', :expires_in => 24.hours) do
            1
          end
          export_id = ( "0000"+good_singing_export_num.to_s).match(/\d{4}$/)[0]
          Rails.cache.write('good_singing_export_number_tag', good_singing_export_num + 1)
          my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{I18n.t(self.controller_name+'.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
          GenerateGoodsSigningTableJob.perform_later(query_ids:  query.ids, query_model: self.controller_name, statement_columns: model.statement_columns_base, my_attachment: my_attachment)
          render json: my_attachment
        when 'TrainingAbsentee'
          training_absentee_export_num = Rails.cache.fetch('training_absentee_export_number_tag', :expires_in => 24.hours) do
            1
          end
          export_id = ( "0000"+training_absentee_export_num.to_s).match(/\d{4}$/)[0]
          Rails.cache.write('training_absentee_export_number_tag', training_absentee_export_num + 1)
          my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{I18n.t(self.controller_name+'.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
          GenerateGoodsSigningTableJob.perform_later(query_ids:  query.ids, query_model: self.controller_name, statement_columns: model.statement_columns_base, my_attachment: my_attachment)
          render json: my_attachment
        else
          file_name = send_export(query)
          my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
          GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: controller_name, statement_columns: model.statement_columns_base, options: JSON.parse(model.options.to_json), my_attachment: my_attachment, add_title: add_title)
          render json: my_attachment
        end
      }
    end

  end

  def add_title

  end

  def send_export(query)
    "#{I18n.t self.controller_name + '.file_name'}#{Time.zone.now.strftime('%Y%m%d-%H%M%s')}.xlsx"
  end

  def send_json(query, meta, serializer = nil)
    render json: query, status: 200, root: 'data', meta: meta, include: '**'
  end

  def columns
    render json: model.statement_columns
  end

  def options
    render json: model.options
  end

  def filter(query)
    query
  end

  private

  def query_params(special_table_name = nil, params_id = nil)
    column_params = model(special_table_name).query_columns(special_table_name, params_id).as_json.map do |col|
      if col['search_type'].in? %w(year_range month_range day_range number_range date decimal_range)
        { col['key'] => [:begin, :end] }
      elsif col['search_type'] == 'screen'
        { col['key'] => [] }
      else
        col['key']
      end
    end
    params.permit(*column_params)
  end

  def model(special_table_name = nil)
    (special_table_name || controller_name).classify.constantize
  end
end