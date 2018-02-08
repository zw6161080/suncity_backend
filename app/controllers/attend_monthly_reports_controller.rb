# coding: utf-8
class AttendMonthlyReportsController < ApplicationController
  include GenerateXlsxHelper
  def index
    # authorize AttendMonthlyReport
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
        report.status = 'calculated'
        report.save
      else
        # now = Time.zone.now
        # if ((now - report.updated_at) / 1.minute) > 30
        if report.status == 'not_calc' || report.status == nil
          # report.status = 'not_calc'
          # report.save
          RefreshAttendMonthlyReportJob.perform_later(report)
        end
      end
    end

    final_result = format_result(result.as_json(include: [], methods: []))

    response_json final_result, meta: meta
  end

  def options
    render json: {
             department: Department.where.not(id: 1),
             position: Position.where.not(id: 1),
             company: Config.get_all_option_from_selects(:company_name)
           }
  end

  def create_fake_data_reports
    AttendMonthlyReport.create_fake_data_reports
    response_json :ok
  end

  def export_xlsx
    authorize AttendMonthlyReport
    all_result = search_query
    final_result = format_result(all_result.as_json(include: [], methods: []))
    language = select_language.to_s
    attend_monthly_report_export_num = Rails.cache.fetch('attend_monthly_report_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + attend_monthly_report_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('attend_monthly_report_export_number_tag', attend_monthly_report_export_num+1)

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'AttendMonthlyReportsController', table_fields_methods: 'get_attend_monthly_report_table_fields', table_fields_args: [], my_attachment: my_attachment, sheet_name: 'AttendMonthlyReportTable')
    render json: my_attachment
  end

  private

  def search_query
    tag = false
    # region = params[:region] || 'macau'
    # lang_key = params[:lang] || 'zh-TW'

    # lang = if lang_key == 'zh-TW'
    #          'chinese_name'
    #        elsif lang_key == 'zh-US'
    #          'english_name'
    #        else
    #          'simple_chinese_name'
    #        end

    AttendMonthlyReport.complete_table_for(params[:company],
                                           params[:department],
                                           params[:position],
                                           params[:user_ids],
                                           params[:start_time],
                                           params[:end_time])

    reports = AttendMonthlyReport
                .by_company(params[:company])
                .by_department_ids(params[:department], params[:start_time], params[:end_time])
                .by_position_ids(params[:position], params[:start_time], params[:end_time])
                .by_users(params[:user_ids])
                .by_year_month(params[:start_time], params[:end_time])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      if params[:sort_column] == 'empoid'
        reports = reports.includes(:user).order("users.#{params[:sort_column]} #{params[:sort_direction]}")
      elsif params[:sort_column] == 'department'
        reports = reports.order("department_id #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user'
        reports = reports.order("user_id #{params[:sort_direction]}")
      else
        reports = reports.order("#{params[:sort_column]} #{params[:sort_direction]}")
      end
      tag = true
    end

    reports = reports.includes(:user).order("attend_monthly_reports.year desc", "attend_monthly_reports.month desc", "users.empoid asc") if tag == false
    reports
  end

  def format_result(json)
    json.map do |hash|
      user = hash['user_id'] ? User.find(hash['user_id']) : nil
      y = hash['year'].to_i
      m = hash['month'].to_i
      d = Time.zone.local(y, m, 1).to_date.end_of_month

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

      hash
    end
  end

  def self.get_attend_monthly_report_table_fields
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

    base_table_fields = [empoid, name, department, year, month]

    table_fields = base_table_fields + fmt_table_fields
  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '考勤月報報表'
    elsif select_language.to_s == 'english_name'
      'Attend Monthly Report'
    else
      '考勤月报报表'
    end
  end
end
