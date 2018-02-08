# coding: utf-8
class AttendAnnualReportsController < ApplicationController
  include GenerateXlsxHelper
  def index
    authorize AttendAnnualReport
    params[:page] ||= 1
    meta = {}
    all_result = search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    result.each do |report|
      # now = Time.zone.now.to_datetime
      # if ((now - report.updated_at.to_datetime) * 24 * 60) > 5
      if report.status == 'not_calc' || report.status == nil
        # report.status = 'not_calc'
        # report.save
        RefreshAttendAnnualReportJob.perform_later(report)
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

  def export_xlsx
    authorize AttendAnnualReport
    all_result = search_query
    final_result = format_result(all_result.as_json(include: [], methods: []))
    attend_annual_report_export_num = Rails.cache.fetch('attend_annual_report_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + attend_annual_report_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('attend_annual_report_export_number_tag', attend_annual_report_export_num+1)

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'AttendAnnualReportsController', table_fields_methods: 'get_attend_annual_report_table_fields', table_fields_args: [], my_attachment: my_attachment, sheet_name: 'AttendAnnualReportTable')
    render json: my_attachment
  end

  private

  def search_query
    tag = false

    AttendAnnualReport.complete_table_for(params[:company],
                                          params[:department],
                                           params[:position],
                                           params[:user_ids],
                                           params[:start_year],
                                           params[:end_year])

    reports = AttendAnnualReport
                .by_company(params[:company])
                .by_department_ids(params[:department], params[:start_year], params[:end_year])
                .by_position_ids(params[:position], params[:start_year], params[:end_year])
                .by_users(params[:user_ids])
                .by_year(params[:start_year], params[:end_year])

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

    reports = reports.includes(:user).order("attend_annual_reports.year desc", "users.empoid asc") if tag == false
    reports
  end

  def format_result(json)
    json.map do |hash|
      user = hash['user_id'] ? User.find(hash['user_id']) : nil
      y = hash['year'].to_i
      d = Time.zone.local(y, 1, 1).to_date.end_of_year
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

  def self.get_attend_annual_report_table_fields
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

    annual_attend_award = {
      chinese_name: '全年勤工獎',
      english_name: 'Annual Attend Award',
      simple_chinese_name: '全年勤工奖',
      get_value: -> (rst, options){
        rst['annual_attend_award'] ? rst['annual_attend_award'] : '0'
      }
    }



    fmt_table_fields = Config.get('attend_report')["attend_report_fields"].map do |field|
      {
        chinese_name: field["chinese_name"],
        english_name: field["english_name"],
        simple_chinese_name: field["simple_chinese_name"],
        get_value: -> (rst, option) {
          rst[field['key']] ? rst[field['key']] : '0'
        }
      }
    end

    base_table_fields = [empoid, name, department, year]

    table_fields = base_table_fields + fmt_table_fields + [annual_attend_award]
  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '考勤年報報表'
    elsif select_language.to_s == 'english_name'
      'Attend Annual Report'
    else
      '考勤年报报表'
    end
  end
end
