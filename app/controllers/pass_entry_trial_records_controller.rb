class PassEntryTrialRecordsController < ApplicationController
  include SalaryRecordHelper
  include MineCheckHelper
  include ActionController::MimeResponds
  include SortParamsHelper

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
            sort_direction: sort_direction.to_s
        }
        render json: query, meta: meta, root: 'data', each_serializer: PassEntryTrialRecordsSerializer, include: '**'
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        file_name = send_export
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(
            query_ids: query.ids,
            query_model: 'career_records',
            statement_columns: CareerRecord.statement_columns_base('pass_entry_trial_records'),
            options: JSON.parse(CareerRecord.options('pass_entry_trial_records').to_json),
            my_attachment: my_attachment
        )
        render json: my_attachment
      }
    end
  end

  def columns
    render json: CareerRecord.statement_columns('pass_entry_trial_records')
  end

  def options
    render json: {
        company_name: Config.get_all_option_from_selects(:company_name),
        department: Department.where.not(id: 1),
        location: Location.where.not(id: [32])
    }
  end

  private
  def send_export
    pass_entry_trial_records_export_num = Rails.cache.fetch('pass_entry_trial_records_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ pass_entry_trial_records_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('pass_entry_trial_records_export_number_tag', pass_entry_trial_records_export_num + 1)
    "#{I18n.t(self.controller_name + '.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end

  def search_query
    query = CareerRecord.joins(:user).where(deployment_type: 'entry')
    %w(company_name location department trial_period_expiration_date).each do |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    query
  end
end
