class ForceHolidayWorkingRecordsController < ApplicationController
  include ActionController::MimeResponds
  include SortParamsHelper
  include StatementBaseActions

  def index
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
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
        render json: query, meta: meta, root: 'data', include: '**'
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        file_name = send_export(query)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(
            query_ids: query.ids,
            query_model: controller_name,
            statement_columns: ForceHolidayWorkingRecord.statement_columns_base,
            options: JSON.parse(ForceHolidayWorkingRecord.options.to_json),
            my_attachment: my_attachment
        )
        render json: my_attachment
      }
    end
  end

  private
  def search_query
    query = ForceHolidayWorkingRecord.joins(:holiday_setting, :user => :profile)
    %w(department position user_id force_holiday_working_date empoid name date_of_employment).each do |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    query
  end

  def send_export(query)
    force_holiday_working_record_export_num = Rails.cache.fetch('force_holiday_working_record_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ force_holiday_working_record_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('force_holiday_working_record_export_number_tag', force_holiday_working_record_export_num + 1)
    "#{I18n.t(self.controller_name + '.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end
end
