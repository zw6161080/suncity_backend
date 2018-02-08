# coding: utf-8
class SignCardRecordsController < ApplicationController
  include GenerateXlsxHelper
  include DownloadActionAble
  before_action :set_sign_card_record, only: [ :show, :update, :destroy, :histories, :add_approval, :add_attach]

  def raw_index
    params[:page] ||= 1
    meta = {}
    all_result = search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    final_result = format_result(result.as_json(include: [:creator], methods: []))
    response_json final_result, meta: meta

  end

  def index_for_report
    authorize SignCardRecord
    raw_index
  end


  def index
    authorize SignCardRecord
    raw_index
  end

  def raw_show
    result = @sign_card_record.as_json(
      include: {
          creator: {},
          attend_attachments: {include: :creator},
          user: {include: [:department, :location, :position ], methods: [ :date_of_employment ]},
          sign_card_record_histories: { include: [ :user, :creator ], methods: [ :sign_card_setting_detail, :sign_card_reason_detail ] },
          approval_items: { include: {user: { include: [:department, :location, :position ] } } },
      }
    )
    response_json result
  end

  def show
    authorize SignCardRecord
    raw_show
  end

  def raw_create
    ActiveRecord::Base.transaction do
      apply_results = {}
      if params[:new_sign_card_records]
        params[:new_sign_card_records].each do |new_record|
          raise LogicError, {id: 422, message: '参数不完整'}.to_json unless sign_card_record_params
          raise LogicError, {id: 422, message: '已申请过签卡'}.to_json if SignCardRecord.where(user_id: params[:new_sign_card_records][:user_id]).where(sign_card_date: params[:new_sign_card_records][:sign_card_date])
          nr = SignCardRecord.create(new_record.permit(
                                       :region,
                                       :user_id,
                                       :is_compensate,
                                       :is_get_to_work,
                                       :sign_card_date,
                                       :sign_card_time,
                                       :sign_card_setting_id,
                                       :sign_card_reason_id,
                                       :is_deleted,
                                       :creator_id,
                                       :is_next,
                                       :comment
                                     ))
          nr.input_date = nr.created_at.to_date
          nr.input_time = nr.created_at.to_datetime.strftime("%H:%M:%S")
          nr.save

          nr.sign_card_record_histories.create(nr.attributes.merge({ id: nil }))

          # attend state
          user_id = nr.user_id
          date = nr.sign_card_date
          att = Attend.find_attend_by_user_and_date(user_id, date)

          if att == nil
            att = Attend.create(user_id: user_id,
                                attend_date: date,
                                attend_weekday: date.wday,
                               )
          end

          state_type = SignCardSetting.return_attend_state_type(nr.sign_card_setting_id)
          att.attend_states.create(sign_card_state: state_type,
                                   record_type: 'sign_card_record',
                                   record_id: nr.id)

          SignCardRecord.create_punching_card_on_holiday_exception(nr)
          # att.attend_states.each do |s|
          #   s.destroy if s.auto_state != nil
          # end

          # attend log
          att.attend_logs.create(user_id: user_id,
                                 apply_type: 'sign_card',
                                 type_id: nr.id,
                                 logger_id: nr.creator_id
                                )

          if nr.is_compensate == false
            AttendMonthlyReport.update_calc_status(nr.user_id, nr.sign_card_date)
            AttendAnnualReport.update_calc_status(nr.user_id, nr.sign_card_date)
          else
            CompensateReport.update_reports(nr)
          end

          AttendMonthApproval.update_data(nr.sign_card_date)

          apply_results["#{nr.user_id}_#{nr.sign_card_date}_#{nr.is_get_to_work}"] = nr.id
          apply_results['id'] = nr.id
        end
      end

      response_json apply_results.as_json
    end
  end



  def create
    authorize SignCardRecord
    raw_create
  end

  def update
    authorize SignCardRecord

    att = Attend.find_attend_by_user_and_date(@sign_card_record.user_id, @sign_card_record.sign_card_date)
    if att
      SignCardRecord.destroy_punching_card_on_holiday_exception(att)
    end

    updated_sign_card_record = @sign_card_record.update(sign_card_record_params)
    if updated_sign_card_record
      updated_record = SignCardRecord.find_by(id: @sign_card_record.id)
      raise LogicError, {id: 422, message: '找不到记录'}.to_json unless updated_record
      attend_state = AttendState.where(record_type: 'sign_card_record', record_id: updated_record.id).first
      state_type = SignCardSetting.return_attend_state_type(updated_record.sign_card_setting_id)
      attend_state.sign_card_state = state_type
      attend_state.save

      updated_record.sign_card_record_histories.create(
        updated_record.attributes.merge({ id: nil })
      )
      SignCardRecord.create_punching_card_on_holiday_exception(updated_record)


      if updated_record.is_compensate == false
        AttendMonthlyReport.update_calc_status(updated_record.user_id, updated_record.sign_card_date)
        AttendAnnualReport.update_calc_status(updated_record.user_id, updated_record.sign_card_date)
      else
        CompensateReport.update_reports(updated_record)
      end
      AttendMonthApproval.update_data(updated_record.sign_card_date)
    end
    response_json updated_sign_card_record
  end

  def destroy
    authorize SignCardRecord
    ActiveRecord::Base.transaction do
      updated_sign_card_record = @sign_card_record.update(is_deleted: true)

      att_states = AttendState.where(record_type: 'sign_card_record', record_id: @sign_card_record.id)
      att_states.each { |state| state.destroy if state }
      att_logs = AttendLog.where(apply_type: 'sign_card', type_id: @sign_card_record.id)
      att_logs.each { |log| log.destroy if log }


      att = Attend.find_attend_by_user_and_date(@sign_card_record.user_id, @sign_card_record.sign_card_date)
      if att
        SignCardRecord.destroy_punching_card_on_holiday_exception(att)
      end

      if @sign_card_record.is_compensate == false
        AttendMonthlyReport.update_calc_status(@sign_card_record.user_id, @sign_card_record.sign_card_date)
        AttendAnnualReport.update_calc_status(@sign_card_record.user_id, @sign_card_record.sign_card_date)
      else
        CompensateReport.update_reports(@sign_card_record)
      end
      AttendMonthApproval.update_data(@sign_card_record.sign_card_date)

      response_json updated_sign_card_record
    end
  end

  def histories
    response_json @sign_card_record.sign_card_record_histories.as_json
  end

  def add_approval
    authorize SignCardRecord
    raise LogicError, {id: 422, message: '參數不完整'}.to_json unless params[:approval_item][:user_id] && params[:approval_item][:datetime] && params[:approval_item][:comment]
    if params[:approval_item]
      na = @sign_card_record.approval_items.create(params[:approval_item].permit(:user_id, :datetime, :comment))
      response_json na.as_json
    else
      response_json :ok
    end
  end

  def destroy_approval
    authorize SignCardRecord
    sign_card_record = SignCardRecord.find(params[:sign_card_record_id])
    raise LogicError, {id: 422, message: '找不到记录'}.to_json unless sign_card_record
    app = sign_card_record.approval_items.find(params[:id])
    raise LogicError, {id: 422, message: '找不到记录'}.to_json unless app
    app.destroy if app
    response_json :ok
  end

  def add_attach
    authorize SignCardRecord
    raise LogicError, {id: 422, message: '參數不完整'}.to_json unless params[:attach_item][:file_name]
    if params[:attach_item]
      ai = @sign_card_record.attend_attachments.create(params[:attach_item].permit(:file_name, :comment, :attachment_id, :creator_id))
      response_json ai.as_json
    else
      response_json :ok
    end
  end

  def destroy_attach
    authorize SignCardRecord
    sign_card_record = SignCardRecord.find(params[:sign_card_record_id])
    raise LogicError, {id: 422, message: '找不到记录'}.to_json unless sign_card_record
    att = sign_card_record.attend_attachments.find(params[:id])
    raise LogicError, {id: 422, message: '找不到记录'}.to_json unless att
    att.destroy if att
    response_json :ok
  end

  def be_able_apply
    apply_date = params[:apply_date].in_time_zone.to_date
    true_records = SignCardRecord.where(is_deleted: false).or(SignCardRecord.where(is_deleted: nil))
    on_apply_count = true_records.where(user_id: params[:user_id], source_id: nil, sign_card_date: apply_date, is_get_to_work: true).count
    off_apply_count = true_records.where(user_id: params[:user_id], source_id: nil, sign_card_date: apply_date, is_get_to_work: false).count
    on_be_able_apply = on_apply_count > 0 ? false : true
    off_be_able_apply = off_apply_count > 0 ? false : true
    result = {}
    result[:on_be_able_apply] = on_be_able_apply
    result[:off_be_able_apply] = off_be_able_apply
    response_json result.as_json
  end

  def raw_export_xlsx
    all_result = search_query
    final_result = format_result(all_result.as_json(include: [], methods: []))
    sign_card_record_export_num = Rails.cache.fetch('sign_card_record_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + sign_card_record_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('sign_card_record_export_number_tag', sign_card_record_export_num+1)

    is_report = params[:type] == 'report' ? true : false
    title = params[:type] == 'report' ? export_report_title : export_record_title

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'SignCardRecordsController', table_fields_methods: 'get_sign_card_record_table_fields', table_fields_args: [is_report], my_attachment: my_attachment, sheet_name: 'SignCardRecordTable')
    render json: my_attachment
  end

  def export_xlsx_for_report
    authorize SignCardRecord
    raw_export_xlsx
  end


  def export_xlsx
    authorize SignCardRecord
    raw_export_xlsx
  end

  def options
    result = {}
    result[:sign_card_reasons] = SignCardReason.all.map do |scr|
      # scr
      {
        key: scr.id,
        chinese_name: scr.reason,
        english_name: scr.reason,
        simple_chinese_name: scr.reason
      }
    end
    recruit_group_users = Role.find_by(key: 'recruit_group')&.users
    result[:users] = recruit_group_users.pluck(:id).uniq!
    response_json result.as_json
  end

  private

  def sign_card_record_params
    params.require(:sign_card_record).permit(
      :region,
      :user_id,
      :is_compensate,
      :is_get_to_work,
      :sign_card_date,
      :sign_card_time,
      :sign_card_setting_id,
      :sign_card_reason_id,
      :is_deleted,
      :creator_id,
      :is_next,
      :comment
    )
  end

  def set_sign_card_record
    @sign_card_record = SignCardRecord.find(params[:id])
  end

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

    sign_card_records = SignCardRecord
                          .where(source_id: nil)
                          .by_location_id(params[:location_id])
                          .by_department_id(params[:department_id])
                          .by_user(params[:user_ids])
                          .by_sign_card_date(params[:sign_card_start_date], params[:sign_card_end_date])
                          .by_is_deleted(params[:is_deleted])
                          .by_sign_card_reason_id(params[:sign_card_reason_id])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      default_order = "created_at DESC"
      default_order_with_self = "sign_card_records.created_at DESC"

      if params[:sort_column] == 'department' || params[:sort_column] == 'position'
        sign_card_records = sign_card_records.includes(:user).order("users.#{params[:sort_column]}_id #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'user.empoid'
        sign_card_records = sign_card_records.includes(:user).order("users.empoid #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'user'
        sign_card_records = sign_card_records.order("user_id #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'user.date_of_employment'
        sign_card_records = sign_card_records.includes(user: :profile).order("profiles.data -> 'position_information' -> 'field_values' -> 'date_of_employment' #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'sign_card_type'
        sign_card_records = sign_card_records.order("sign_card_setting_id #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'sign_card_reason'
        sign_card_records = sign_card_records.order("sign_card_reason_id #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'enterDate'
        sign_card_records = sign_card_records.order("input_date #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'enterTime'
        sign_card_records = sign_card_records.order("input_time #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'creator'
        sign_card_records = sign_card_records.order("creator_id #{params[:sort_direction]}", default_order)
      else
        sign_card_records = sign_card_records.order("#{params[:sort_column]} #{params[:sort_direction]}", default_order)
      end
      tag = true
    end

    sign_card_records = sign_card_records.order(created_at: :desc) if tag == false
    sign_card_records
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

      sign_card_setting = hash['sign_card_setting_id'] ? SignCardSetting.find(hash['sign_card_setting_id']) : nil
      hash['sign_card_type'] = sign_card_setting ?
      {
        id: sign_card_setting['id'],
        chinese_name: sign_card_setting['chinese_name'],
        english_name: sign_card_setting['english_name'],
        simple_chinese_name: sign_card_setting['chinese_name'],
      } : nil

      sign_card_reason = hash['sign_card_reason_id'] ? SignCardReason.find(hash['sign_card_reason_id']) : nil
      hash['sign_card_reason'] = sign_card_reason ?
      {
        id: sign_card_reason['id'],
        chinese_name: sign_card_reason['reason'],
      } : nil

      hash
    end
  end

  def find_name_for(type, table)
    type_options = table
    type_options.select { |op| op[:key] == type }.first
  end

  def self.get_sign_card_record_table_fields( is_report)
    empoid = {
      chinese_name: '員工編號',
      english_name: 'empoid',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        # user = User.find(rst["user_id"])
        # user["empoid"].rjust(8, '0')
        "\s#{rst["user"][:empoid].rjust(8, '0')}"
        # "%08d" % rst["user"][:empoid]
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

    is_get_to_work = {
      chinese_name: '上/下班簽卡',
      english_name: 'On / Off',
      simple_chinese_name: '上/下班签卡',
      get_value: -> (rst, options){
        rst['is_get_to_work'] ? '上班簽卡' : '下班签卡'
      }
    }

    sign_card_date = {
      chinese_name: '簽卡日期',
      english_name: 'Sign Card Date',
      simple_chinese_name: '签卡日期',
      get_value: -> (rst, options){
        rst['sign_card_date'] ? rst["sign_card_date"] : ''
      }
    }

    sign_card_time = {
      chinese_name: '簽卡時間',
      english_name: 'Sign Card Time',
      simple_chinese_name: '签卡时间',
      get_value: -> (rst, options){
        time = rst['sign_card_time'] ? Time.zone.parse(rst["sign_card_time"]).strftime("%H:%M:%S") : ''
        is_next = rst['is_next'] ? '次日' : ''
        "#{is_next} #{time}"
      }
    }

    sign_card_setting = {
      chinese_name: '簽卡類型',
      english_name: 'Sign Card Type',
      simple_chinese_name: '签卡类型',
      get_value: -> (rst, options){
        rst['sign_card_type'] ? rst['sign_card_type'][options[:name_key]] : ''
      }
    }

    sign_card_reason = {
      chinese_name: '簽卡原因',
      english_name: 'Sign Card Reason',
      simple_chinese_name: '签卡原因',
      get_value: -> (rst, options){
        rst['sign_card_reason'] ? rst['sign_card_reason'][:chinese_name] : ''
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
                        is_get_to_work, sign_card_date, sign_card_time, sign_card_setting,
                        sign_card_reason, comment, creator, input_date, input_time]


  end

  def export_record_title
    if select_language.to_s == 'chinese_name'
      '簽卡記錄'
    elsif select_language.to_s == 'english_name'
      'Sign Card Records'
    else
      '签卡记录'
    end
  end

  def export_report_title
    if select_language.to_s == 'chinese_name'
      '簽卡報表'
    elsif select_language.to_s == 'english_name'
      'Sign Card Report'
    else
      '签卡报表'
    end
  end
end
