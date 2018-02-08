class VipHallsTrainersController < ApplicationController

  include SortParamsHelper
  include GenerateXlsxHelper

  before_action :set_vip_halls_trainer, only: [:update]

  # GET /vip_halls_trainers
  def index
    authorize VipHallsTrainer
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
                .order(sort_column => sort_direction)
                .page
                .page(params.fetch(:page, 1))
                .per(20)
    # 处理表头
    if query.count >= 1
      vip_halls_train = VipHallsTrain.find(query.first.vip_halls_train_id)
    else
      vip_halls_train = VipHallsTrain.find(@vip_halls_train_id)
    end
    employee_amount               = vip_halls_train.employee_amount
    training_minutes_available    = vip_halls_train.training_minutes_available
    training_minutes_accepted     = vip_halls_train.training_minutes_accepted
    training_minutes_per_employee = vip_halls_train.training_minutes_per_employee
    case (training_minutes_per_employee/60).floor
      when 0...25 then
        header_score = 1
      when 25...30 then
        header_score = 2
      when 30...35 then
        header_score = 3
      when 35...40 then
        header_score = 4
      else
        header_score = 5
    end
    # 处理表头
    meta = {
        total_count: query.total_count,
        current_page: query.current_page,
        total_pages: query.total_pages,
        sort_column: sort_column.to_s,
        sort_direction: sort_direction.to_s,
        header_number_of_people_on_the_1st_day: employee_amount,
        header_total_training_time_provided: training_minutes_available,
        header_total_training_time_accepted: training_minutes_accepted,
        header_average_training_time_accepted: training_minutes_per_employee,
        header_score: header_score,
        locked: vip_halls_train.locked,
    }
    data = query.map do |record|
      record.as_json(include: :user)
    end
    response_json data.as_json, meta: meta
  end

  # GET /vip_halls_trainers/export
  def export
    authorize VipHallsTrainer
    # 数据查询
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query.order(sort_column => sort_direction)
    data = query.map do |record|
      record.as_json(include: :user)
    end
    # 数据筛选
    temp_serial_number = 1
    selected_data = data.map do |record|
      one_record = {}
      one_record[:serial_number]      = temp_serial_number
      temp_serial_number += 1
      one_record[:train_date]         = record.dig('train_date_begin').strftime('%Y/%m/%d')
      one_record[:train_content]      = record.dig 'train_content'
      one_record[:employee_id]        = record.dig 'user.empoid'
      one_record[:train_date_begin]   = record.dig('train_date_begin').strftime('%H:%M')
      one_record[:train_date_end]     = record.dig('train_date_end').strftime('%H:%M')
      one_record[:train_type]         = I18n.t('vip_halls_trainer.enum_train_type.'+record.dig('train_type'))
      one_record[:number_of_students] = record.dig 'number_of_students'
      length_of_training_time_hour         = record.dig('length_of_training_time')/60
      length_of_training_time_minute       = record.dig('length_of_training_time')%60
      one_record[:length_of_training_time] = length_of_training_time_hour.to_s+I18n.t('vip_halls_trainer.hour')+length_of_training_time_minute.to_s+I18n.t('vip_halls_trainer.minute')
      total_accepted_training_time_hour         = record.dig('total_accepted_training_time')/60
      total_accepted_training_time_minute       = record.dig('total_accepted_training_time')%60
      one_record[:total_accepted_training_time] = total_accepted_training_time_hour.to_s+I18n.t('vip_halls_trainer.hour')+total_accepted_training_time_minute.to_s+I18n.t('vip_halls_trainer.minute')
      if record.dig 'remarks'
        one_record[:remarks]          = record.dig 'remarks'
      else
        one_record[:remarks]          = ' '
      end
      if I18n.locale==:en
        one_record[:employee_name]    = record.dig 'user.english_name'
      elsif I18n.locale==:'zh-CN'
        one_record[:employee_name]    = record.dig 'user.simple_chinese_name'
      else
        one_record[:employee_name]    = record.dig 'user.chinese_name'
      end
      one_record
    end
    # 生成Excel
    xlsx_data = {
        fields: {:serial_number                => I18n.t('vip_halls_trainer.header.serial_number'),
                 :train_date                   => I18n.t('vip_halls_trainer.header.train_date'),
                 :train_content                => I18n.t('vip_halls_trainer.header.train_content'),
                 :employee_id                  => I18n.t('vip_halls_trainer.header.employee_id'),
                 :employee_name                => I18n.t('vip_halls_trainer.header.employee_name'),
                 :train_date_begin             => I18n.t('vip_halls_trainer.header.train_date_begin'),
                 :train_date_end               => I18n.t('vip_halls_trainer.header.train_date_end'),
                 :length_of_training_time      => I18n.t('vip_halls_trainer.header.length_of_training_time'),
                 :train_type                   => I18n.t('vip_halls_trainer.header.train_type'),
                 :number_of_students           => I18n.t('vip_halls_trainer.header.number_of_students'),
                 :total_accepted_training_time => I18n.t('vip_halls_trainer.header.total_accepted_training_time'),
                 :remarks                      => I18n.t('vip_halls_trainer.header.remarks')},
        records: selected_data,
    }
    response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
    over_time_export_num = Rails.cache.fetch('over_time_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+over_time_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('over_time_export_number_tag', over_time_export_num+1)
    if params['inspector'] == 'hr'
      location = Location.find(VipHallsTrain.find(params['vip_halls_train_id']).location_id)
    else
      location = Location.find(params['location_id'])
    end
    if I18n.locale==:en
      location_name = location.english_name
    elsif I18n.locale==:'zh-CN'
      location_name = location.simple_chinese_name
    else
      location_name = location.chinese_name
    end
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: I18n.t('vip_halls_trainer.filename')+location_name+'_'+Time.zone.now.strftime('%Y%m%d')+export_id.to_s+'.xlsx')
    GenerateTableJob.perform_later(data: xlsx_data, my_attachment: my_attachment)
    render json: my_attachment
  end

  # GET /vip_halls_trainers/columns
  def columns
    columns = [
        {key: 'header0',                                chinese_name: '-場館內員工培訓記錄', english_name: ' - Staff training records in the location', simple_chinese_name: '-场馆内员工培训记录'},
        {key: 'header1',                                chinese_name: '月份',             english_name: 'Month',                                     simple_chinese_name: '月份'},
        {key: 'header_number_of_people_on_the_1st_day', chinese_name: '每月1日場館人數',    english_name: 'The number of people on the 1st day',       simple_chinese_name: '每月1日场馆人数',    value_type: 'number_value'},
        {key: 'header_score',                           chinese_name: '評分',             english_name: 'Score',                                     simple_chinese_name: '评分',             value_type: 'number_value'},
        {key: 'header_total_training_time_provided',    chinese_name: '場館提供培訓總時數',  english_name: 'Provided training',                         simple_chinese_name: '场馆提供培训总时数', value_type: 'number_value'},
        {key: 'header_total_training_time_accepted',    chinese_name: '員工接受培訓總時數',  english_name: 'Total staff received training hours ',      simple_chinese_name: '员工接受培训总时数', value_type: 'number_value'},
        {key: 'header_average_training_time_accepted',  chinese_name: '員工平均培訓時數',    english_name: 'Average staff training hours',             simple_chinese_name: '员工平均培训时数',    value_type: 'number_value'},
        {key: 'serial_number',                          chinese_name: '序號',             english_name: 'Serial number',                             simple_chinese_name: '序号',             value_type: 'number_value'},
        {key: 'train_date',                             chinese_name: '培訓日期',          english_name: 'Training date',                             simple_chinese_name: '培训日期',          value_type: 'date_value', value_format: 'YYYY/MM/DD', search_attribute: 'train_date_begin'},
        {key: 'train_content',                          chinese_name: '培訓內容',          english_name: 'Training content',                          simple_chinese_name: '培训内容',          value_type: 'string_value'},
        {key: 'employee_id',                            chinese_name: '培訓員-員工編號',    english_name: 'Trainer - staff ID',                        simple_chinese_name: '培训员-员工编号',    value_type: 'string_value'},
        {key: 'employee_name',                          chinese_name: '培訓員-姓名',       english_name: 'Trainer - name',                            simple_chinese_name: '培训员-姓名',       value_type: 'obj_value'},
        {key: 'train_date_begin',                       chinese_name: '培訓開始時間',       english_name: 'Training start time',                      simple_chinese_name: '培训开始时间',       value_type: 'date_value', value_format: 'hh:mm'},
        {key: 'train_date_end',                         chinese_name: '培訓結束時間',       english_name: 'Training end time',                        simple_chinese_name: '培训结束时间',       value_type: 'date_value', value_format: 'hh:mm'},
        {key: 'length_of_training_time',                chinese_name: '培訓時長',          english_name: 'Training hours',                           simple_chinese_name: '培训时长',          value_type: 'number_value'},
        {key: 'train_type',                             chinese_name: '培訓類型',          english_name: 'Category',                                 simple_chinese_name: '培训类型',          value_type: 'string_value'},
        {key: 'number_of_students',                     chinese_name: '同時上課人數',       english_name: 'Number of students the same time',         simple_chinese_name: '同时上课人数',       value_type: 'number_value'},
        {key: 'total_accepted_training_time',           chinese_name: '員工接受培訓總時數',  english_name: 'Total staff received training hours',      simple_chinese_name: '员工接受培训总时数',  value_type: 'number_value'},
        {key: 'remarks',                                chinese_name: '備註',             english_name: 'Remarks',                                  simple_chinese_name: '备注',             value_type: 'string_value'},
    ]
    render json: columns
  end

  # POST /vip_halls_trainers
  def create
    authorize VipHallsTrainer
    if Time.zone.parse(vip_halls_trainer_params['train_date_end']) >= Time.zone.parse(vip_halls_trainer_params['train_date_begin'])
      length_of_training_time      = ((Time.zone.parse(vip_halls_trainer_params['train_date_end'])-Time.zone.parse(vip_halls_trainer_params['train_date_begin']))/60).to_i
      total_accepted_training_time = length_of_training_time * vip_halls_trainer_params['number_of_students'].to_i
      vip_halls_trainer = VipHallsTrainer.create(vip_halls_trainer_params.as_json.merge(
          length_of_training_time: length_of_training_time,
          total_accepted_training_time: total_accepted_training_time
      ))
      response_json vip_halls_trainer
    else
      response_json [], status: :unprocessable_entity
    end
  end

  # PATCH/PUT /vip_halls_trainers/1
  def update
    authorize VipHallsTrainer
    if @vip_halls_trainer.update(vip_halls_trainer_params.permit(
        :train_date_begin,
        :train_date_end,
        :train_content,
        :user_id,
        :train_type,
        :number_of_students,
        :remarks))
      if Time.zone.parse(vip_halls_trainer_params['train_date_end']) >= Time.zone.parse(vip_halls_trainer_params['train_date_begin'])
        length_of_training_time      = ((Time.zone.parse(vip_halls_trainer_params['train_date_end'])-Time.zone.parse(vip_halls_trainer_params['train_date_begin']))/60).to_i
        total_accepted_training_time = length_of_training_time * vip_halls_trainer_params['number_of_students'].to_i
        @vip_halls_trainer.update(
            length_of_training_time: length_of_training_time,
            total_accepted_training_time: total_accepted_training_time
        )
      else
        response_json [], status: :unprocessable_entity
      end
      render json: @vip_halls_trainer
    else
      render json: @vip_halls_trainer.errors, status: :unprocessable_entity
    end
  end

  # GET /vip_halls_trainers/month_options
  def month_options
    query = VipHallsTrain.where(location_id: params[:location_id]).order('train_month desc').select('id','train_month').map do |item|
      data = {}
      data['id'] = item['id']
      data['train_month'] = item['train_month'].strftime('%Y/%m')
      data
    end
    response_json query
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vip_halls_trainer
      @vip_halls_trainer = VipHallsTrainer.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def vip_halls_trainer_params
      params.require(:vip_halls_trainer).permit(*VipHallsTrainer.create_params)
    end

    def search_query
      case params[:inspector]
        when 'hr' then
          @vip_halls_train_id = params[:vip_halls_train_id].to_i
          query = VipHallsTrainer
                      .includes(:user)
                      .where(vip_halls_train_id: @vip_halls_train_id)
        else
          default_train_month = VipHallsTrain
                                    .where(location_id: params[:location_id])
                                    .order('train_month desc')
                                    .first&.train_month
          if params[:train_month]
            default_train_month = Time.zone.parse(params[:train_month])
          end
          @vip_halls_train_id = VipHallsTrain
                                   .where(location_id: params[:location_id])
                                   .where(train_month: default_train_month)
                                   .first&.id
          query = VipHallsTrainer
                      .includes(:user)
                      .where(vip_halls_train_id: @vip_halls_train_id)
      end
      query
    end
end
