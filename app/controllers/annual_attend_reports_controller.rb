# coding: utf-8
class AnnualAttendReportsController < ApplicationController
  include GenerateXlsxHelper
  def index
    authorize AnnualAttendReport
    params[:page] ||= 1
    meta = {}
    all_result = search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    final_result = format_result(result.as_json(include: [], methods: []))

    response_json final_result, meta: meta
  end

  def options
    result = {}
    result[:years] = AnnualAttendReport.pluck(:year).compact.uniq.sort
    response_json result.as_json
  end

  def export_xlsx
    authorize AnnualAttendReport
    all_result = search_query
    final_result = format_result(all_result.as_json(include: [], methods: []))
    annual_attend_report_export_num = Rails.cache.fetch('annual_attend_report_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + annual_attend_report_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('annual_attend_report_export_number_tag', annual_attend_report_export_num+1)

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'AnnualAttendReportsController', table_fields_methods: 'get_annual_attend_report_table_fields', table_fields_args: [], my_attachment: my_attachment, sheet_name: 'AnnualAttendTable')
    render json: my_attachment
  end

  private

  def search_query
    tag = false
    reports = AnnualAttendReport
                .by_department_ids(params[:department_id])
                .by_users(params[:user_ids])
                .by_year(params[:year])
                .by_is_meet(params[:is_meet])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      default_order = "created_at DESC"
      default_order_with_self = "annual_attend_reports.created_at DESC"

      if params[:sort_column] == 'empoid' || params[:sort_column] == 'department_id' || params[:sort_column] == 'position_id'
        reports = reports.includes(:user).order("users.#{params[:sort_column]} #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'department' || params[:sort_column] == 'position'
        sort_column = "#{params[:sort_column]}_id"
        reports = reports.includes(:user).order("users.#{sort_column} #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'user'
        sort_column = "#{params[:sort_column]}_id"
        reports = reports.order("#{sort_column} #{params[:sort_direction]}", default_order)
      else
        reports = reports.order("#{params[:sort_column]} #{params[:sort_direction]}", default_order)
      end
      tag = true
    end

    # reports = reports.order(created_at: :desc) if tag == false
    reports = reports.includes(:user).order("annual_attend_reports.year desc", "users.empoid asc") if tag == false
    reports
  end

  def format_result(json)
    json.map do |hash|
      user = hash['user_id'] ? User.find(hash['user_id']) : nil
      hash['user'] = user ?
      {
        id: hash['user_id'],
        chinese_name: user['chinese_name'],
        english_name: user['english_name'],
        simple_chinese_name: user['chinese_name'],
        empoid: user['empoid'],
      } : nil

      department = user ? user.department : nil
      hash['department'] = department ?
      {
        id: department['id'],
        chinese_name: department['chinese_name'],
        english_name: department['english_name'],
        simple_chinese_name: department['chinese_name']
      } : nil

      position = user ? user.position : nil
      hash['position'] = position ?
      {
        id: position['id'],
        chinese_name: position['chinese_name'],
        english_name: position['english_name'],
        simple_chinese_name: position['chinese_name']
      } : nil

      year = hash['year'].to_i
      aar = AnnualAwardReport.find_by(year_month: Time.zone.local(year, 1, 1).to_datetime)
      aar_item = aar ? AnnualAwardReportItem.find_by(user_id: user.id, annual_award_report_id: aar.id) : nil
      hash['money_hkd'] = aar_item ? aar_item&.annual_at_duty_final_hkd : 0

      aar = AnnualAttendReport.find_by(id: hash['id'].to_i)
      aar.money_hkd = hash['money_hkd']
      aar.save

      hash
    end
  end

  def self.get_annual_attend_report_table_fields
    empoid = {
      chinese_name: '員工編號',
      english_name: 'empoid',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        rst["user"][:empoid].rjust(8, '0')
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

    position = {
      chinese_name: '職位',
      english_name: 'Position',
      simple_chinese_name: '职位',
      get_value: -> (rst, options){
        rst['position'] ? rst['position'][options[:name_key]] : ''
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

    settlement_date = {
      chinese_name: '結算日期',
      english_name: 'Settlemant Date',
      simple_chinese_name: '结算日期',
      get_value: -> (rst, options){
        rst['settlement_date'] ? rst['settlement_date'] : ''
      }
    }

    is_meet = {
      chinese_name: '是否符合',
      english_name: 'Is Meet',
      simple_chinese_name: '是否符合',
      get_value: -> (rst, options){
        rst['is_meet'] ? '是' : '否'
      }
    }

    money_hkd = {
      chinese_name: '金額（HKD）',
      english_name: 'Money (HKD)',
      simple_chinese_name: '金额（HKD）',
      get_value: -> (rst, options){
        rst['money_hkd'].to_i
      }
    }

    table_fields = [empoid, name, department, position, year, settlement_date,
                    is_meet, money_hkd]


  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '全年勤工報表'
    elsif select_language.to_s == 'english_name'
      'Annual Attend Report Table'
    else
      '全年勤工报表'
    end
  end
end
