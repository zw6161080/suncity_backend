class ImmediateLeaveController < ApplicationController

  def index
    sort_column = params[:sort_column] ? params[:sort_column] : 'date'
    sort_direction = params[:sort_direction] ? params[:sort_direction] : 'desc'
    immediate_leave = search_query.order("#{sort_column} #{sort_direction}")
                            .page.page(params[:page]).per(20)

    meta = {
      total_count: immediate_leave.total_count,
      current_page: immediate_leave.current_page,
      total_pages: immediate_leave.total_pages, 
      sort_column: sort_column,
      sort_direction: sort_direction
    }

    result = immediate_leave.as_json(include: [:user, :creator])
    result.collect do|hash|
      hash['date'] = hash['date'].to_s.split('-').join('/')
      hash['created_at'] = hash['created_at'].to_date.to_s.split('-').join('/')
      hash
    end
    response_json result, meta: meta
  end

  def create
    ActiveRecord::Base.transaction do
      immediate_leave = ImmediateLeave.create(immediate_leave_params)
      immediate_leave.creator = current_user
      immediate_leave.save

      if params[:immediate_leave_items]
        params[:immediate_leave_items].each do |item|
          immediate_leave.immediate_leave_items.create(item.permit(:comment, :date, :shift_info ,:work_time ,:come, :leave))
        end
      end

      if params[:attend_approvals]
        params[:attend_approvals].each do |attend_approval|
          immediate_leave.attend_approvals.create(attend_approval.permit(:user_id, :date, :comment))
        end
      end

      if params[:attend_attachments]
        params[:attend_attachments].each do |attend_attachment|
          immediate_leave.attend_attachments.create(attend_attachment.permit(:file_name, :comment, :attachment_id).merge({creator_id: current_user.id}))
        end
      end

      immediate_leave.item_count = Array(params[:immediate_leave_items]).count
      immediate_leave.creator = current_user
      immediate_leave.save
      
      response_json immediate_leave.id
    end
  end

  def show
    immediate_leave = ImmediateLeave.find(params[:id])
    result = immediate_leave.as_json(include: {immediate_leave_items: {}, attend_approvals: {include: {user: {include: [:department, :location, :position ]}}}, attend_attachments: {include: :creator}, user: {include: [:department, :location, :position ]}, creator: {}})

    response_json result
  end

  def field_options
    options = {}
    options[:date] = ImmediateLeave.all.pluck(:date).compact.uniq.try(:sort).collect do |item|
      item.to_s.split('-').join('/')
    end

    options[:department_chinese_name] = ImmediateLeave.joins(
        {user: [:department,:position]}
    ).pluck('departments.chinese_name').compact.uniq.try(:sort)
    options[:position_chinese_name] = ImmediateLeave.joins(
        {user: [:department,:position]}
    ).pluck('positions.chinese_name').compact.uniq.try(:sort)
    options[:record_type] = ImmediateLeave.all.pluck(:record_type).compact.uniq.try(:sort)
    options[:status] = ImmediateLeave.all.pluck(:status).compact.uniq.try(:sort)

    options[:created_at] = ImmediateLeave.all.pluck(:created_at).collect do |item|
      item.to_date.to_s.split('-').join('/')
    end.compact.uniq.try(:sort)
    response_json options
  end

  private

  def search_query
    immediate_leave_query = ImmediateLeave.joins({user: [:department,:position]},:creator)
    immediate_leave_query = immediate_leave_query.select([
      "immediate_leaves.*",
      "users.chinese_name as user_chinese_name",
      "departments.chinese_name as department_chinese_name",
      "positions.chinese_name as position_chinese_name",
      "creators_immediate_leaves.chinese_name as creator_chinese_name"
    ])
    if params[:date]
      params[:date].collect! do |item|
        date = item.split('/').map(&:to_i)
        Date.new(date[0],date[1],date[2])
      end
      immediate_leave_query = immediate_leave_query.where(date: params[:date])
    end

    if params[:user_chinese_name]
      immediate_leave_query = immediate_leave_query.where('users.chinese_name like ?', "%#{params[:user_chinese_name]}%")
    end


    if params[:department_chinese_name]
      immediate_leave_query = immediate_leave_query.where(departments: {chinese_name: params[:department_chinese_name]})
    end

    if params[:position_chinese_name]
      immediate_leave_query = immediate_leave_query.where(positions: {chinese_name: params[:position_chinese_name]})
    end

    if params[:record_type]
      immediate_leave_query = immediate_leave_query.where(record_type: params[:record_type])
    end
    if params[:status]
      immediate_leave_query = immediate_leave_query.where(status: params[:status])
    end

    if params[:creator_chinese_name]
      immediate_leave_query = immediate_leave_query.where('creators_immediate_leaves.chinese_name like ?', "%#{params[:creator_chinese_name]}%")
    end

    if params[:created_at]
      params[:created_at].collect! do |item|
        date = item.split('/').map(&:to_i)
        date = Time.zone.local(date[0],date[1],date[2]).to_datetime.midnight
        date...(date + 1.day)
      end
      immediate_leave_query = immediate_leave_query.where(created_at: params[:created_at])
    end

    immediate_leave_query
  end

  def immediate_leave_params
    params.require(:immediate_leave).permit(
      :user_id,
      :comment,
      :date
    )
  end

end
