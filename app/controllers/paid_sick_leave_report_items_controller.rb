# coding: utf-8
class PaidSickLeaveReportItemsController < ApplicationController
  include GenerateXlsxHelper
  def index
    authorize PaidSickLeaveReportItem
    params[:page] ||= 1
    meta = {}
    all_result = search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    result.each { |r| r.refresh_data }

    final_result = format_result(result.as_json(include: [], methods: []))

    response_json final_result, meta: meta
  end

  def options
    result = {}
    result[:years] = PaidSickLeaveReportItem.pluck(:year).compact.uniq.sort
    response_json result.as_json
  end

  def export_xlsx
    authorize PaidSickLeaveReportItem
    all_result = search_query
    tmp_final_result = format_result(all_result.as_json(include: [], methods: []))
    final_result = tmp_final_result.zip([*1..tmp_final_result.size]).map do |obj_arr|
      obj_arr.first['order_no'] = obj_arr.second
      obj_arr.first
    end

    language = select_language.to_s
    paid_sick_leave_report_export_num = Rails.cache.fetch('paid_sick_leave_report_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + paid_sick_leave_report_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('paid_sick_leave_report_export_number_tag', paid_sick_leave_report_export_num+1)

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'PaidSickLeaveReportItemsController', table_fields_methods: 'get_paid_sick_leave_report_table_fields', table_fields_args: [], my_attachment: my_attachment, sheet_name: 'PSLTable')
    render json: my_attachment
  end

  private

  def search_query
    tag = false

    last_r = PaidSickLeaveReport.order(:created_at).last
    last_r_year = last_r ? last_r.year : nil
    params[:year] ||= last_r_year
    # params[:year] = params[:year].to_i == 0 ? nil : params[:year]

    reports = PaidSickLeaveReportItem
                .by_department_ids(params[:department_ids])
                .by_users(params[:user_ids])
                .by_year(params[:year])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      if params[:sort_column] == 'empoid' || params[:sort_column] == 'department_id' || params[:sort_column] == 'position_id'
        reports = reports.includes(:user).order("users.#{params[:sort_column]} #{params[:sort_direction]}")
      elsif params[:sort_column] == 'department' || params[:sort_column] == 'position'
        sort_column = "#{params[:sort_column]}_id"
        reports = reports.includes(:user).order("users.#{sort_column} #{params[:sort_direction]}")
      elsif params[:sort_column] == 'user'
        sort_column = "#{params[:sort_column]}_id"
        reports = reports.order("#{sort_column} #{params[:sort_direction]}")
      else
        reports = reports.order("#{params[:sort_column]} #{params[:sort_direction]}")
      end
      tag = true
    end

    # reports = reports.order(created_at: :desc) if tag == false
    reports = reports.includes(:user).order("users.empoid asc") if tag == false
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
        date_of_employment: user.profile.data['position_information']['field_values']['date_of_employment']
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

      hash
    end
  end

  def self.get_paid_sick_leave_report_table_fields
    order_no= {
      chinese_name: '序號',
      english_name: 'order_no',
      simple_chinese_name: '序号',
      get_value: -> (rst, options){
        rst["order_no"]
      }
    }

    empoid= {
      chinese_name: '員工編號',
      english_name: 'empoid',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        "\s#{rst["user"][:empoid].rjust(8, '0')}"
      }
    }

    name = {
      chinese_name: '員工姓名',
      english_name: 'Name',
      simple_chinese_name: '员工姓名',
      get_value: -> (rst, options){
        rst["user"] ? rst["user"][options[:name_key]] : ''
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

    date_of_employment = {
      chinese_name: '入職日期',
      english_name: 'Date of Employment',
      simple_chinese_name: '入职日期',
      get_value: -> (rst, options){
        rst["user"] ? rst["user"][:date_of_employment] : ''
      }
    }

    on_duty_days = {
      chinese_name: '在職天數',
      english_name: 'On Duty Days',
      simple_chinese_name: '在职天数',
      get_value: -> (rst, options){
        rst['on_duty_days'] ? rst['on_duty_days'] : ''
      }
    }

    paid_sick_leave_counts = {
      chinese_name: '申請有薪病假天數',
      english_name: 'Paid Sick Leave Count',
      simple_chinese_name: '申请有薪病假天数',
      get_value: -> (rst, options){
        rst['paid_sick_leave_counts'] ? rst['paid_sick_leave_counts'] : ''
      }
    }

    obtain_counts = {
      chinese_name: '獲得天數',
      english_name: 'Obtain Count',
      simple_chinese_name: '获得天数',
      get_value: -> (rst, options){
        rst['obtain_counts'] ? rst['obtain_counts'] : ''
      }
    }

    table_fields = [order_no, empoid, name, department, position, date_of_employment,
                    on_duty_days, paid_sick_leave_counts, obtain_counts]


  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '有薪病假獎勵假報表'
    elsif select_language.to_s == 'english_name'
      'Paid Sick Leave Report Table'
    else
      '有薪病假奖励假报表'
    end
  end
end
