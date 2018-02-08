# coding: utf-8
class CompensateReportsController < ApplicationController
  include GenerateXlsxHelper
  def index
    # authorize CompensateReport
    params[:page] ||= 1
    meta = {}
    all_result = search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    result.each do |report|
      if (report.user_id == 62 && report.year_month == 201201) ||
         (report.user_id == 62 && report.year_month == 201202) ||
         (report.user_id == 68 && report.year_month == 201201) ||
         (report.user_id == 68 && report.year_month == 201202) ||
         (report.user_id == 69 && report.year_month == 201201) ||
         (report.user_id == 69 && report.year_month == 201202)
      else
        # report.refresh_data(report.year, report.month)
      end
    end

    final_result = format_result(result.as_json(include: [], methods: []))

    response_json final_result, meta: meta
  end

  def header_options
    render json: {
             department: Department.where.not(id: 1),
             position: Position.where.not(id: 1),
             company: Config.get_all_option_from_selects(:company_name)
           }
  end

  def options
    result = {}

    result[:record_types] = self.class.record_type_table

    response_json result.as_json
  end

  def all_info
    all = {}
    all[:all_reports] = CompensateReport.all
    all[:all_counts] = CompensateReport.all.count
    response_json all.as_json
  end

  def export_xlsx
    authorize CompensateReport
    all_result = search_query
    final_result = format_result(all_result.as_json(include: [], methods: []))
    compensate_report_export_num = Rails.cache.fetch('compensate_report_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + compensate_report_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('compensate_report_export_number_tag', compensate_report_export_num+1)

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'CompensateReportsController', table_fields_methods: 'get_compensate_report_table_fields', table_fields_args: [], my_attachment: my_attachment, sheet_name: 'CompensateReportTable')
    render json: my_attachment
  end

  private

  def search_query
    tag = false

    # date = Time.zone.now.to_date

    # start_date = Time.zone.parse(params[:start_time]).to_date
    # end_date = Time.zone.parse(params[:end_time]).to_date

    # (start_date .. end_date).map { |d| "#{d.year}_#{d.month}" }.uniq.each do |d|
    #   year = d.split("_").first.to_i
    #   month = d.split("_").second.to_i
    #   ama = AttendMonthApproval.where(month: "#{year}/#{month.to_s.rjust(2, "0")}", status: 'approval').first
    #   if ama
    #     CompensateReport.delete_reports(year, month)
    #     CompensateReport.generate_reports(year, month)
    #   end
    # end

    reports = CompensateReport
                .by_company(params[:company])
                .by_department_ids(params[:department], params[:start_time], params[:end_time])
                .by_position_ids(params[:position], params[:start_time], params[:end_time])
                .by_users(params[:user_ids])
                .by_year_month(params[:start_time], params[:end_time])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      pair_sort_key_order = "pair_sort_key asc"
      pair_sort_key_order_with_self = "compensate_reports.pair_sort_key asc"

      if params[:sort_column] == 'empoid'
        reports = reports.includes(:user).order(pair_sort_key_order_with_self, "users.#{params[:sort_column]} #{params[:sort_direction]}")
      elsif params[:sort_column] == 'department'
        reports = reports.order(pair_sort_key_order, "department_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user'
        reports = reports.order(pair_sort_key_order, "user_id #{params[:sort_direction]}")
      else
        reports = reports.order(pair_sort_key_order, "#{params[:sort_column]} #{params[:sort_direction]}")
      end
      tag = true
    end

    reports = reports.order(pair_sort_key: :asc, created_at: :desc) if tag == false
    reports
  end

  def format_result(json)
    json.map do |hash|
      user = hash['user_id'] ? User.find(hash['user_id']) : nil
      y_m = "#{hash['year_month']}01"
      d = Time.zone.parse(y_m).to_date.end_of_month
      hash['user'] = user ?
      {
        id: hash['user_id'],
        chinese_name: user['chinese_name'],
        english_name: user['english_name'],
        simple_chinese_name: user['chinese_name'],
        empoid: user['empoid'],
      } : nil

      hash['company'] = user ? user&.company_name : nil

      # department = user ? user.department : nil
      # hash['department'] = department ?
      # {
      #   id: department['id'],
      #   chinese_name: department['chinese_name'],
      #   english_name: department['english_name'],
      #   simple_chinese_name: department['chinese_name']
      # } : nil

      department = user ? ProfileService.department(user, d) : nil
      hash['department'] = department ?
      {
        id: department['id'],
        chinese_name: department['chinese_name'],
        english_name: department['english_name'],
        simple_chinese_name: department['chinese_name']
      } : nil

      position = user ? ProfileService.position(user, d) : nil
      hash['position'] = position ?
      {
        id: position['id'],
        chinese_name: position['chinese_name'],
        english_name: position['english_name'],
        simple_chinese_name: position['chinese_name']
      } : nil

      hash['record_type_name'] = find_name_for(hash['record_type'], self.class.record_type_table)

      hash
    end
  end

  def find_name_for(type, table)
    table.select { |op| op[:key] == type }.first
  end

  def self.record_type_table
    [
      {
        key: 'original',
        chinese_name: '原記錄',
        english_name: 'Original',
        simple_chinese_name: '原纪录',
      },

      {
        key: 'compensate',
        chinese_name: '補薪記錄',
        english_name: 'Compensate',
        simple_chinese_name: '补薪记录',
      },
    ]
  end

  def self.get_compensate_report_table_fields
    year_dict = {
      chinese_name: '年',
      english_name: '/',
      simple_chinese_name: '年',
    }
    month_dict = {
      chinese_name: '月',
      english_name: '',
      simple_chinese_name: '月',
    }

    empoid = {
      chinese_name: '員工編號',
      english_name: 'empoid',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        # user = User.find(rst["user_id"])
        # user["empoid"].rjust(8, '0')
        "\s#{rst["user"][:empoid].rjust(8, '0')}"
      }
    }

    name = {
      chinese_name: '員工姓名',
      english_name: 'Name',
      simple_chinese_name: '员工姓名',
      get_value: -> (rst, options){
        rst["user"][options[:name_key]]
      }
    }

    department = {
      chinese_name: '部門',
      english_name: 'Department',
      simple_chinese_name: '部门',
      get_value: -> (rst, options){
        rst['department'] ? rst['department'][options[:name_key]] : ''
      }
    }

    record_type = {
      chinese_name: '記錄類別',
      english_name: 'Record Type',
      simple_chinese_name: '记录类别',
      get_value: -> (rst, options){
        # rst['record_type'] == 'original' ? 'Original' : 'Compensate'
        rst['record_type'] ? record_type_table.select { |op| op[:key] == rst['record_type'] }.first[options[:name_key]] : ''
      }
    }

    year_month = {
      chinese_name: '補薪月份',
      english_name: 'Compensate Month',
      simple_chinese_name: '补薪月份',
      get_value: -> (rst, options){
        ans = ""
        if rst['year_month']
          year = rst['year_month'].to_s[0..3]
          month = rst['year_month'].to_s[4..5]
          year_text = year_dict[options[:name_key]]
          month_text = month_dict[options[:name_key]]
          ans = "#{year}#{year_text}#{month}#{month_text}"
        end
        ans
      }
    }

    year = {
      chinese_name: '年度',
      english_name: 'Year',
      simple_chinese_name: '年度',
      get_value: -> (rst, options){
        rst['year'] ? rst['year'] : ''
      }
    }

    month = {
      chinese_name: '月份',
      english_name: 'Month',
      simple_chinese_name: '月份',
      get_value: -> (rst, options){
        rst['month'] ? rst['month'] : ''
      }
    }

    base_table_fields = [empoid, name, department, record_type, year_month, year, month]

    fmt_table_fields = Config.get('attend_report')["attend_report_fields"].map do |field|
      {
        chinese_name: field["chinese_name"],
        english_name: field["english_name"],
        simple_chinese_name: field["simple_chinese_name"],
        get_value: -> (rst, option) {
          rst[field['key']] ? rst[field['key']] : ""
        }
      }
    end

    table_fields = base_table_fields + fmt_table_fields
  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '補薪報表'
    elsif select_language.to_s == 'english_name'
      'Compensate Report'
    else
      '补薪报表'
    end
  end
end
