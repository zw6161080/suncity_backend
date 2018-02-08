class TrainRecordByTrainsController < ApplicationController

  include SortParamsHelper
  include GenerateXlsxHelper

  # GET /train_record_by_trains
  def index
    authorize TrainRecordByTrain
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
    if [:train_id, :train_number, :train_date, :train_type, :train_cost, :satisfaction_degree].include?(sort_column)
      case sort_column
        when :train_id then
          query = query
                      .order("train_id #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
        when :train_number then
          query = query.includes(:train)
                      .order("trains.train_number #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
        when :train_date then
          query = query.includes(:train)
                      .order("trains.train_date_begin #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
        when :train_type then
          query = query.includes(train: :train_template_type)
                      .order("train_template_types.id #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
        when :train_cost then
          query = query.includes(:train)
                      .order("trains.train_cost #{sort_direction}")
                      .page
                      .page(params.fetch(:page, 1))
                      .per(20)
        when :satisfaction_degree then
          query = query.includes(:train)
                  .order("trains.satisfaction_percentage #{sort_direction}")
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
    data = query.map do |record|
      record.get_json_data
    end
    response_json data.as_json, meta: meta
  end

  # GET /train_record_by_trains/export
  def export
    authorize TrainRecordByTrain
    # 数据查询
    sort_column = sort_column_sym(params[:sort_column], 'created_at')
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query
    if [:train_id, :train_number, :train_date, :train_type, :train_cost].include?(sort_column)
      case sort_column
        when :train_id then
          query = query.order("train_id #{sort_direction}")
        when :train_number then
          query = query.includes(:train).order("trains.train_number #{sort_direction}")
        when :train_date then
          query = query.includes(:train).order("trains.train_date_begin #{sort_direction}")
        when :train_type then
          query = query.includes(train: :train_template_type).order("train_template_types.id #{sort_direction}")
        when :train_cost then
          query = query.includes(:train).order("trains.train_cost #{sort_direction}")
      end
    else
      query = query.order(sort_column => sort_direction)
    end
    data = query.map do |record|
      record.get_json_data
    end
    # 数据筛选
    selected_data = data.map do |record|
      one_record = {}
      one_record[:train_number]        = record.dig 'train.train_number'
      one_record[:train_date]          = "#{record.dig('train.train_date_begin').strftime('%Y/%m/%d')} ~ #{record.dig('train.train_date_end').strftime('%Y/%m/%d')}"
      one_record[:train_cost]          = record.dig('train.train_cost').to_s
      one_record[:final_list_count]    = record.dig 'final_list_count'
      one_record[:entry_list_count]    = record.dig 'entry_list_count'
      one_record[:invited_count]       = record.dig 'invited_count'
      one_record[:attendance_rate]     = record.dig('attendance_rate').to_s+'%'
      one_record[:passing_rate]        = record.dig('passing_rate').to_s+'%'
      one_record[:satisfaction_degree] = record.dig('satisfaction_degree').to_s+'%'
      if I18n.locale==:en
        one_record[:train_name]        = record.dig 'train.english_name'
        one_record[:train_type]        = record.dig 'train.train_template_type.english_name'
      elsif I18n.locale==:'zh-CN'
        one_record[:train_name]        = record.dig 'train.simple_chinese_name'
        one_record[:train_type]        = record.dig 'train.train_template_type.simple_chinese_name'
      else
        one_record[:train_name]        = record.dig 'train.chinese_name'
        one_record[:train_type]        = record.dig 'train.train_template_type.chinese_name'
      end
      one_record
    end
    # 生成Excel
    xlsx_data = {
        fields: {:train_name          => I18n.t('train_record_by_train.header.train_name'),
                 :train_number        => I18n.t('train_record_by_train.header.train_number'),
                 :train_date          => I18n.t('train_record_by_train.header.train_date'),
                 :train_type          => I18n.t('train_record_by_train.header.train_type'),
                 :train_cost          => I18n.t('train_record_by_train.header.train_cost'),
                 :final_list_count    => I18n.t('train_record_by_train.header.final_list_count'),
                 :entry_list_count    => I18n.t('train_record_by_train.header.entry_list_count'),
                 :invited_count       => I18n.t('train_record_by_train.header.invited_count'),
                 :attendance_rate     => I18n.t('train_record_by_train.header.attendance_rate'),
                 :passing_rate        => I18n.t('train_record_by_train.header.passing_rate'),
                 :satisfaction_degree => I18n.t('train_record_by_train.header.satisfaction_degree') },
        records: selected_data,
    }
    response.headers['Access-Control-Expose-Headers'] = 'Content-Disposition'
    train_record_by_train_export_number_tag = Rails.cache.fetch('train_record_by_train_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+train_record_by_train_export_number_tag.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('train_record_by_train_export_number_tag', train_record_by_train_export_number_tag+1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: I18n.t('train_record_by_train.filename')+Time.zone.now.strftime('%Y%m%d')+export_id.to_s+'.xlsx')
    GenerateTableJob.perform_later(data: xlsx_data, my_attachment: my_attachment)
    render json: my_attachment
  end

  # POST /train_record_by_trains
  def create
    final_list_count = 0
    entry_list_count = 0
    invited_count    = 0
    attendance_rate     = '100.00'
    passing_rate        = '100.00'
    train_record_by_train = TrainRecordByTrain.create(train_record_by_train_params.as_json.merge(
        final_list_count:    final_list_count,
        entry_list_count:    entry_list_count,
        invited_count:       invited_count,
        attendance_rate:     attendance_rate,
        passing_rate:        passing_rate,
    ))
    response_json train_record_by_train
  end

  # GET /train_record_by_trains/columns
  def columns
    render json: [
        {key: 'head',                chinese_name: '按培訓課程',  english_name: 'According to Courses',           simple_chinese_name: '按培训课程'},
        {key: 'train_name',          chinese_name: '培訓名稱',    english_name: 'Training name',                  simple_chinese_name: '培训名称'},
        {key: 'train_number',        chinese_name: '培訓編號',    english_name: 'Training number',                simple_chinese_name: '培训编号'},
        {key: 'train_date',          chinese_name: '培訓日期',    english_name: 'Training date',                  simple_chinese_name: '培训日期'},
        {key: 'train_type',          chinese_name: '培訓種類',    english_name: 'Training category',              simple_chinese_name: '培训种类'},
        {key: 'train_cost',          chinese_name: '培訓總費用',  english_name: 'Total training costs',           simple_chinese_name: '培训总费用'},
        {key: 'final_list_count',    chinese_name: '培訓人數',    english_name: 'Number of participants',         simple_chinese_name: '培训人数'},
        {key: 'entry_list_count',    chinese_name: '培訓報名人數', english_name: 'Number of training applicants',  simple_chinese_name: '培训报名人数'},
        {key: 'invited_count',       chinese_name: '培訓受邀人數', english_name: 'Number of training invitations', simple_chinese_name: '培训受邀人数'},
        {key: 'attendance_rate',     chinese_name: '課程出席率',  english_name: 'Course attendance',              simple_chinese_name: '课程出席率'},
        {key: 'passing_rate',        chinese_name: '學員通過率',  english_name: 'Students passing rate',          simple_chinese_name: '学员通过率'},
        {key: 'satisfaction_degree', chinese_name: '課程滿意度',  english_name: 'Satisfaction',                   simple_chinese_name: '课程满意度'}
    ]
  end

  # GET /train_record_by_trains/options
  def options
    render json: TrainRecordByTrain.options
  end

  private
    # Only allow a trusted parameter "white list" through.
    def train_record_by_train_params
      params.require(:train_record_by_train).permit(*TrainRecordByTrain.create_params)
    end

    def search_query
      query = TrainRecordByTrain.includes(train: :train_template_type)
      {
          train_id:            :by_train_id,
          train_number:        :by_train_number,
          train_date:          :by_train_date,
          train_type:          :by_train_type,
          train_cost:          :by_train_cost,
          final_list_count:    :by_final_list_count,
          entry_list_count:    :by_entry_list_count,
          invited_count:       :by_invited_count,
          attendance_rate:     :by_attendance_rate,
          passing_rate:        :by_passing_rate,
          satisfaction_degree: :by_satisfaction_degree,
      }.each do |key, value|
        query = query.send(value, params[key]) if params[key]
      end
      query
    end

end
