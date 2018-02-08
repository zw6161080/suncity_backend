# coding: utf-8
class OvertimeRecordsController < ApplicationController
  include GenerateXlsxHelper
  include DownloadActionAble
  before_action :set_overtime_record, only: [:show, :update, :destroy, :histories, :add_approval, :add_attach]


  def raw_index
    params[:page] ||= 1
    meta = {}
    all_result = search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page
    meta['overtime_hours'] = all_result.sum(:overtime_hours)
    meta['vehicle_department_over_time_min'] = all_result.sum(:vehicle_department_over_time_min)

    final_result = format_result(result.as_json(include: [:creator], methods: []))

    response_json final_result, meta: meta

  end

  def index_for_report
    authorize OvertimeRecord
    raw_index
  end

  def index
    authorize OvertimeRecord
    raw_index
  end

  def raw_show
    result = @overtime_record.as_json(
      include: {
        approval_items: {include: {user: {include: [:department, :location, :position ]}}},
        attend_attachments: {include: :creator},
        user: {include: [:department, :location, :position ], methods: [:date_of_employment]},
        overtime_record_histories: {include: [:user, :creator]},
      }
    )
    response_json result
  end

  def show
    authorize OvertimeRecord
    raw_show
  end

  def raw_create
    ActiveRecord::Base.transaction do
      raise LogicError, {id: 422, message: '參數不完整'}.to_json unless overtime_record_params
      raise LogicError, {id: 422, message: '加班已经存在'}.to_json if OvertimeRecord.where(user_id: params[:overtime_record][:user_id]).where(overtime_start_date: params[:overtime_record][:overtime_start_date])
      raise LogicError, {id: 422, message: '加班结束时间错误'}.to_json unless params[:overtime_record][:overtime_end_date] == params[:overtime_record][:overtime_start_date] || params[:overtime_record][:overtime_end_date] == params[:overtime_record][:overtime_start_date]+1
      nr = OvertimeRecord.create(overtime_record_params)
      nr.overtime_record_histories.create(nr.attributes.merge({ id: nil }))

      nr.input_date = nr.created_at.to_date
      nr.input_time = nr.created_at.to_datetime.strftime("%H:%M:%S")
      nr.save

      # attend state
      user_id = nr.user_id
      date = nr.overtime_start_date

      att = Attend.find_attend_by_user_and_date(user_id, date)
      if att == nil
        att = Attend.create(user_id: user_id,
                            attend_date: date,
                            attend_weekday: date.wday,
        )
      end

      remark = nr.overtime_type == 'vehicle_department' ? "#{nr.vehicle_department_over_time_min} mins" : "#{nr.overtime_hours} hours"
      att.attend_states.create(state: 'overtime',
                               record_type: 'overtime_record',
                               record_id: nr.id,
                               remark: remark
      )

      OvertimeRecord.destroy_punching_card_on_holiday_exception(att)

      att.attend_logs.create(user_id: user_id,
                             apply_type: 'overtime',
                             type_id: nr.id,
                             logger_id: nr.creator_id
      )

      if nr.is_compensate != true
        AttendMonthlyReport.update_calc_status(nr.user_id, nr.overtime_start_date)
        AttendAnnualReport.update_calc_status(nr.user_id, nr.overtime_start_date)
      else
        CompensateReport.update_reports(nr)
      end
      AttendMonthApproval.update_data(nr.overtime_start_date)

      response_json nr.id
    end
  end


  def create
    authorize OvertimeRecord
    raw_create
  end

  def update
    origin_start = @overtime_record.overtime_start_date

    raise LogicError, {id: 422, message: '加班已经存在'}.to_json if OvertimeRecord.where(user_id: params[:overtime_record][:user_id]).where(overtime_start_date: params[:overtime_record][:overtime_start_date])
    raise LogicError, {id: 422, message: '加班结束时间错误'}.to_json unless params[:overtime_record][:overtime_end_date] == params[:overtime_record][:overtime_start_date] || params[:overtime_record][:overtime_end_date] == params[:overtime_record][:overtime_start_date]+1

    updated_overtime_record = @overtime_record.update(overtime_record_params)

    if updated_overtime_record
      updated_record = OvertimeRecord.find_by(id: @overtime_record.id)
      raise LogicError, {id: 422, message: '找不到记录'}.to_json unless updated_record
      new_start = params[:overtime_start_date].in_time_zone.to_date

      if origin_start != new_start
        # destroy
        attend_state = AttendState.where(record_type: 'overtime_record', record_id: @overtime_record.id).first
        attend_state.destroy if attend_state

        attend_log = AttendLog.where(apply_type: 'overtime', type_id: @overtime_record.id).first
        attend_log.destroy if attend_log

        OvertimeRecord.create_punching_card_on_holiday_exception(updated_record)

        # create
        user_id = updated_record.user_id

        att = Attend.find_attend_by_user_and_date(user_id, new_start)
        if att == nil
          att = Attend.create(user_id: user_id,
                              attend_date: new_start,
                              attend_weekday: new_start.wday,
                             )
        end



        remark = updated_record.overtime_type == 'vehicle_department' ? "#{updated_record.vehicle_department_over_time_min} mins" : "#{updated_record.overtime_hours} hours"
        att.attend_states.create(state: 'overtime',
                                 record_type: 'overtime_record',
                                 record_id: updated_record.id,
                                 remark: remark
                                )

        OvertimeRecord.destroy_punching_card_on_holiday_exception(att)

        att.attend_logs.create(user_id: user_id,
                               apply_type: 'overtime',
                               type_id: updated_record.id,
                               logger_id: updated_record.creator_id
                              )
      else
        user_id = updated_record.user_id
        att = Attend.find_attend_by_user_and_date(user_id, new_start)
        if att == nil
          att = Attend.create(user_id: user_id,
                              attend_date: new_start,
                              attend_weekday: new_start.wday,
                             )
        end



        remark = updated_record.overtime_type == 'vehicle_department' ? "#{updated_record.vehicle_department_over_time_min} mins" : "#{updated_record.overtime_hours} hours"
        att_state = att.attend_states.where(state: 'overtime',
                                            record_type: 'overtime_record',
                                            record_id: updated_record.id
                                           ).first
        att_state.remark = remark
        att_state.save
      end


      updated_record.overtime_record_histories.create(
        updated_record.attributes.merge({ id: nil })
      )

      if updated_record.is_compensate == false
        AttendMonthlyReport.update_calc_status(updated_record.user_id, updated_record.overtime_start_date)
        AttendAnnualReport.update_calc_status(updated_record.user_id, updated_record.overtime_start_date)
      else
        CompensateReport.update_reports(updated_record)
      end
      AttendMonthApproval.update_data(updated_record.overtime_start_date)
    end
    response_json updated_overtime_record
  end

  def destroy
    ActiveRecord::Base.transaction do
      updated_overtime_record = @overtime_record.update(is_deleted: true)

      att_states = AttendState.where(record_type: 'overtime_record', record_id: @overtime_record.id)
      att_states.each { |state| state.destroy if state }
      att_logs = AttendLog.where(apply_type: 'overtime', type_id: @overtime_record.id)
      att_logs.each { |log| log.destroy if log }

      OvertimeRecord.create_punching_card_on_holiday_exception(@overtime_record)

      if @overtime_record.is_compensate == false
        AttendMonthlyReport.update_calc_status(@overtime_record.user_id, @overtime_record.overtime_start_date)
        AttendAnnualReport.update_calc_status(@overtime_record.user_id, @overtime_record.overtime_start_date)
      else
        CompensateReport.update_reports(@overtime_record)
      end

      AttendMonthApproval.update_data(@overtime_record.overtime_start_date)

      response_json updated_overtime_record
    end
  end

  def histories
    response_json @overtime_record.overtime_record_histories.as_json
  end

  def add_approval
    authorize OvertimeRecord
    raise LogicError, {id: 422, message: '參數不完整'}.to_json unless params[:approval_item][:user_id] && params[:approval_item][:datetime] && params[:approval_item][:comment]
    if params[:approval_item]
      na = @overtime_record.approval_items.create(params[:approval_item].permit(:user_id, :datetime, :comment))
      response_json na.as_json
    else
      response_json :ok
    end
  end

  def destroy_approval
    authorize OvertimeRecord
    overtime_record = OvertimeRecord.find(params[:overtime_record_id])
    raise LogicError, {id: 422, message: '找不到记录'}.to_json unless overtime_record
    app = overtime_record.approval_items.find(params[:id])
    raise LogicError, {id: 422, message: '找不到记录'}.to_json unless app
    app.destroy if app
    response_json :ok
  end

  def add_attach
    authorize OvertimeRecord
    raise LogicError, {id: 422, message: '找不到记录'}.to_json unless params[:attach_item][:file_name]
    if params[:attach_item]
      ai = @overtime_record.attend_attachments.create(params[:attach_item].permit(:file_name, :comment, :attachment_id, :creator_id))
      response_json ai.as_json
    else
      response_json :ok
    end
  end

  def destroy_attach
    authorize OvertimeRecord
    overtime_record = OvertimeRecord.find(params[:overtime_record_id])
    raise LogicError, {id: 422, message: '找不到记录'}.to_json unless overtime_record
    att = overtime_record.attend_attachments.find(params[:id])
    raise LogicError, {id: 422, message: '找不到记录'}.to_json unless att
    att.destroy if att
    response_json :ok
  end

  def be_able_apply
    overtime_date = params[:apply_start_date].in_time_zone.to_date
    # end_date = params[:apply_end_date].in_time_zone.to_date

    true_records = OvertimeRecord.where(is_deleted: false).or(OvertimeRecord.where(is_deleted: nil))

    result = [*overtime_date .. overtime_date].map do |date|
      # apply_count = true_records.where(user_id: params[:user_id], source_id: nil).where("overtime_start_date <= ? AND overtime_end_date > ?", date, date).count
      apply_count = true_records.where(user_id: params[:user_id], source_id: nil).where(overtime_start_date: overtime_date).count
      be_able_apply = apply_count > 0 ? false : true
      [date, be_able_apply]
    end.to_h

    final_result = result.merge(
      {
        be_able_apply: result.values.select { |k| k == false }.count <= 0
      }
    )
    response_json final_result.as_json
  end


  def options
    result = {}

    result[:overtime_types] = overtime_type_table
    result[:compensation_types] = compensation_type_table

    response_json result.as_json
  end

  def raw_export_xlsx
    all_result = search_query
    final_result = format_result(all_result.as_json(include: [], methods: []))
    language = select_language.to_s
    overtime_record_export_num = Rails.cache.fetch('overtime_record_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + overtime_record_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('overtime_record_export_number_tag', overtime_record_export_num+1)

    is_report = params[:type] == 'report' ? true : false
    title = params[:type] == 'report' ? export_report_title : export_record_title

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'OvertimeRecordsController', table_fields_methods: 'get_table_fields', table_fields_args: [is_report], my_attachment: my_attachment, sheet_name: 'OvertimeRecordTable')
    render json: my_attachment

  end

  def export_xlsx_for_report
    authorize OvertimeRecord
    raw_export_xlsx
  end

  def export_xlsx
    authorize OvertimeRecord
    raw_export_xlsx
  end



  private

  def overtime_record_params
    params.require(:overtime_record).permit(
      :region,
      :user_id,
      :is_compensate,
      :overtime_type,
      :compensate_type,
      :overtime_start_date,
      :overtime_true_start_date,
      :overtime_end_date,
      :overtime_start_time,
      :overtime_end_time,
      :overtime_hours,
      :vehicle_department_over_time_min,
      :is_deleted,
      :creator_id,
      :comment
    )
  end

  def set_overtime_record
    @overtime_record = OvertimeRecord.find(params[:id])
  end

  def search_query
    tag = false
    # region = params[:region] || 'macau'

    overtime_records = OvertimeRecord
                           .where(source_id: nil)
                           .by_company_name(params[:company_name])
                           .by_location_id(params[:location_id])
                           .by_department_id(params[:department_id])
                           .by_position_id(params[:position_id])
                           .by_user(params[:user_ids])
                           .by_overtime_date(params[:overtime_start_date], params[:overtime_end_date])
                           .by_overtime_type(params[:overtime_types])
                           .by_compensate_type(params[:compensation_types])
                           .by_is_deleted(params[:is_deleted])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      default_order = "created_at DESC"
      default_order_with_self = "overtime_records.created_at DESC"

      if params[:sort_column] == 'department' || params[:sort_column] == 'position'
        overtime_records = overtime_records.includes(:user).order("users.#{params[:sort_column]}_id #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'user.empoid'
        overtime_records = overtime_records.includes(:user).order("users.empoid #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'user'
        overtime_records = overtime_records.order("user_id #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'user.date_of_employment'
        overtime_records = overtime_records.includes(user: :profile).order("profiles.data -> 'position_information' -> 'field_values' -> 'date_of_employment' #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'overtime_types' || params[:sort_column] == 'overtime_name'
        overtime_records = overtime_records.order("overtime_type #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'compensation_types' || params[:sort_column] == 'compensate_name'
        overtime_records = overtime_records.order("compensate_type #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'enterDate'
        overtime_records = overtime_records.order("input_date #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'enterTime'
        overtime_records = overtime_records.order("input_time #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'creator'
        overtime_records = overtime_records.order("creator_id #{params[:sort_direction]}", default_order)
      else
        overtime_records = overtime_records.order("#{params[:sort_column]} #{params[:sort_direction]}", default_order)
      end
      tag = true
    end

    overtime_records = overtime_records.order(created_at: :desc) if tag == false
    overtime_records
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

      hash['compensate_name'] = find_name_for(hash['compensate_type'], compensation_type_table)
      hash['overtime_name'] = find_name_for(hash['overtime_type'], overtime_type_table)

      hash
    end
  end

  def find_name_for(type, table)
    type_options = table
    type_options.select { |op| op[:key] == type }.first
  end

  def find_overtime_type_name(type)
    type_options = overtime_type_table
    type_options.select { |op| op[:key] == type }.first
  end

  def find_compensation_type_name(type)
    type_options = compensation_type_table
    type_options.select { |op| op[:key] == type }.first
  end

  def overtime_type_table
    [
      {
        key: 'weekdays',
        chinese_name: '平日加班',
        english_name: 'Weekdays Overtime',
        simple_chinese_name: '平日加班',
      },

      {
        key: 'general_holiday',
        chinese_name: '公休加班',
        english_name: 'General Holiday Overtime',
        simple_chinese_name: '公休加班',
      },

      {
        key: 'force_holiday',
        chinese_name: '強制性假日加班',
        english_name: 'Force Holiday Overtime',
        simple_chinese_name: '强制性假日加班',
      },

      {
        key: 'public_holiday',
        chinese_name: '公眾假日加班',
        english_name: 'Public Holiday Overtime',
        simple_chinese_name: '公众假日加班',
      },

      {
        key: 'vehicle_department',
        chinese_name: '車務部平日加班',
        english_name: 'Vehicle Department Overtime',
        simple_chinese_name: '车务部平日加班',
      },
    ]
  end

  def compensation_type_table
    [
      {
        key: 'money',
        chinese_name: '補錢',
        english_name: 'Money',
        simple_chinese_name: '补钱',
      },

      {
        key: 'holiday',
        chinese_name: '補假',
        english_name: 'Holiday',
        simple_chinese_name: '补假',
      },
    ]
  end

  def self.get_table_fields(is_report)
    empoid = {
      chinese_name: '員工編號',
      english_name: 'empoid',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        # user = User.find(rst["user_id"])
        # user["empoid"].rjust(8, '0')
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

    entry_date = {
      chinese_name: '入職日期',
      english_name: 'Entry date',
      simple_chinese_name: '入职日期',
      get_value: -> (rst, options){
        rst['date_of_employment'] ? rst['date_of_employment'] : ''
      }
    }

    is_compensate = {
      chinese_name: '是否補薪',
      english_name: 'Is Compensate',
      simple_chinese_name: '是否补薪',
      get_value: -> (rst, options){
        rst['is_compensate'] ? '是' : '否'
      }
    }

    overtime_type = {
      chinese_name: '加班類型',
      english_name: 'Overtime Type',
      simple_chinese_name: '加班类型',
      get_value: -> (rst, options){
        rst['overtime_name'] ? rst['overtime_name'][options[:name_key]] : ''
      }
    }

    compensate_type = {
      chinese_name: '補償類型',
      english_name: 'Compensate Type',
      simple_chinese_name: '补偿类型',
      get_value: -> (rst, options){
        rst['compensate_name'] ? rst['compensate_name'][options[:name_key]] : ''
      }
    }

    overtime_date = {
      chinese_name: '加班日期',
      english_name: 'Overtime date',
      simple_chinese_name: '加班日期',
      get_value: -> (rst, options){
        rst['overtime_start_date'] ? rst['overtime_start_date'] : ''
      }
    }

    overtime_start_date = {
      chinese_name: '加班開始日期',
      english_name: 'Overtime start date',
      simple_chinese_name: '加班开始日期',
      get_value: -> (rst, options){
        rst['overtime_true_start_date'] ? rst['overtime_true_start_date'] : ''
      }
    }

    overtime_start_time = {
      chinese_name: '加班開始時間',
      english_name: 'Overtime start time',
      simple_chinese_name: '加班开始时间',
      get_value: -> (rst, options){
        rst['overtime_start_time'] ? Time.zone.parse(rst['overtime_start_time']).strftime("%H:%M:%S") : ''
      }
    }

    overtime_end_date = {
      chinese_name: '加班結束日期',
      english_name: 'Overtime end date',
      simple_chinese_name: '加班结束日期',
      get_value: -> (rst, options){
        rst['overtime_end_date'] ? rst['overtime_end_date'] : ''
      }
    }

    overtime_end_time = {
      chinese_name: '加班結束時間',
      english_name: 'Overtime end time',
      simple_chinese_name: '加班结束时间',
      get_value: -> (rst, options){
        rst['overtime_end_time'] ? Time.zone.parse(rst['overtime_end_time']).strftime("%H:%M:%S") : ''
      }
    }

    overtime_hours = {
      chinese_name: '加班時數',
      english_name: 'Overtime hours',
      simple_chinese_name: '加班时数',
      get_value: -> (rst, options){
        rst['overtime_hours'] ? rst['overtime_hours'] : ''
      }
    }

    vehicle_department_over_time_min = {
      chinese_name: '車務部加班分鐘',
      english_name: 'Vehicle department over time min',
      simple_chinese_name: '车务部加班分钟',
      get_value: -> (rst, options){
        rst['vehicle_department_over_time_min'] ? rst['vehicle_department_over_time_min'] : ''
      }
    }


    comment = {
      chinese_name: '備註',
      english_name: 'Remarks',
      simple_chinese_name: '备注',
      get_value: -> (rst, options){
        rst['comment'] ? rst["comment"] : ''
      }
    }

    input_date = {
      chinese_name: '錄入日期',
      english_name: 'Input Date',
      simple_chinese_name: '录入时间',
      get_value: -> (rst, options){
        rst['input_date'] ? rst["input_date"] : ''
      }
    }

    input_time = {
      chinese_name: '錄入時間',
      english_name: 'Input Time',
      simple_chinese_name: '录入时间',
      get_value: -> (rst, options){
        rst['input_time'] ? rst["input_time"] : ''
      }
    }

    creator = {
      chinese_name: '錄入人',
      english_name: 'Inputter',
      simple_chinese_name: '录入人',
      get_value: -> (rst, options){
        ans = ""
        if rst['creator_id']
          user = User.find_by(id: rst['creator_id'])
          name = user ? user[options[:name_key]] : ''
          empoid = user ? user.empoid : ''
          ans = "#{name} (#{empoid})"
        end
        ans
      }
    }

    tmp_table_fields = [empoid, name, department, position, entry_date, is_compensate,
                        overtime_type, compensate_type, overtime_date, overtime_start_date,
                     overtime_start_time, overtime_end_date, overtime_end_time, overtime_hours,
                    vehicle_department_over_time_min, comment]

    input_table_fields = [input_date, input_time, creator]
    table_fields = is_report ? tmp_table_fields + input_table_fields : tmp_table_fields

  end

  def export_record_title
    if select_language.to_s == 'chinese_name'
      '加班記錄'
    elsif select_language.to_s == 'english_name'
      'Overtime Records'
    else
      '加班记录'
    end
  end

  def export_report_title
    if select_language.to_s == 'chinese_name'
      '加班報表'
    elsif select_language.to_s == 'english_name'
      'Overtime Report'
    else
      '加班报表'
    end
  end
end
