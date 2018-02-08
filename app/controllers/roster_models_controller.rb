# coding: utf-8
class RosterModelsController < ApplicationController
  include GenerateXlsxHelper
  before_action :set_roster_model, only: [:update, :destroy, :export_xlsx]
  before_action :set_be_used, only: [:index, :index_by_my_profile]



  #我的档案中使用
  def index_by_my_profile
    raw_index
  end

  def raw_index
    result = RosterModel.all.map do |roster_model|
      weeks = roster_model.roster_model_weeks
      roster_model_weeks_table = weeks.map do |w|
        w.as_json.merge(
          {
            mon: ClassSetting.find_by(id: w.mon_class_setting_id).as_json,
            tue: ClassSetting.find_by(id: w.tue_class_setting_id).as_json,
            wed: ClassSetting.find_by(id: w.wed_class_setting_id).as_json,
            thu: ClassSetting.find_by(id: w.thu_class_setting_id).as_json,
            fri: ClassSetting.find_by(id: w.fri_class_setting_id).as_json,
            sat: ClassSetting.find_by(id: w.sat_class_setting_id).as_json,
            sun: ClassSetting.find_by(id: w.sun_class_setting_id).as_json
          }
        )
      end

      roster_model.as_json(
        include: {
          department: {}
        }
      ).merge(
        roster_model_weeks: roster_model_weeks_table,
      )
    end
    response_json result.as_json

  end

  def index
    authorize RosterModel
    raw_index
  end

  def create
    authorize RosterModel
    ActiveRecord::Base.transaction do
      rm = RosterModel.create(roster_model_params)
      roster_model_weeks = params[:roster_model_weeks]
      roster_model_weeks.each do |weeks_params|
        rm.roster_model_weeks.create(weeks_params.permit(
                                       :region,
                                       :order_no,
                                       :mon_class_setting_id,
                                       :tue_class_setting_id,
                                       :wed_class_setting_id,
                                       :thu_class_setting_id,
                                       :fri_class_setting_id,
                                       :sat_class_setting_id,
                                       :sun_class_setting_id
                                     ))
      end

      response_json :ok
    end
  end

  def update
    authorize RosterModel
    ActiveRecord::Base.transaction do
      weeks_before_count = @roster_model.weeks_count.to_i
      weeks_current_count = params['weeks_count'].to_i

      @roster_model.update(roster_model_params)
      roster_model_weeks_params = params['roster_model_weeks']
      roster_model_weeks = @roster_model.roster_model_weeks

      if weeks_before_count <= weeks_current_count
        roster_model_weeks_params.each do |weeks_params|
          if weeks_params['order_no'].to_i <= weeks_before_count.to_i

            rmw = roster_model_weeks.find_by(order_no: weeks_params['order_no'].to_i)
            if rmw
              rmw.update(weeks_params.permit(
                           :region,
                           :order_no,
                           :mon_class_setting_id,
                           :tue_class_setting_id,
                           :wed_class_setting_id,
                           :thu_class_setting_id,
                           :fri_class_setting_id,
                           :sat_class_setting_id,
                           :sun_class_setting_id
                         ))
            end
          else
            roster_model_weeks.create(weeks_params.permit(
                                        :region,
                                        :order_no,
                                        :mon_class_setting_id,
                                        :tue_class_setting_id,
                                        :wed_class_setting_id,
                                        :thu_class_setting_id,
                                        :fri_class_setting_id,
                                        :sat_class_setting_id,
                                        :sun_class_setting_id
                                      ))
          end
        end
      else
        roster_model_weeks_params.each do |weeks_params|
          rmw = roster_model_weeks.find_by(order_no: weeks_params['order_no'].to_i)
          rmw.update(weeks_params.permit(
                       :region,
                       :order_no,
                       :mon_class_setting_id,
                       :tue_class_setting_id,
                       :wed_class_setting_id,
                       :thu_class_setting_id,
                       :fri_class_setting_id,
                       :sat_class_setting_id,
                       :sun_class_setting_id
                     ))
        end
        roster_model_weeks.where("order_no > ?", weeks_current_count.to_i).each { |w| w.destroy }
      end

      response_json :ok
    end
  end

  def destroy
    authorize RosterModel
    @roster_model.destroy unless @roster_model.be_used
    response_json :ok
  end

  def export_xlsx
    authorize RosterModel
    weeks = @roster_model.roster_model_weeks
    roster_model_weeks_table = weeks.map do |w|
      w.as_json.merge(
        {
          mon: ClassSetting.find_by(id: w.mon_class_setting_id).as_json,
          tue: ClassSetting.find_by(id: w.tue_class_setting_id).as_json,
          wed: ClassSetting.find_by(id: w.wed_class_setting_id).as_json,
          thu: ClassSetting.find_by(id: w.thu_class_setting_id).as_json,
          fri: ClassSetting.find_by(id: w.fri_class_setting_id).as_json,
          sat: ClassSetting.find_by(id: w.sat_class_setting_id).as_json,
          sun: ClassSetting.find_by(id: w.sun_class_setting_id).as_json
        }
      )
    end

    roster_model_export_num = Rails.cache.fetch('roster_model_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + roster_model_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('roster_model_export_number_tag', roster_model_export_num+1)

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(roster_model_weeks_table.to_json),controller_name: 'RosterModelsController', table_fields_methods: 'get_table_fields', table_fields_args: [], my_attachment: my_attachment, sheet_name: 'RosterModelTable')
    render json: my_attachment
  end

  private

  def roster_model_params
    params.permit(
      :region,
      :chinese_name,
      :department_id,
      :start_date,
      :end_date,
      :weeks_count,
    )
  end

  def set_roster_model
    @roster_model = RosterModel.find(params[:id])
  end

  def set_be_used
    RosterModel.set_be_used
  end

  def self.get_table_fields
    general_holiday_dict = {
      chinese_name: '公休',
      english_name: 'General Holiday',
      simple_chinese_name: '公休',
    }

    order_no = {
      chinese_name: '星期數',
      english_name: 'Week NO',
      simple_chinese_name: '星期数',
      get_value: -> (rst, options){
        rst["order_no"] ? rst["order_no"] : ''
      }
    }

    mon = {
      chinese_name: 'Mon',
      english_name: 'Mon',
      simple_chinese_name: 'Mon',
      get_value: -> (rst, options){
        rst[:mon] ? rst[:mon]["display_name"] : general_holiday_dict[options[:name_key]]
      }
    }

    tue = {
      chinese_name: 'Tue',
      english_name: 'Tue',
      simple_chinese_name: 'Tue',
      get_value: -> (rst, options){
        rst[:tue] ? rst[:tue]["display_name"] : general_holiday_dict[options[:name_key]]
      }
    }

    wed = {
      chinese_name: 'Wed',
      english_name: 'Wed',
      simple_chinese_name: 'Wed',
      get_value: -> (rst, options){
        rst[:wed] ? rst[:wed]["display_name"] : general_holiday_dict[options[:name_key]]
      }
    }

    thu = {
      chinese_name: 'Thu',
      english_name: 'Thu',
      simple_chinese_name: 'Thu',
      get_value: -> (rst, options){
        rst[:thu] ? rst[:thu]["display_name"] : general_holiday_dict[options[:name_key]]
      }
    }

    fri = {
      chinese_name: 'Fri',
      english_name: 'Fri',
      simple_chinese_name: 'Fri',
      get_value: -> (rst, options){
        rst[:fri] ? rst[:fri]["display_name"] : general_holiday_dict[options[:name_key]]
      }
    }

    sat = {
      chinese_name: 'Sat',
      english_name: 'Sat',
      simple_chinese_name: 'Sat',
      get_value: -> (rst, options){
        rst[:sat] ? rst[:sat]["display_name"] : general_holiday_dict[options[:name_key]]
      }
    }

    sun = {
      chinese_name: 'Sun',
      english_name: 'Sun',
      simple_chinese_name: 'Sun',
      get_value: -> (rst, options){
        rst[:sun] ? rst[:sun]["display_name"] : general_holiday_dict[options[:name_key]]
      }
    }

    table_fields = [order_no, mon, tue, wed, thu, fri, sat, sun]

  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '更模'
    elsif select_language.to_s == 'english_name'
      'Roster Model'
    else
      '更模'
    end
  end
end
