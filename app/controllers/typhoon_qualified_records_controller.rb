# coding: utf-8
class TyphoonQualifiedRecordsController < ApplicationController
  include GenerateXlsxHelper
  before_action :set_typhoon_qualified_record, only: [:do_apply, :cancel_apply]

  def index
    authorize TyphoonQualifiedRecord
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

  def do_apply
    ActiveRecord::Base.transaction do
      qualify_date = @typhoon_qualified_records.qualify_date
      year, month = "#{qualify_date.year}".rjust(4, '0'), "#{qualify_date.month}".rjust(2, '0')
      fmt_month = "#{year}/#{month}"
      status = AttendMonthApproval.where(month: fmt_month).first.try(:status)
      is_compensate = status == 'approval' ? true : false

      @typhoon_qualified_records.update(is_apply: true, money: 100, is_compensate: is_compensate)

      if is_compensate
        CompensateReport.update_reports(@typhoon_qualified_records)
      else
        AttendMonthlyReport.update_calc_status(@typhoon_qualified_records.user_id, @typhoon_qualified_records.qualify_date)
        AttendAnnualReport.update_calc_status(@typhoon_qualified_records.user_id, @typhoon_qualified_records.qualify_date)
      end

      typhoon_setting = TyphoonSetting.find(@typhoon_qualified_records.typhoon_setting_id)
      typhoon_setting.apply_counts = typhoon_setting.typhoon_qualified_records.where(is_apply: true).count
      typhoon_setting.save
      response_json :ok
    end
  end

  def cancel_apply
    ActiveRecord::Base.transaction do
      @typhoon_qualified_records.update(is_apply: false, money: 0, is_compensate: nil)
      typhoon_setting = TyphoonSetting.find(@typhoon_qualified_records.typhoon_setting_id)
      typhoon_setting.apply_counts = typhoon_setting.typhoon_qualified_records.where(is_apply: true).count
      typhoon_setting.save

      AttendMonthlyReport.update_calc_status(@typhoon_qualified_records.user_id, @typhoon_qualified_records.qualify_date)
      AttendAnnualReport.update_calc_status(@typhoon_qualified_records.user_id, @typhoon_qualified_records.qualify_date)
      CompensateReport.update_reports(@typhoon_qualified_records)

      response_json :ok
    end
  end

  def export_xlsx
    authorize TyphoonQualifiedRecord
    all_result = search_query
    final_result = format_result(all_result.as_json(include: [], methods: []))
    language = select_language.to_s
    typhoon_qualified_records_export_num = Rails.cache.fetch('typhoon_qualified_records_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + typhoon_qualified_records_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('typhoon_qualified_records_export_number_tag', typhoon_qualified_records_export_num+1)


    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'TyphoonQualifiedRecordsController', table_fields_methods: 'get_typhoon_qualified_records_table_fields', table_fields_args: [], my_attachment: my_attachment, sheet_name: 'TyphoonTable')
    render json: my_attachment
  end

  private

  def set_typhoon_qualified_record
    @typhoon_qualified_records = TyphoonQualifiedRecord.find(params[:id])
  end

  def search_query
    tag = false
    # region = params[:region] || 'macau'
    lang_key = params[:lang] || 'zh-TW'

    lang = if lang_key == 'zh-TW'
             'chinese_name'
           elsif lang_key == 'zh-US'
             'english_name'
           else
             'simple_chinese_name'
           end

    records = TyphoonQualifiedRecord
                  .by_typhoon_setting_id(params[:typhoon_setting_id])
                  .by_department_id(params[:department_id])
                  .by_user(params[:user_ids])
                  .by_qualify_date(params[:qualify_start_date], params[:qualify_end_date])
                  .by_typhoon_start_date(params[:typhoon_start_date], params[:typhoon_end_date])
                  .by_is_apply(params[:is_apply])


    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      default_order = "created_at DESC"
      default_order_with_self = "typhoon_qualified_records.created_at DESC"

      if params[:sort_column] == 'department' || params[:sort_column] == 'position'
        records = records.includes(:user).order("users.#{params[:sort_column]}_id #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'empoid'
        records = records.includes(:user).order("users.empoid #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'name'
        records = records.order("user_id #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'user.date_of_employment'
        records = records.includes(user: :profile).order("profiles.data -> 'position_information' -> 'field_values' -> 'date_of_employment' #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'startDate'
        records = records.includes(:typhoon_setting).order("typhoon_settings.start_date #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'startTime'
        records = records.includes(:typhoon_setting).order("typhoon_settings.start_time #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'endDate'
        records = records.includes(:typhoon_setting).order("typhoon_settings.end_date #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'endTime'
        records = records.includes(:typhoon_setting).order("typhoon_settings.end_time #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'isCompensate'
        records = records.order("is_compensate #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'qualifyDate'
        records = records.order("qualify_date #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'workingHours'
        records = records.order("working_hours #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'workingHours'
        records = records.order("working_hours #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'isApply'
        records = records.order("is_apply #{params[:sort_direction]}", default_order)
      else
        records = records.order("#{params[:sort_column]} #{params[:sort_direction]}", default_order)
      end
      tag = true

    end

    records = records.includes(:typhoon_setting, :user)
                .order("typhoon_settings.start_date desc", "typhoon_settings.end_date desc", "typhoon_qualified_records.qualify_date desc", "users.empoid asc") if tag == false
    records
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

      profile = user ? user.profile : nil

      hash['date_of_employment'] = profile ? profile['data']['position_information']['field_values']['date_of_employment'] : ''

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

      hash['typhoon_setting'] = hash['typhoon_setting_id'] ? TyphoonSetting.find_by(id: hash['typhoon_setting_id']) : nil

      hash
    end
  end

  def self.get_typhoon_qualified_records_table_fields
    empoid = {
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

    typhoon_start_date = {
      chinese_name: '颱風開始日期',
      english_name: 'Typhoon Start Date',
      simple_chinese_name: '台风开始日期',
      get_value: -> (rst, options){
        ans = ''
        if rst['typhoon_setting_id']
          typhoon_setting = TyphoonSetting.find_by(id: rst['typhoon_setting_id'])
          ans = typhoon_setting ? typhoon_setting['start_date'] : ''
        end
        ans
      }
    }

    typhoon_start_time = {
      chinese_name: '颱風開始時間',
      english_name: 'Typhoon Start Time',
      simple_chinese_name: '台风开始时间',
      get_value: -> (rst, options){
        ans = ''
        if rst['typhoon_setting_id']
          typhoon_setting = TyphoonSetting.find_by(id: rst['typhoon_setting_id'])
          ans = typhoon_setting ? Time.zone.parse(typhoon_setting['start_time']).strftime("%H:%M:%S") : ''
        end
        ans
      }
    }

    typhoon_end_date = {
      chinese_name: '颱風結束日期',
      english_name: 'Typhoon End Date',
      simple_chinese_name: '台风结束日期',
      get_value: -> (rst, options){
        ans = ''
        if rst['typhoon_setting_id']
          typhoon_setting = TyphoonSetting.find_by(id: rst['typhoon_setting_id'])
          ans = typhoon_setting ? typhoon_setting['end_date'] : ''
        end
        ans
      }
    }

    typhoon_end_time = {
      chinese_name: '颱風結束時間',
      english_name: 'Typhoon End Time',
      simple_chinese_name: '台风结束时间',
      get_value: -> (rst, options){
        ans = ''
        if rst['typhoon_setting_id']
          typhoon_setting = TyphoonSetting.find_by(id: rst['typhoon_setting_id'])
          ans = typhoon_setting ? Time.zone.parse(typhoon_setting['end_time']).strftime("%H:%M:%S") : ''
        end
        ans
      }
    }

    is_compensate = {
      chinese_name: '是否補薪',
      english_name: 'Is Compensate',
      simple_chinese_name: '是否补薪',
      get_value: -> (rst, options){
        ans = ''
        if rst['is_compensate'] == true
          ans = '是'
        elsif rst['is_compensate'] == false
          ans = '否'
        end
        ans
      }
    }

    qualify_date = {
      chinese_name: '符合日期',
      english_name: 'Qualify date',
      simple_chinese_name: '符合日期',
      get_value: -> (rst, options){
        rst['qualify_date'] ? rst['qualify_date'] : ''
      }
    }

    working_hours = {
      chinese_name: '工作時間',
      english_name: 'Working Hours',
      simple_chinese_name: '工作时间',
      get_value: -> (rst, options){
        rst['working_hours'] ? rst['working_hours'] : ''
      }
    }

    is_apply = {
      chinese_name: '作出申請',
      english_name: 'Is Apply',
      simple_chinese_name: '作出申请',
      get_value: -> (rst, options){
        rst['is_apply'] ? '是' : '否'
      }
    }

    money = {
      chinese_name: '金額（HKD）',
      english_name: 'Money (HKD)',
      simple_chinese_name: '金额（HKD）',
      get_value: -> (rst, options){
        rst['money'].to_i
      }
    }

    table_fields = [empoid, name, department, position, typhoon_start_date, typhoon_start_time,
                    typhoon_end_date, typhoon_end_time, is_compensate, qualify_date, working_hours,
                    is_apply, money]


  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '颱風津貼報表'
    elsif select_language.to_s == 'english_name'
      'Typhoon Table'
    else
      '台风津贴报表'
    end
  end
end
