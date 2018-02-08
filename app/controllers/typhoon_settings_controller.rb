class TyphoonSettingsController < ApplicationController
  before_action :set_typhoon_setting, only: [:update, :destroy]

  def index
    authorize TyphoonSetting
    params[:page] ||= 1
    meta = {}
    all_result = search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)

    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    response_json result, meta: meta
  end

  def create
    authorize TyphoonSetting
    ActiveRecord::Base.transaction do
      ts = TyphoonSetting.create(typhoon_setting_params)
      TyphoonSetting.create_typhoon_qualified_records(ts)
      ts.qualify_counts = ts.typhoon_qualified_records.count
      ts.save
      response_json ts.id
    end
  end

  def update
    authorize TyphoonSetting
    ActiveRecord::Base.transaction do
      raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:start_date] && params[:end_date] && params[:start_time] && params[:end_time]
      raise LogicError, {id: 422, message: '时间不正确'}.to_json if params[:start_date] > params[:end_date]
      raise LogicError, {id: 422, message: '时间不正确'}.to_json if params[:start_time] > params[:end_time]
      if @typhoon_setting.apply_counts.to_i == 0
        @typhoon_setting.update(typhoon_setting_params)
        @typhoon_setting.typhoon_qualified_records.each { |tqr| tqr.destroy }
        TyphoonSetting.create_typhoon_qualified_records(@typhoon_setting)
        @typhoon_setting.qualify_counts = @typhoon_setting.typhoon_qualified_records.count
        @typhoon_setting.save
      end

      response_json :ok
    end
  end

  def destroy
    authorize TyphoonSetting
    if @typhoon_setting.apply_counts.to_i == 0
      @typhoon_setting.destroy
      @typhoon_setting.typhoon_qualified_records.each do |tqr|
        tqr.destroy
      end
    end
    response_json :ok
  end

  private

  def typhoon_setting_params
    params.require(:typhoon_setting).permit(
      :start_date,
      :end_date,
      :start_time,
      :end_time
    )
  end

  def set_typhoon_setting
    @typhoon_setting = TyphoonSetting.find(params[:id])
  end

  def search_query
    tag = false

    typhoon_settings = TyphoonSetting
                         .by_start_date(params[:start_date])
                         .by_end_date(params[:end_date])
                         .by_qualify_counts(params[:qualify_counts])
                         .by_apply_counts(params[:apply_counts])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'
      typhoon_settings = typhoon_settings.order("#{params[:sort_column]} #{params[:sort_direction]}")
      tag = true
    end

    typhoon_settings = typhoon_settings.order(created_at: :desc) if tag == false
    typhoon_settings
  end

end
