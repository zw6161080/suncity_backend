class EntryWaitedRecordsController < ApplicationController
  include ActionController::MimeResponds
  include SortParamsHelper

  def index
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = search_query
    query = order_by(query, sort_column, sort_direction)
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
        render json: query, root: 'data', meta: meta, each_serializer: EntryWaitedRecordSerializer, include: '**'
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        file_name = send_export(query)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_now(
            query_ids: query.ids,
            query_model: 'applicant_profiles',
            statement_columns: CareerRecord.statement_columns_base('entry_waited_records'),
            options: JSON.parse(CareerRecord.options('entry_waited_records').to_json), my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def field_options
    department = Department.where('departments.status' => 0).where('id != 1')
    position = Position.where('id != 1')
    render json: { position: position, department: department }
  end

  private
  def send_export(query)
    entry_waited_record_export_num = Rails.cache.fetch('entry_waited_record_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ entry_waited_record_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('entry_waited_record_export_number_tag', entry_waited_record_export_num + 1)
    "#{I18n.t(self.controller_name + '.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end

  def order_by(query, sort_column, sort_direction)
    case sort_column
      when :empoid then
        query = query.order("applicant_profiles.empoid_for_create_profile #{sort_direction}")
      when :name then
        query = query.select("*, applicant_profiles.data -> 'personal_information' -> 'field_values' -> 'chinese_name' as name").order("name #{sort_direction}")
      when :department then
        query = query.select('*, applicant_positions.department_id as department').order("department #{sort_direction}")
      when :position then
        query = query.select('*, applicant_positions.position_id as position').order("position #{sort_direction}")
      when :date_of_employment then
        query = query.select("*, applicant_profiles.data -> 'position_to_apply' -> 'field_values' -> 'available_on' as date_of_employment").order("date_of_employment #{sort_direction}")
      else
        query = query
    end
    query
  end

  def search_query
    query = ApplicantProfile
                .joins(:applicant_positions)
                .where(:applicant_positions => { status: 'entry_needed' })
                .distinct(:id)
    if params[:name]
      query = query.where('chinese_name = :name OR english_name = :name', name: params[:name])
    end
    if params[:department]
      query = query.where(:applicant_positions => { department_id: params[:department] })
    end
    if params[:position]
      query = query.where(:applicant_positions => { position_id: params[:position] })
    end
    if params[:query_date]
      from = Time.zone.parse(params[:query_date][:begin]).beginning_of_day rescue nil
      to = Time.zone.parse(params[:query_date][:end]).end_of_day rescue nil
      if from && to
        query = query.where("applicant_profiles.data #>> '{position_to_apply, field_values, available_on}' >= :from", from: from)
                    .where("applicant_profiles.data #>> '{position_to_apply, field_values, available_on}' <= :to", to: to)
      elsif from
        query = query.where("applicant_profiles.data #>> '{position_to_apply, field_values, available_on}' >= :from", from: from)
      elsif to
        query = query.where("applicant_profiles.data #>> '{position_to_apply, field_values, available_on}' <= :to", to: to)
      end
    end
    query
  end
end
