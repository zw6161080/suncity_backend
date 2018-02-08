class HolidaySettingsController < ApplicationController
  before_action :set_holiday_setting, only: [:update, :destroy]

  def index
    authorize HolidaySetting
    result = search_query.order(:category).order(:holiday_date)
    meta = { total_count: result.size }
    response_json search_query.as_json, meta: meta
  end

  def create
    authorize HolidaySetting
    ActiveRecord::Base.transaction do
      raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:chinese_name] && params[:english_name] && params[:simple_chinese_name] && params[:category] && params[:holiday_date] && params[:region]
      holiday_setting = HolidaySetting.create(holiday_setting_params)
      holiday_setting.save
      response_json holiday_setting.id
    end
  end

  def update
    authorize HolidaySetting
    result = @holiday_setting.update_attributes(holiday_setting_params)
    response_json result
  end

  def destroy
    authorize HolidaySetting
    @holiday_setting.destroy
    response_json
  end

  def batch_create
    authorize HolidaySetting
    ActiveRecord::Base.transaction do
      raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:chinese_name] && params[:english_name] && params[:simple_chinese_name] && params[:category] && params[:holiday_date] && params[:region]
      if params[:holidays]
        params[:holidays].each do |holiday|
          holiday_setting = HolidaySetting.create(holiday.permit(
                                                    :region,
                                                    :chinese_name,
                                                    :english_name,
                                                    :simple_chinese_name,
                                                    :category,
                                                    :holiday_date,
                                                    :comment
                                                  ))
          holiday_setting.save
        end
      end
      response_json
    end
  end

  private

  def holiday_setting_params
    params.require(:holiday_setting).permit(
      :region,
      :chinese_name,
      :english_name,
      :simple_chinese_name,
      :category,
      :holiday_date,
      :comment
    )
  end

  def set_holiday_setting
    @holiday_setting = HolidaySetting.find(params[:id])
  end

  def query_range
    start_date = Date.today.beginning_of_year
    end_date = Date.today.end_of_year
    if params[:year] && !params[:month]
      year_n = params[:year].to_i rescue nil
      start_date = Date.new(year_n).beginning_of_year
      end_date = Date.new(year_n).end_of_year
    elsif params[:year] && params[:month]
      year_n = params[:year].to_i rescue nil
      month_n = params[:month].to_i rescue nil
      start_date = Date.new(year_n, month_n).beginning_of_month
      end_date = Date.new(year_n, month_n).end_of_month
    end
    [start_date,end_date]
  end

  def search_query
    start_date = query_range.first
    end_date = query_range.last
    HolidaySetting.where(holiday_date: start_date..end_date)
      .order("category ASC", "holiday_date ASC")
  end
end
