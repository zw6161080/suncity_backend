class SpecialScheduleSettingsController < ApplicationController

  include StatementBaseActions

  before_action :set_special_schedule_setting, only: [:update, :destroy]

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
        response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
        file_name = send_export(query)
        my_attachment = current_user.my_attachments.create(status: :generating, file_name: file_name)
        GenerateStatementReportJob.perform_later(
            query_ids: query.ids,
            query_model: controller_name,
            statement_columns: SpecialScheduleSetting.statement_columns_base,
            options: JSON.parse(SpecialScheduleSetting.options.to_json),
            my_attachment: my_attachment
        )
        render json: my_attachment
      }
    end
  end

  def check_params
    if SpecialScheduleSetting.can_create(special_schedule_setting_params)
      render json: { can_create: true }
      return
    end
    render json: { can_create: false, message: 'match_the_department' }
  end

  # POST /special_schedule_settings
  def create
    if !SpecialScheduleSetting.can_create(special_schedule_setting_params)
      render json: { can_create: false, message: 'match_the_department' }
      return
    end
    raise LogicError, {id: 422, message: '参数不完整'}.to_json unless special_schedule_setting_params
    @special_schedule_setting = SpecialScheduleSetting.new(special_schedule_setting_params)

    if @special_schedule_setting.save
      RosterObject.object_for_special_type(params[:user_id],
                                           current_user,
                                           'special_roster',
                                           params[:target_location_id],
                                           params[:target_department_id],
                                           params[:date_begin].in_time_zone.to_date,
                                           params[:date_end].in_time_zone.to_date,
                                          )

      render json: @special_schedule_setting, status: :created, location: @special_schedule_setting
    else
      render json: @special_schedule_setting.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /special_schedule_settings/1
  def update
    old_special_schedule_setting = @special_schedule_setting
    raise LogicError, {id: 422, message: '参数不完整'}.to_json unless special_schedule_setting_params
    if @special_schedule_setting.update(special_schedule_setting_params)
      RosterObject.update_object_for_special_type(old_special_schedule_setting, @special_schedule_setting, current_user)
      render json: @special_schedule_setting
    else
      render json: @special_schedule_setting.errors, status: :unprocessable_entity
    end
  end

  # DELETE /special_schedule_settings/1
  def destroy
    render json: @special_schedule_setting.destroy
  end

  private
  def send_export(query)
    special_schedule_setting_export_num = Rails.cache.fetch('special_schedule_setting_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+ special_schedule_setting_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('special_schedule_setting_export_number_tag', special_schedule_setting_export_num + 1)
    "#{I18n.t(self.controller_name + '.file_name')}#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx"
  end

  def set_special_schedule_setting
    @special_schedule_setting = SpecialScheduleSetting.find(params[:id])
  end

  def special_schedule_setting_params
    params.require(:user_id)
    params.require(:target_location_id)
    params.require(:target_department_id)
    params.require(:date_begin)
    params.require(:date_end)
    params.permit(:user_id,
                  :target_location_id,
                  :target_department_id,
                  :date_begin,
                  :date_end,
                  :comment
    )
  end

  def search_query
    query = SpecialScheduleSetting.left_outer_joins(:user => :profile)
    %w(name empoid schedule_date location department position date_of_employment target_location target_department schedule_date).each do  |item|
      query = query.send("by_#{item}", params[item.to_sym]) if params[item.to_sym]
    end
    query
  end
end
