class SalaryRecordsController < ApplicationController
  include SalaryRecordHelper
  include MineCheckHelper
  include ActionController::MimeResponds
  include SortParamsHelper

  before_action :set_salary_record, only: [:show, :update, :destroy]
  before_action :set_user, only: [:index_by_user, :current_salary_record_by_user]
  before_action :myself?, only:[:index_by_user, :current_salary_record_by_user], if: :entry_from_mine?

  def columns
    render json: SalaryRecord.statement_columns
  end

  def options
    render json: {
        company_name: Config.get_all_option_from_selects(:company_name),
        department: Department.where.not(id: 1),
        location: Location.all
    }
  end

  def index
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
    query = query_latest(query) if params[:latest]
    query = query.order_by(sort_column , sort_direction)
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
        render json: query, meta: meta, root: 'data', each_serializer: SalaryRecordReportSerializer, include: '**'
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        file_name = send_export(query)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: controller_name, statement_columns: SalaryRecord.statement_columns_base, options: JSON.parse(SalaryRecord.options.to_json), my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  # GET /salary_records/1
  def show

    authorize SalaryRecord

    render json: @salary_record,  adapter: :attributes
  end

  # POST /salary_records
  def create
    authorize SalaryRecord
    @salary_record = SalaryRecord.new(salary_record_params)
    if @salary_record.save
      TimelineRecordService.update_salary_record_valid_date(@salary_record.user)
      render json: @salary_record, status: :created, location: @salary_record, adapter: :attributes
    else
      render json: @salary_record.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /salary_records/1
  def update

    authorize SalaryRecord
    if @salary_record.update(update_params)
      TimelineRecordService.update_salary_record_valid_date(@salary_record.user)
      render json: @salary_record, adapter: :attributes
    else
      render json: @salary_record.errors, status: :unprocessable_entity
    end
  end

  # DELETE /salary_records/1
  def destroy
    authorize SalaryRecord
    @salary_record.destroy unless @salary_record.is_being_valid?
    TimelineRecordService.update_salary_record_valid_date(@salary_record.user)
    render json: { result: 'success' }
  end

  def salary_information_options
    render json: SalaryRecord.salary_information_options
  end

  def index_by_user
    if entry_from_mine?
      query = SalaryRecord
    else
      authorize SalaryRecord
      query = policy_scope(SalaryRecord)
    end
    render json: query.where(user_id: user_id_params).order(salary_begin: :desc), adapter: :attributes, each_serializer: SalaryRecordForNumberFormatSerializer
  end

  def current_salary_record_by_user

    if entry_from_mine?
      query = SalaryRecord
    else
      authorize SalaryRecord unless entry_from_mine?
      query = policy_scope(SalaryRecord)
    end
    render json: query.where(user_id: user_id_params).by_current_valid_record_for_salary_info.first, adapter: :attributes, serializer: SalaryRecordForNumberFormatSerializer
  end

  #职位变动中调用
  def current_salary_record_by_user_from_job_transfer
    render json: SalaryRecord.where(user: user_id_params).by_current_valid_record.first
  end

  #员工档案详情页使用
  #当期生效的信息
  #即将生效的信息
  def current_salary_record_and_coming_salary_record
    current_salary_record = ActiveModelSerializers::SerializableResource.new(SalaryRecord.where(user: user_id_params).by_current_valid_record_for_salary_info.first) rescue nil
    coming_salary_record = ActiveModelSerializers::SerializableResource.new(SalaryRecord.where(user: user_id_params).where("salary_begin > :today", today: Time.zone.now.beginning_of_day).order(salary_begin: :asc).first) rescue nil
    render json: {
      current_salary_record: current_salary_record,
      coming_salary_record: coming_salary_record
    }
  end

  private
  def send_export(query)
    salary_record_export_num = Rails.cache.fetch('salary_record_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ salary_record_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('salary_record_export_number_tag', salary_record_export_num + 1)
    "#{I18n.t(self.controller_name + '.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end

  def set_user
    @user = User.find(params[:user_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_salary_record
    @salary_record = SalaryRecord.find(params[:id])
  end

  def query_latest(query)
    users = User.where(id: query.pluck(:user_id)).includes(:salary_records)
    match_records = []
    users.each do |user|
      match_records << user.salary_records.order('salary_begin desc').first
    end
    query.where(id: match_records.pluck(:id))
  end

  def search_query
    query = SalaryRecord.left_outer_joins(:user => :profile)
    %w(company_name location department position change_date).each do |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    query
  end
end
