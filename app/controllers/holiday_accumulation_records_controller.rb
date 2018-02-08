class HolidayAccumulationRecordsController < ApplicationController
  include ActionController::MimeResponds
  include SortParamsHelper

  def options
    holiday_type = HolidayRecord.fixed_holiday_type_table + HolidayRecord.reserved_holiday_type_table
    positions = Position.where(id: User.all.select(:position_id))
    departments = Department.where(id: User.all.select(:department_id))
    render json: {
        holiday_type: holiday_type,
        position_id: positions,
        department_id: departments
    }
  end

  def index
    sort_column = sort_column_sym(params[:sort_column], :empoid)
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = search_query.order_by(sort_column , sort_direction)
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
        render json: query, root: 'data', meta: meta, each_serializer: HolidayAccumulationRecordSerializer, query_params: query_params, include: '**'
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        file_name = send_export(query)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(
            query_ids: query.ids,
            query_model: controller_name,
            statement_columns: StatementAble.statement_columns_base('holiday_accumulation_records'),
            options: JSON.parse(StatementAble.options.to_json),
            my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  private
  def send_export(query)
    holiday_accumulation_record_export_num = Rails.cache.fetch('holiday_accumulation_record_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ holiday_accumulation_record_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('holiday_accumulation_record_export_number_tag', holiday_accumulation_record_export_num + 1)
    "#{I18n.t(self.controller_name + '.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end

  def query_params
    params.require(:query_date)
    params.require(:holiday_type)
    params.require(:apply_type)
    params.permit(:query_date, :holiday_type, :apply_type)
  end

  def search_query
    query = User.joins(:profile)
    %w(empoid name position_id department_id date_of_employment).each do  |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    # query = query.send("by_date_of_employment", params[:date_of_employment][:begin], params[:date_of_employment][:end]) if params[:date_of_employment]
    query
  end
end
