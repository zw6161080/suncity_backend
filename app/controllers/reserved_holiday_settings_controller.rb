class ReservedHolidaySettingsController < ApplicationController

  include StatementBaseActions

  before_action :set_reserved_holiday_setting, only: [:show, :update, :destroy]

  def index
    sort_column = sort_column_sym(params[:sort_column], :date_begin)
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

  # GET /reserved_holiday_settings/1
  def show
    render json: @reserved_holiday_setting
  end

  # POST /reserved_holiday_settings
  def create
    raise LogicError, {id: 422, message: '参数不完整'}.to_json unless reserved_holiday_setting_params
    @reserved_holiday_setting = ReservedHolidaySetting
                                    .new(reserved_holiday_setting_params
                                             .merge(
                                                 can_destroy: true,
                                                 update_date: Time.zone.now
                                             )
                                    )

    if @reserved_holiday_setting.save
      render json: @reserved_holiday_setting, status: :created, location: @reserved_holiday_setting
    else
      render json: @reserved_holiday_setting.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /reserved_holiday_settings/1
  def update
    raise LogicError, {id: 422, message: '参数不完整'}.to_json unless reserved_holiday_setting_params
    if @reserved_holiday_setting.update(
        reserved_holiday_setting_params.merge(update_date: Time.zone.now)
    )
      render json: @reserved_holiday_setting
    else
      render json: @reserved_holiday_setting.errors, status: :unprocessable_entity
    end
  end

  # DELETE /reserved_holiday_settings/1
  def destroy
    render json: @reserved_holiday_setting.destroy
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_reserved_holiday_setting
    @reserved_holiday_setting = ReservedHolidaySetting.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def reserved_holiday_setting_params
    params.require(:date_begin)
    params.require(:date_end)
    params.require(:chinese_name)
    params.require(:english_name)
    params.require(:simple_chinese_name)
    params.require(:days_count)
    # params.require(:creator_id)
    params.permit(:chinese_name,
                  :english_name,
                  :simple_chinese_name,
                  :days_count,
                  :comment,
                  :creator_id
    ).merge(
        :date_begin => Time.zone.parse(params[:date_begin]).beginning_of_day,
        :date_end => Time.zone.parse(params[:date_end]).end_of_day
    )
  end

  def search_query
    query = ReservedHolidaySetting.left_outer_joins(:creator)
    %w(name date_begin date_end days_count member_count creator update_date).each do  |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    query
  end
end
