# coding: utf-8
class JobTransfersController < ApplicationController
  include SortParamsHelper
  def index
    authorize JobTransfer
    sort_column = sort_column_sym(params[:sort_column], :apply_date)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query.order_by(sort_column , sort_direction)
    query = query.page.page(params.fetch(:page, 1)).per(20)
    meta = {
      total_count: query.total_count,
      current_page: query.current_page,
      total_pages: query.total_pages,
      sort_column: sort_column.to_s,
      sort_direction: sort_direction.to_s,
    }
    render json: query, status: 200, root: 'data', meta: meta, include: '**'
  end

  def options
    response_json JobTransfer.options
  end

  def export_xlsx
    authorize JobTransfer
    sort_column = sort_column_sym(params[:sort_column], :apply_date)
    sort_direction = sort_direction_sym(params[:sort_direction], :desc)
    query = search_query.order_by(sort_column , sort_direction)
    final_result =  ActiveModelSerializers::SerializableResource.new(query, each_serializer: JobTransferSerializer, include: "**", adapter: :attributes).as_json
    final_result = final_result.map{|hash| hash.with_indifferent_access}
    job_transfer_export_num = Rails.cache.fetch('job_transfer_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+job_transfer_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('job_transfer_export_number_tag', job_transfer_export_num+1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json), controller_name: 'JobTransfersController', table_fields_methods: 'get_job_transfer_table_fields', table_fields_args: [],my_attachment: my_attachment, sheet_name: 'JobTransferTable')
    render json: my_attachment
  end

  private

  def search_query
    lang = select_language
    apply_date_begin = Time.zone.parse(params[:apply_date_begin]).to_date rescue nil
    apply_date_start = Time.zone.parse(params[:apply_date_start]).to_date rescue nil
    position_start_date_begin = Time.zone.parse(params[:position_start_date_begin]).to_date rescue nil
    position_start_date_end = Time.zone.parse(params[:position_start_date_end]).to_date rescue nil
    position_end_date_begin = Time.zone.parse(params[:position_end_date_begin]).to_date rescue nil
    position_end_date_end = Time.zone.parse(params[:position_end_date_end]).to_date rescue nil
    trial_expiration_date_begin = Time.zone.parse(params[:trial_expiration_date_begin]).to_date rescue nil
    trial_expiration_date_end = Time.zone.parse(params[:trial_expiration_date_end]).to_date rescue nil
    input_date_begin = Time.zone.parse(params[:input_date_begin]).to_date rescue nil
    input_date_end = Time.zone.parse(params[:input_date_end]).to_date rescue nil
    date_of_employment_begin = Time.zone.parse(params[:date_of_employment_begin]).strftime("%Y/%m/%d") rescue nil
    date_of_employment_end = Time.zone.parse(params[:date_of_employment_end]).strftime("%Y/%m/%d") rescue nil
    position_resigned_date_begin = Time.zone.parse(params[:position_resigned_date_begin]).strftime("%Y/%m/%d") rescue nil
    position_resigned_date_end = Time.zone.parse(params[:position_resigned_date_end]).strftime("%Y/%m/%d") rescue nil

    JobTransfer.join_user_and_profile
        .by_date_of_employment(params[:date_of_employment_begin], params[:date_of_employment_end])
        .by_position_resigned_date(params[:position_resigned_date_begin], params[:position_resigned_date_end])
        .by_date_of_employment(date_of_employment_begin, date_of_employment_end)
        .by_position_resigned_date(position_resigned_date_begin, position_resigned_date_end)
        .by_apply_date(apply_date_begin, apply_date_start)
        .by_apply_result(params[:apply_result])
        .by_employee_name(params[:employee_name], lang)
        .by_empoid(params[:empoid])
        .by_position_start_date(position_start_date_begin, position_start_date_end)
        .by_position_end_date(position_end_date_begin, position_end_date_end)
        .by_trial_expiration_date(trial_expiration_date_begin, trial_expiration_date_end)
        .by_inputter(params[:inputter], lang)
        .by_input_date(input_date_begin, input_date_end)
        .by_transfer_type(params[:transfer_type], lang)
        .by_salary_calculation(params[:salary_calculation], lang)
        .by_new_location_id(params[:new_location])
        .by_new_department_id(params[:new_department])
        .by_new_position_id(params[:new_position])
        .by_new_grade(params[:new_grade])
        .by_original_location_id(params[:original_location])
        .by_original_department_id(params[:original_department])
        .by_original_position_id(params[:original_position])
        .by_original_grade(params[:original_grade])
        .by_new_company_name(params[:new_company_name], lang)
        .by_original_company_name(params[:original_company_name], lang)
        .by_new_employment_status(params[:new_employment_status], lang)
        .by_original_employment_status(params[:original_employment_status], lang)
  end


  def self.get_job_transfer_table_fields
    apply_date ={
      chinese_name: '申请日期',
      english_name: 'Apply date',
      simple_chinese_name: '申请日期',
      get_value: -> (rst, options){
        rst["apply_date"] ? Time.zone.parse(rst["apply_date"]).strftime('%Y/%m/%d') : nil
      }
    }

    name = {
      chinese_name: '員工姓名',
      english_name: 'Name',
      simple_chinese_name: '员工姓名',
      get_value: -> (rst, options){
        rst["user"] ? rst["user"][options[:name_key]] : nil
      }
    }

    date_of_employment = {
      chinese_name: '入職日期',
      english_name: 'Entry date',
      simple_chinese_name: '入職日期',
      get_value: -> (rst, options){
        rst['user'] ? rst['user']['profile']['data']['position_information']['field_values']['date_of_employment'] : nil
      }
    }

    position_resigned_date = {
      chinese_name: '離職日期',
      english_name: 'Date of departure',
      simple_chinese_name: '離職日期',
      get_value: -> (rst, options){
        rst['user'] ? rst['user']['profile']['data']['position_information']['field_values']['resigned_date'] : nil
      }
    }

    employee_id = {
      chinese_name: '員工編號',
      english_name: 'ID',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        rst['user']['empoid'] rescue nil
      }
    }

    transfer_type = {
      chinese_name: '調配類型',
      english_name: 'Deployment type',
      simple_chinese_name: '调配类型',
      get_value: -> (rst, options){
        rst["transfer_type"] ? JobTransfer.transfer_types.find { |opt| opt[:key] == rst["transfer_type"]} : nil
      }
    }

    position_start_date = {
      chinese_name: '職位開始日期',
      english_name: 'Start date',
      simple_chinese_name: '职位开始日期',
      get_value: -> (rst, options){
        rst["position_start_date"] ? Time.zone.parse(rst["position_start_date"]).strftime('%Y/%m/%d') : nil
      }
    }

    position_end_date = {
      chinese_name: '職位結束日期',
      english_name: 'End date',
      simple_chinese_name: '职位结束日期',
      get_value: -> (rst, options){
        rst["position_end_date"] ? Time.zone.parse(rst["position_end_date"]).strftime('%Y/%m/%d') : nil
      }
    }

    apply_result = {
      chinese_name: '申請結果',
      english_name: 'Application results',
      simple_chinese_name: '申请结果',
      get_value: -> (rst, options){
        if rst['apply_result']
          {
            key: true,
            chinese_name: '通過',
            simple_chinese_name: '通过',
            english_name: 'pass',
          }[options[:name_key]]
        else
          {
            key: false,
            chinese_name: '未通過',
            simple_chinese_name: '未通过',
            english_name: 'failed'
          }[options[:name_key]]
        end
      }
    }

    trial_expiration_date = {
      chinese_name: '試用期期滿日期',
      english_name: 'Expiration date',
      simple_chinese_name: '试用期期满日期',
      get_value: -> (rst, options){
        rst["trial_expiration_date"] ? Time.zone.parse(rst["trial_expiration_date"]).strftime('%Y/%m/%d') : nil
      }
    }

    salary_calculation = {
      chinese_name: '薪酬計算',
      english_name: 'Salary count',
      simple_chinese_name: '薪酬计算',
      get_value: -> (rst, options){
        rst["salary_calculation"] ? Config.get_single_option('salary_calculation', rst["salary_calculation"]): nil
      }
    }

    new_company_name = {
      chinese_name: '新公司',
      english_name: 'New company',
      simple_chinese_name: '新公司',
      get_value: -> (rst, options){
        rst["new_company_name"] ? Config.get_single_option('company_name', rst["new_company_name"]) : nil
      }
    }

    new_location = {
      chinese_name: '新場館',
      english_name: 'New location',
      simple_chinese_name: '新场馆',
      get_value: -> (rst, options){
        rst["new_location"] ? rst["new_location"][options[:name_key]] : nil
      }
    }

    new_department = {
      chinese_name: '新部門',
      english_name: 'New department',
      simple_chinese_name: '新部门',
      get_value: -> (rst, options){
        rst["new_department"] ? rst["new_department"][options[:name_key]] : nil
      }
    }

    new_position = {
      chinese_name: '新職位',
      english_name: 'New position',
      simple_chinese_name: '新职位',
      get_value: -> (rst, options){
        rst["new_position"] ? rst["new_position"][options[:name_key]] : nil
      }
    }

    new_group = {
      chinese_name: '新組別',
      english_name: 'New group',
      simple_chinese_name: '新组别',
      get_value: -> (rst, options){
        rst["new_group"] ? rst["new_group"][options[:name_key]] : nil
      }
    }

    new_grade = {
      chinese_name: '新職級',
      english_name: 'New grade',
      simple_chinese_name: '新职级',
      get_value: -> (rst, options){
        rst["new_grade"]
      }
    }

    new_employment_status  = {
      chinese_name: '新在職類別',
      english_name: 'New job category',
      simple_chinese_name: '新在职类别',
      get_value: -> (rst, options){
        rst["new_employment_status"] ? Config.get_single_option('employment_status', rst["new_employment_status"]) : nil
      }
    }

    instructions = {
      chinese_name: '調配說明',
      english_name: 'Deployment instructions',
      simple_chinese_name: '调配说明',
      get_value: -> (rst, options){
        rst["instructions"]
      }
    }

    original_company_name = {
      chinese_name: '原公司',
      english_name: 'Original company',
      simple_chinese_name: '原公司',
      get_value: -> (rst, options){
        rst["original_company_name"] ?  Config.get_single_option('company_name', rst["original_company_name"]) : nil
      }
    }

    original_location = {
      chinese_name: '原場館',
      english_name: 'Original location',
      simple_chinese_name: '原场馆',
      get_value: -> (rst, options){
        rst["original_location"] ? rst["original_location"][options[:name_key]] : nil
      }
    }

    original_department = {
      chinese_name: '原部門',
      english_name: 'Original department',
      simple_chinese_name: '原部门',
      get_value: -> (rst, options){
        rst["original_department"] ? rst["original_department"][options[:name_key]] : nil
      }
    }

    original_position = {
      chinese_name: '原職位',
      english_name: 'Original position',
      simple_chinese_name: '原职位',
      get_value: -> (rst, options){
        rst["original_position"] ? rst["original_position"][options[:name_key]] : nil
      }
    }

    original_group = {
      chinese_name: '新組別',
      english_name: 'Griginal group',
      simple_chinese_name: '新组别',
      get_value: -> (rst, options){
        rst["original_group"] ? rst["original_group"][options[:name_key]] : nil
      }
    }

    original_grade = {
      chinese_name: '原職級',
      english_name: 'Original grade',
      simple_chinese_name: '原职级',
      get_value: -> (rst, options){
        rst["original_grade"]
      }
    }

    original_employment_status = {
      chinese_name: '原在職類別',
      english_name: 'Original job category',
      simple_chinese_name: '原在职类别',
      get_value: -> (rst, options){
        rst["original_employment_status"] ?  Config.get_single_option('employment_status', rst["original_employment_status"]) : nil
      }
    }

    inputter = {
      chinese_name: '錄入人',
      english_name: 'Inputer',
      simple_chinese_name: '录入人',
      get_value: -> (rst, options){
        rst["inputter"] ? rst["inputter"][options[:name_key]] : nil
      }
    }

    input_date = {
      chinese_name: '錄入日期',
      english_name: 'Input Date',
      simple_chinese_name: '录入日期',
      get_value: -> (rst, options){
        rst["input_date"] ? Time.zone.parse(rst["input_date"]).strftime('%Y/%m/%d') : nil
      }
    }

    comment = {
      chinese_name: '備註',
      english_name: 'Remarks',
      simple_chinese_name: '备注',
      get_value: -> (rst, options){
        rst["comment"]
      }
    }

    table_fields = [ apply_date, name, date_of_employment, position_resigned_date,employee_id, transfer_type, position_start_date, position_end_date,
                     apply_result, trial_expiration_date, salary_calculation,
                     new_company_name, new_location, new_department, new_position, new_grade, new_employment_status, instructions,
                     original_company_name, original_location, original_department, original_position, original_grade, original_employment_status,
                     inputter, input_date, comment ]

  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '職位調配記錄'
    elsif select_language.to_s == 'english_name'
      'Job placement record'
    else
      '职位调配记录'
    end

  end
end
