# coding: utf-8
class StaffFeedbacksController < ApplicationController

  include SortParamsHelper
  include GenerateXlsxHelper

  before_action :set_staff_feedback, only: [:update]

  # GET /staff_feedbacks
  def index
    # authorize StaffFeedback 不要改回去
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
    if [:employee_no, :department_id, :position_id, :feedback_tracker].include?(sort_column)
      case sort_column
        when :employee_no then
          query = query.includes(:user)
                      .order("users.empoid #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
        when :department_id then
          query = query.includes(:user)
                      .order("users.department_id #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
        when :position_id then
          query = query.includes(:user)
                      .order("users.position_id #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
        when :feedback_tracker then
          query = query
                      .order("feedback_tracker_id #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
      end
    else
      query = query
                  .order(sort_column => sort_direction)
                  .page
                  .page(params.fetch(:page, 1))
                  .per(20)
    end
    meta = {
        total_count: query.total_count,
        current_page: query.current_page,
        total_pages: query.total_pages,
        sort_column: sort_column.to_s,
        sort_direction: sort_direction.to_s,
    }
    data = query.map do |feedback|
      feedback.get_json_data
    end
    response_json data.as_json, meta: meta
  end

  # GET /staff_feedbacks/index_my_feedbacks
  def index_my_feedbacks
    # authorize StaffFeedback
    sort_column = sort_column_sym(params[:sort_column], 'feedback_date')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query_of_my_feedback
    if [:feedback_tracker].include?(sort_column)
      query = query
                  .order("feedback_tracker_id #{sort_direction}")
                  .page
                  .page(params.fetch(:page, 1))
                  .per(20)
    else
      query = query
                  .order(sort_column => sort_direction)
                  .page
                  .page(params.fetch(:page, 1))
                  .per(20)
    end
    meta = {
        total_count: query.total_count,
        current_page: query.current_page,
        total_pages: query.total_pages,
        sort_column: sort_column.to_s,
        sort_direction: sort_direction.to_s,
    }
    data = query.map do |feedback|
      feedback.get_json_data
    end
    response_json data.as_json, meta: meta
  end

  # GET /staff_feedbacks/export_all_feedbacks
  def export_all_feedbacks
    # authorize StaffFeedback
    # 数据查询
    sort_column = sort_column_sym(params[:sort_column], 'feedback_date')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
    if [:employee_no, :department_id, :position_id, :feedback_tracker].include?(sort_column)
      case sort_column
        when :employee_no then
          query = query.includes(:user).order("users.empoid #{sort_direction}")
        when :department_id then
          query = query.includes(:user).order("users.department_id #{sort_direction}")
        when :position_id then
          query = query.includes(:user).order("users.position_id #{sort_direction}")
        when :feedback_tracker then
          query = query.order("feedback_tracker_id #{sort_direction}")
      end
    else
      query = query.order(sort_column => sort_direction)
    end
    data = query.map do |feedback|
      feedback.get_json_data
    end
    # 数据筛选
    selected_data = data.map do |record|
      one_record = {}
      one_record[:feedback_date]       = record.dig('feedback_date').strftime('%Y/%m/%d')
      one_record[:feedback_title]      = record.dig 'feedback_title'
      one_record[:employee_id]         = record.dig 'user.empoid'
      one_record[:feedback_track_status]      = I18n.t('staff_feedback.enum_track_status.'+record.dig('feedback_track_status'))
      if record.dig('feedback_track_date')
        one_record[:feedback_track_date]      = record.dig('feedback_track_date').strftime('%Y/%m/%d')
      else
        one_record[:feedback_track_date]      = ' '
      end
      if record.dig('feedback_track_content')
        one_record[:feedback_track_content]   = record.dig('feedback_track_content')
      else
        one_record[:feedback_track_content]   = ' '
      end

      one_record[:employee_name]       = record.dig "user.#{select_language}"
      one_record[:employee_department] = record.dig "user.department.#{select_language}"
      one_record[:employee_position]   = record.dig "user.position.#{select_language}"
      one_record[:feedback_tracker]    = record.dig "feedback_tracker.#{select_language}" rescue nil

      one_record[:feedback_tracker]    = ' ' if one_record[:feedback_tracker]==nil
      one_record
    end
    # 生成Excel
    xlsx_data = {
        fields: {:feedback_date          => I18n.t('staff_feedback.header.feedback_date'),
                 :feedback_title         => I18n.t('staff_feedback.header.feedback_title'),
                 :employee_name          => I18n.t('staff_feedback.header.employee_name'),
                 :employee_id            => I18n.t('staff_feedback.header.employee_id'),
                 :employee_department    => I18n.t('staff_feedback.header.employee_department'),
                 :employee_position      => I18n.t('staff_feedback.header.employee_position'),
                 :feedback_track_status  => I18n.t('staff_feedback.header.track_status'),
                 :feedback_tracker       => I18n.t('staff_feedback.header.tracker'),
                 :feedback_track_date    => I18n.t('staff_feedback.header.track_date'),
                 :feedback_track_content => I18n.t('staff_feedback.header.track_content') },
        records: selected_data,
    }
    response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
    over_time_export_num = Rails.cache.fetch('over_time_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+over_time_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('over_time_export_number_tag', over_time_export_num+1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: I18n.t('staff_feedback.filename')+Time.zone.now.strftime('%Y%m%d')+export_id.to_s+'.xlsx')
    GenerateTableJob.perform_later(data: xlsx_data, my_attachment: my_attachment)
    render json: my_attachment
  end

  # POST /staff_feedbacks
  def create
    # authorize StaffFeedback 不要改回去
    staff_feedback = StaffFeedback.create(staff_feedback_params.as_json)
    response_json staff_feedback
  end

  # PATCH/PUT /staff_feedbacks/1
  def update
    # authorize StaffFeedback 不要改回去
    if @staff_feedback.update(staff_feedback_params)
      response_json @staff_feedback
    else
      response_json @staff_feedback.errors, error: :unprocessable_entity
    end
  end

  # GET /staff_feedbacks/field_options
  def field_options
    response_json StaffFeedback.field_options
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_staff_feedback
      @staff_feedback = StaffFeedback.detailed_by_id(params[:id])
    end

    def staff_feedback_params
      params.require(:staff_feedback).permit(*StaffFeedback.create_params)
    end

    def search_query
      query = StaffFeedback.includes(user: [:department, :position]).includes(:feedback_tracker)
      {
          employee_no:            :by_users_employee_no,
          department_id:          :by_users_department_id,
          position_id:            :by_users_position_id,
          feedback_track_status:  :by_feedback_track_status,
      }.each do |key, value|
        query = query.send(value, params[key]) if params[key]
      end

      if params[:employee_name]
          query = query.where(users: {select_language => params[:employee_name]})
      end

      if params[:feedback_date]
        if params[:feedback_date][:begin].present? && params[:feedback_date][:end].present?
          query = query.where(feedback_date: Time.zone.parse(params[:feedback_date][:begin])..Time.zone.parse(params[:feedback_date][:end]))
        elsif params[:feedback_date][:begin].present? && params[:feedback_date][:end].blank?
          query = query.where("feedback_date >= ?", Time.zone.parse(params[:feedback_date][:begin]))
        elsif params[:feedback_date][:begin].blank? && params[:feedback_date][:end].present?
          query = query.where("feedback_date <= ?", Time.zone.parse(params[:feedback_date][:end]))
        end
      end

      if params[:feedback_track_date]
        from = (Time.zone.parse(params[:feedback_track_date][:begin]).beginning_of_day rescue nil)
        to   = (Time.zone.parse(params[:feedback_track_date][:end]).end_of_day rescue nil)
        if from && to
          query = query.where('feedback_track_date >= :from AND feedback_track_date <= :to', from: from, to: to)
        elsif from
          query = query.where('feedback_track_date >= :from', from: from)
        elsif to
          query = query.where('feedback_track_date <= :to', to: to)
        end
      end

      if params[:feedback_tracker]
        query = query.where(feedback_tracker_id: User.where('chinese_name = :name OR english_name = :name', name: params[:feedback_tracker]).select(:id))
      end
      query
    end

    def search_query_of_my_feedback
      query = StaffFeedback.includes(user: [:department, :position]).includes(:feedback_tracker)
                           .where(user_id: current_user.id)
      {
          feedback_track_status: :by_feedback_track_status,
      }.each do |key, value|
        query = query.send(value, params[key]) if params[key]
      end

      if params[:feedback_date]
        if params[:feedback_date][:begin].present? && params[:feedback_date][:end].present?
          query = query.where(feedback_date: Time.zone.parse(params[:feedback_date][:begin])..Time.zone.parse(params[:feedback_date][:end]))
        elsif params[:feedback_date][:begin].present? && params[:feedback_date][:end].blank?
          query = query.where("feedback_date >= ?", Time.zone.parse(params[:feedback_date][:begin]))
        elsif params[:feedback_date][:begin].blank? && params[:feedback_date][:end].present?
          query = query.where("feedback_date <= ?", Time.zone.parse(params[:feedback_date][:end]))
        end
      end

      if params[:feedback_track_date]
        from = (Time.zone.parse(params[:feedback_track_date][:begin]).beginning_of_day rescue nil)
        to   = (Time.zone.parse(params[:feedback_track_date][:end]).end_of_day rescue nil)
        if from && to
          query = query.where('feedback_track_date >= :from AND feedback_track_date <= :to', from: from, to: to)
        elsif from
          query = query.where('feedback_track_date >= :from', from: from)
        elsif to
          query = query.where('feedback_track_date <= :to', to: to)
        end
      end

      if params[:feedback_tracker]
        query = query.where(feedback_tracker_id: User.where('chinese_name = :name OR english_name = :name', name: params[:feedback_tracker]).select(:id))
      end
      query
    end

end
