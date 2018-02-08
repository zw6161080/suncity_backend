class PerformanceInterviewsController < ApplicationController
  include StatementBaseActions

  before_action :set_performance_interview, only: [:show, :update, :destroy, :completed]
  before_action :set_appraisal, except: [:record_index, :record_columns, :record_options]
  before_action :authorize_action, only: [:columns]

  def authorize_action
    authorize Appraisal
  end

  def after_query(query = search_query)
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :asc)
    query = query.order_by(sort_column , sort_direction)
    query = query.where(appraisal_id: params[:appraisal_id])
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
        performance_interview_number_tag = Rails.cache.fetch('performance_interview_number_tag', :expires_in => 24.hours) do
          1
        end
        Rails.cache.write('performance_interview_number_tag', performance_interview_number_tag + 1)
        export_id = ("0000"+ performance_interview_number_tag.to_s).match(/\d{4}$/)[0]
        file_name = "#{@appraisal.appraisal_name}#{@appraisal.date_begin.strftime('%Y/%m/%d')}~#{@appraisal.date_end.strftime('%Y/%m/%d')}_#{I18n.t(self.controller_name+'.file_name')}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: controller_name, statement_columns: model.statement_columns_base("performance_interviews"), options: JSON.parse(model.options.to_json), my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def index
    authorize Appraisal
    query = search_query(@appraisal.performance_interviews)
    after_query(query)
  end

  def index_by_department
    query = PerformanceInterview.where(id: @appraisal.performance_interviews.joins(:appraisal_participator => :user).where(:users => { department_id: current_user.department_id }).pluck(:id))
    query = search_query(query)
    after_query(query)
  end

  def index_by_mine
    query = PerformanceInterview.where(id: @appraisal.performance_interviews.joins(:appraisal_participator).where(:appraisal_participators => { user_id: current_user.id }).pluck(:id))
    query = search_query(query)
    after_query(query)
  end

  def record_index
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
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
        performance_interview_number_tag = Rails.cache.fetch('performance_interview_number_tag', :expires_in => 24.hours) do
          1
        end
        Rails.cache.write('performance_interview_number_tag', performance_interview_number_tag + 1)
        export_id = ("0000"+ performance_interview_number_tag.to_s).match(/\d{4}$/)[0]
        file_name = "#{I18n.t('performance_interviews_records'+'.file_name')}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(query_ids: query.ids, query_model: controller_name, statement_columns: model.statement_columns_base("performance_interviews_records"), options: JSON.parse(model.options.to_json), my_attachment: my_attachment)
        render json: my_attachment
      }
    end
  end

  def record_columns
    render json: model.statement_columns('performance_interviews_records')
  end

  def options
    authorize Appraisal
    render json: PerformanceInterview.options('performance_interviews')
  end

  def record_options
    render json: PerformanceInterview.options('performance_interviews_records')
  end

  def side_bar_options
    authorize Appraisal
    query = @appraisal.performance_interviews.joins(:appraisal_participator => :user)
    data = [
      {
        key: 'all',
        chinese_name: '全部',
        english_name: 'All',
        simple_chinese_name: '全部',
        count: query.count
      }
    ]
    Location.where.not(id: 32).each do |location|
      departments = location.departments.where.not(id: 1).map do |department|
        department.as_json.merge(member_count: query.where(:users => { location_id: location.id, department_id: department.id }).count)
      end
      data.push(location.as_json.merge(departments: departments, member_count: query.where(:users => { location_id: location.id }).count))
    end
    render json: { side_bar_options: data }
  end

  # PATCH/PUT /performance_interviews/1
  def update
    authorize Appraisal
    raise LogicError, {id: 422, message: '參數不完整'}.to_json unless params[:performance_moderator_id] && params[:interview_time_begin] && params[:interview_time_end] && params[:interview_date]
    raise LogicError, {id: 422, message: '面談主持人不能是自己'}.to_json if params[:performance_moderator_id] == @performance_interview.appraisal_participator.user_id
    raise LogicError, {id: 422, message: '時間不符合規則'}.to_json if params[:interview_time_begin] > params[:interview_time_end]
    @performance_interview.update(
        performance_interview_params.merge(operator_id: current_user.id, operator_at: Time.zone.now)
    )
    if params['attend_attachments']
      @performance_interview.attachment_items.destroy_all
      params['attend_attachments'].each do |attachment_params|
        @performance_interview
            .attachment_items
            .create(attachment_params.permit(:file_name, :attachment_id).merge(creator_id: current_user.id))
      end
    end
    render json: @performance_interview, include: '**'
  end

  def completed
    authorize Appraisal
    if @performance_interview.performance_interview_status == 'completed'
      render json: { complete: false }, root: 'data'
      return
    end
    raise LogicError, {id: 422, message: '參數不完整'}.to_json unless params[:performance_moderator_id] && params[:interview_time_begin] && params[:interview_time_end] && params[:interview_date]
    raise LogicError, {id: 422, message: '面談主持人不能是自己'}.to_json if params[:performance_moderator_id] == @performance_interview.appraisal_participator.user_id
    raise LogicError, {id: 422, message: '時間不符合規則'}.to_json if params[:interview_time_begin] > params[:interview_time_end]
    @performance_interview
        .update(performance_interview_params
                    .merge(
                        performance_interview_status: 'completed',
                        operator_id: current_user.id,
                        operator_at: Time.zone.now
                    )
        )
    if params['attend_attachments']
      @performance_interview.attachment_items.destroy_all
      params['attend_attachments'].each do |attachment_params|
        @performance_interview
            .attachment_items
            .create(attachment_params.permit(:file_name, :attachment_id).merge(creator_id: current_user.id))
      end
    end
    render json: @performance_interview, include: '**'
  end

  private

  def filter(query)
    query.where(appraisal_id: params[:appraisal_id])
  end

  def set_appraisal
    @appraisal = Appraisal.find(params[:appraisal_id])
  end
  # Use callbacks to share common setup or constraints between actions.
  def set_performance_interview
    @performance_interview = PerformanceInterview.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def performance_interview_params
    params.permit(:performance_moderator_id,
                  :interview_date,
                  :interview_time_begin,
                  :interview_time_end)
  end

  def search_query(query = PerformanceInterview.all)
    query = query.left_outer_joins({:appraisal_participator => {:user => :profile} }, :appraisal, :performance_moderator, :operator)
    %w(appraisal_name appraisal_date performance_interview_status empoid name location department position grade division_of_job date_of_employment performance_moderator interview_date operator operator_at).each do  |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    query
  end
end
