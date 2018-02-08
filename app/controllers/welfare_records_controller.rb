class WelfareRecordsController < ApplicationController
  include WelfareRecordHelper
  include MineCheckHelper
  include ActionController::MimeResponds
  include SortParamsHelper
  before_action :set_welfare_record, only: [:show, :update, :destroy]
  before_action :set_user, only: [:index_by_user, :current_welfare_record_by_user, :current_welfare_record_and_coming_welfare_record]
  before_action :myself?, only:[:index_by_user, :current_welfare_record_by_user], if: :entry_from_mine?

  def columns
    render json: WelfareRecord.statement_columns
  end

  def options
    render json: {
        company_name: Config.get_all_option_from_selects(:company_name),
        department: Department.where.not(id: 1),
        location: Location.where.not(id: [32])
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
        render json: query, meta: meta, root: 'data', each_serializer: WelfareRecordReportSerializer, include: '**'
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        file_name = send_export(query)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(
            query_ids: query.ids,
            query_model: controller_name,
            statement_columns: WelfareRecord.statement_columns_base,
            options: JSON.parse(WelfareRecord.options.to_json),
            my_attachment: my_attachment
        )
        render json: my_attachment
      }
    end
  end

  # DELETE /welfare_records/1
  def destroy
    @welfare_record.destroy unless @welfare_record.is_being_valid?
  end

  def update
    authorize WelfareRecord
    if @welfare_record.update(update_params)
      render json: @welfare_record
    else
      render json: @welfare_record.errors, status: :unprocessable_entity
    end
  end

  def create
    authorize WelfareRecord
    wr = WelfareRecord.new(create_params)
    if wr.save
      render json: wr.reload
    else
      render json: wr.errors
    end
  end

  def welfare_information_options
    render json: WelfareRecord.welfare_information_options
  end

  def index_by_user
    authorize WelfareRecord unless entry_from_mine?
    render json: WelfareRecord.where(user: user_id_params).order(welfare_begin: :desc)
  end

  def current_welfare_record_by_user
    authorize WelfareRecord unless entry_from_mine?
    render json: WelfareRecord.where(user: user_id_params).by_current_valid_record_for_welfare_info.first
  end
  #职位变动中调用
  def current_welfare_record_by_user_from_job_transfer
    render json: WelfareRecord.where(user: user_id_params).by_current_valid_record.first
  end

  #员工档案详情页使用
  #当期生效的信息
  #即将生效的信息
  def current_welfare_record_and_coming_welfare_record
    current_welfare_record = ActiveModelSerializers::SerializableResource.new(WelfareRecord.where(user: user_id_params).by_current_valid_record_for_welfare_info.first) rescue nil
    coming_welfare_record = ActiveModelSerializers::SerializableResource.new(WelfareRecord.where(user: user_id_params).where("welfare_begin > :today", today: Time.zone.now.beginning_of_day).order(welfare_begin: :asc).first) rescue nil
    render json: {
      current_welfare_record: current_welfare_record,
      coming_welfare_record: coming_welfare_record
    }
  end

  private
  def query_latest(query)
    users = User.where(id: query.pluck(:user_id)).includes(:welfare_records)
    match_records = []
    users.each do |user|
      match_records << user.welfare_records.order('welfare_begin desc').first
    end
    query.where(id: match_records.pluck(:id))
  end

  def send_export(query)
    welfare_record_export_num = Rails.cache.fetch('welfare_record_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ welfare_record_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('welfare_record_export_number_tag', welfare_record_export_num + 1)
    "#{I18n.t(self.controller_name + '.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end

  def set_user
    @user = User.find(params[:user_id])
  end
  def create_params
    params.require(welfare_required_array)
    params.permit(welfare_required_array + welfare_permitted_array)
  end


  def update_params
    params.permit(welfare_required_array + welfare_permitted_array)
  end

  def user_id_params
    params.require(:user_id)
  end

  def set_welfare_record
    @welfare_record = WelfareRecord.find(params[:id])
  end

  def search_query
    query = WelfareRecord.left_outer_joins(:user => :profile )
    %w(company_name location department query_date).each do |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    query
  end
end
