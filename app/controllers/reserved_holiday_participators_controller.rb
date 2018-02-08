class ReservedHolidayParticipatorsController < ApplicationController
  include StatementBaseActions

  before_action :set_reserved_holiday_participator, only: [:update, :destroy]
  before_action :set_reserved_holiday_setting, only: [:index, :create, :whether_user_added]

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
        render json: query, root: 'data', meta: meta, include: '**'
      }
      format.xlsx {
        query = model.query(
            queries: query_params,
            sort_column: sort_column,
            sort_direction: sort_direction,
            path_param: params[:path_param]
        )
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        send_export(query)
      }
    end
  end

  def whether_user_added
    not_match_user_ids = []
    reserved_holiday_participator_params.each do |user_id|
      not_match_user_ids.push(user_id) if @reserved_holiday_setting.reserved_holiday_participators.find_by(user_id: user_id)
    end
    render json: {
      can_added: not_match_user_ids.size == 0,
      not_match_users: User.where(id: not_match_user_ids).map{ |user| user.as_json }
    }, root: 'data'
  end

  # POST /reserved_holiday_participators
  def create
    ActiveRecord::Base.transaction do
      User.where(id: reserved_holiday_participator_params).each do |user|
        @reserved_holiday_setting
          .reserved_holiday_participators
          .new(user_id: user.id, owned_days_count: @reserved_holiday_setting.days_count)
      end
    end
    if @reserved_holiday_setting.save
      render json: @reserved_holiday_setting, status: :created, location: @reserved_holiday_setting
    else
      render json: @reserved_holiday_setting.errors, status: :unprocessable_entity
    end
  end

  # DELETE /reserved_holiday_participators/1
  def destroy
    render json: @reserved_holiday_participator.destroy
  end

  private
  def set_reserved_holiday_setting
    @reserved_holiday_setting = ReservedHolidaySetting.find(params[:reserved_holiday_setting_id])
  end

  def set_reserved_holiday_participator
    @reserved_holiday_participator = ReservedHolidayParticipator.find(params[:id])
  end

  def reserved_holiday_participator_params
    params.require(:user_ids)
  end

  def search_query
    query = @reserved_holiday_setting.reserved_holiday_participators.left_outer_joins(:reserved_holiday_setting, :user => :profile)
    %w(reserved_holiday_setting empoid name department position grade employment_status date_of_employment owned_days_count taken_days_count).each do  |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    query
  end
end
