class SpecialScheduleRemarksController < ApplicationController
  include ActionController::MimeResponds
  include SortParamsHelper

  before_action :set_special_schedule_remark, only: [:update, :destroy]

  def columns
    render json: SpecialScheduleRemark.statement_columns
  end

  def options
    render json: {
        department: Department.where(id: SpecialScheduleRemark.joins(:user).select('users.department_id')),
        position: Position.where(id: SpecialScheduleRemark.joins(:user).select('users.position_id'))
    }
  end

  def index_by_user
    if params[:user_id]
      render json: User.find(params[:user_id]).special_schedule_remarks.order(date_begin: :desc), root: 'data'
      return
    end
    render json: { err_message: 'user_id is undefined' }
  end

  # GET /special_schedule_remarks
  def index
    sort_column = sort_column_sym(params[:sort_column], :user_id)
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
        render json: query, root: 'data', meta: meta, include: '**'
      }
      format.xlsx {
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        file_name = send_export(query)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(
            query_ids: query.ids,
            query_model: controller_name,
            statement_columns: SpecialScheduleRemark.statement_columns_base,
            options: JSON.parse(SpecialScheduleRemark.options.to_json),
            my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  # POST /special_schedule_remarks
  def create
    @special_schedule_remark = SpecialScheduleRemark.new(special_schedule_remark_params)

    if @special_schedule_remark.save
      render json: @special_schedule_remark, status: :created, location: @special_schedule_remark
    else
      render json: @special_schedule_remark.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /special_schedule_remarks/1
  def update
    if @special_schedule_remark.update(special_schedule_remark_params)
      render json: @special_schedule_remark
    else
      render json: @special_schedule_remark.errors, status: :unprocessable_entity
    end
  end

  # DELETE /special_schedule_remarks/1
  def destroy
    render json: @special_schedule_remark.destroy
  end

  private
  def send_export(query)
    special_schedule_remark_export_num = Rails.cache.fetch('special_schedule_remark_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ special_schedule_remark_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('special_schedule_remark_export_number_tag', special_schedule_remark_export_num + 1)
    "#{I18n.t(self.controller_name + '.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end
  def set_special_schedule_remark
    @special_schedule_remark = SpecialScheduleRemark.find(params[:id])
  end

  def special_schedule_remark_params
    params.require(:user_id)
    params.require(:content)
    params.require(:date_end)
    params.require(:date_begin)
    params.permit(:user_id, :content, :date_begin, :date_end)
  end

  def search_query
    query = SpecialScheduleRemark.joins(:user => :profile)
    %w(user_ids empoid name department position date_of_employment date_begin date_end query_date).each do  |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    query
  end

end
