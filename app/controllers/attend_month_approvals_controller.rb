# coding: utf-8
class AttendMonthApprovalsController < ApplicationController
  include GenerateXlsxHelper
  before_action :set_attend_month_approval, only: [:approval, :cancel_approval]
  after_action :calc_compensate_reports, only: [:approval]

  def index
    authorize AttendMonthApproval
    params[:page] ||= 1
    meta = {}
    all_result = search_query
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)

    # result.each { |r| r.set_data }

    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    final_result = format_result(result.as_json(include: [], methods: []))

    response_json final_result, meta: meta
  end

  def create
    authorize AttendMonthApproval
    ActiveRecord::Base.transaction do
      year, month = params[:month].split('/').map(& :to_i)
      raise LogicError, {id: 422, message: '日期不规范'}.to_json unless month <= 12
      if year > 0 && month > 0 && month <= 12
        f_year, f_month = "#{year}".rjust(4, '0'), "#{month}".rjust(2, '0')
        fmt_month = "#{f_year}/#{f_month}"
        raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:attend_month_approval][:month]
        attend_month_approval = AttendMonthApproval.create(attend_month_approval_params)
        attend_month_approval.month = fmt_month
        attend_month_approval.status = 'not_approval'
        attend_month_approval.save
        # UpdateAttendMonthApprovalJob.perform_later(attend_month_approval)
        response_json attend_month_approval.id
      end
    end
  end

  def approval
    authorize AttendMonthApproval
    ActiveRecord::Base.transaction do
      @attend_month_approval.update(status: 0)
      @attend_month_approval.update(approval_time: Time.zone.now.to_datetime)

      group_user_ids = Role.attend_and_payment_group_user_ids
      Message.add_notification(@attend_month_approval, "attend_month_approval", group_user_ids) unless group_user_ids.empty?

      # month fmt: '2017/01'
      # month = @attend_month_approval.month
      # year, month = month.split('/').map(& :to_i)
      # amr = AttendMonthlyReport.where(year: year, month: month).first

      # CalcCompensateReportJob.perform_later(year, month)

      # if (amr == nil)
      #   # AttendMonthlyReport.generate_reports(year, month)
      #   # CompensateReport.generate_reports(year, month)
      #   CalcAttendMonthReportJob.perform_later(year, month)
      #   CalcCompensateReportJob.perform_later(year, month)
      # else
      #   RefreshAttendMonthlyReportJob.perform_later(amr)
      # end

      # if month == 12
      #   anr = AttendAnnualReport.where(year: year).first
      #   if anr == nil
      #     CalcAttendAnnualReportJob.perform_later(year)
      #   else
      #     RefreshAttendAnnualReportJob.perform_later(anr)
      #   end
      # end

      response_json :ok
    end
  end

  def cancel_approval
    authorize AttendMonthApproval
    ActiveRecord::Base.transaction do
      @attend_month_approval.update(status: 1)

      group_user_ids = Role.attend_and_payment_group_user_ids
      Message.add_notification(@attend_month_approval, "attend_month_cancel_approval", group_user_ids) unless group_user_ids.empty?

      month = @attend_month_approval.month
      year, month = month.split('/').map(& :to_i)
      t = Time.zone.local(year, month, 1).to_date

      start_date = t.beginning_of_month
      end_date = t.end_of_month

      # older_amas = AttendMonthApproval.where("approval_time < ?", @attend_month_approval.approval_time)
      # order_older_amas = older_amas.order(approval_time: :desc)
      # last_ama = order_older_amas.first

      # start_date = last_ama ? last_ama.approval_time : Time.zone.local(1970, 1, 1).to_datetime
      # end_date = @attend_month_approval ? @attend_month_approval.approval_time : Time.zone.now.to_datetime


      SignCardRecord.deal_with_compensation(start_date, end_date, false)
      OvertimeRecord.deal_with_compensation(start_date, end_date, false)
      WorkingHoursTransactionRecord.deal_with_compensation(start_date, end_date, false)
      HolidayRecord.deal_with_compensation(start_date, end_date, false)
      TyphoonQualifiedRecord.deal_with_compensation(start_date, end_date, false)

      CompensateReport.update_reports_after_cancel_approval(@attend_month_approval)

      response_json :ok
    end
  end

  def patch_approval_time
    AttendMonthApproval.all.each do |ama|
      ama.approval_time = ama.updated_at.to_datetime
      ama.save
    end
    response_json :ok
  end

  def options
    result = {}
    # months = AttendMonthApproval.all.pluck(:month)
    result[:months] = AttendMonthApproval.all.pluck(:month)

    result[:status_types] = status_type_table
    response_json result.as_json
  end

  def is_apply_record_compensate
    result = {}
    raise LogicError, {id: 422, message: '日期不规范'}.to_json unless params[:month] <= 12
    if params[:year] && params[:month]
      year, month = "#{params[:year]}".rjust(4, '0'), "#{params[:month]}".rjust(2, '0')
      fmt_month = "#{year}/#{month}"
      normal = "#{params[:year]}/#{params[:month]}"
      status = AttendMonthApproval.where(month: [fmt_month, normal]).first.try(:status)
      is_compensate = status == 'approval' ? true : false

      result[:is_compensate] = is_compensate
      response_json result.as_json
    else
      result[:messages] = 'params year and month is required'
      response_json result.as_json
    end
  end

  def export_xlsx
    authorize AttendMonthApproval
    all_result = search_query
    final_result = format_result(all_result.as_json(include: [], methods: []))
    language = select_language.to_s
    attend_month_approval_export_num = Rails.cache.fetch('attend_month_approval_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + attend_month_approval_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('attend_month_approval_export_number_tag', attend_month_approval_export_num+1)

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'AttendMonthApprovalsController', table_fields_methods: 'get_attend_month_approval_table_fields', table_fields_args: [], my_attachment: my_attachment, sheet_name: 'AttendMonthApprovalTable')
    render json: my_attachment
  end

  private

  def attend_month_approval_params
    params.require(:attend_month_approval).permit(:month)
  end

  def set_attend_month_approval
    @attend_month_approval = AttendMonthApproval.find(params[:id])
  end

  def search_query
    tag = false
    # region = params[:region] || 'macau'

    attend_month_approvals = AttendMonthApproval
                               .by_employee_counts(params[:employee_counts])
                               .by_roster_counts(params[:roster_counts])
                               .by_general_holiday_counts(params[:general_holiday_counts])
                               .by_punching_counts(params[:punching_counts])
                               .by_punching_exception_counts(params[:punching_exception_counts])
                               .by_status(params[:status])
                               .by_month(params[:month])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'
      attend_month_approvals = attend_month_approvals.order("#{params[:sort_column]} #{params[:sort_direction]}")
      tag = true
    end

    attend_month_approvals = attend_month_approvals.order(month: :desc) if tag == false
    attend_month_approvals
  end

  def format_result(json)
    json.map do |hash|
      hash['status_name'] = find_name_for(hash['status'], status_type_table)
      hash
    end
  end

  def find_name_for(type, table)
    table.select { |op| op[:key] == type }.first
  end

  def status_type_table
    [
      {
        key: 'approval',
        chinese_name: '已審批',
        english_name: 'Approval',
        simple_chinese_name: '已审批',
      },

      {
        key: 'not_approval',
        chinese_name: '未審批',
        english_name: 'Not Approval',
        simple_chinese_name: '未审批',
      },
    ]
  end

  def self.get_attend_month_approval_table_fields
    status = {
      chinese_name: '審批狀態',
      english_name: 'Status',
      simple_chinese_name: '审批状态',
      get_value: -> (rst, options){
        ans = ""
        if rst["status_name"] == nil
          ans = find_name_for('not_approval', status_type_table)[options[:name_key]]
        else
          ans = rst["status_name"][options[:name_key]]
        end
        ans
        # rst["status_name"] ? rst["status_name"][options[:name_key]] : rst["status_name"][options[:name_key]]
      }
    }

    month = {
      chinese_name: '考勤月份',
      english_name: 'Month',
      simple_chinese_name: '考勤月份',
      get_value: -> (rst, options){
        rst['month'] ? rst['month'] : ''
      }
    }

    employee_counts = {
      chinese_name: '員工人數',
      english_name: 'Employee Counts',
      simple_chinese_name: '员工人数',
      get_value: -> (rst, options){
        rst['employee_counts'] ? rst['employee_counts'] : ''
      }
    }

    roster_counts = {
      chinese_name: '排班人次',
      english_name: 'Roster Counts',
      simple_chinese_name: '排班人次',
      get_value: -> (rst, options){
        rst['roster_counts'] ? rst['roster_counts'] : ''
      }
    }

    general_holiday_counts = {
      chinese_name: '公休人次',
      english_name: 'General Holiday Counts',
      simple_chinese_name: '公休人次',
      get_value: -> (rst, options){
        rst['general_holiday_counts'] ? rst['general_holiday_counts'] : ''
      }
    }

    punching_counts = {
      chinese_name: '打卡記錄次數',
      english_name: 'Punching Counts',
      simple_chinese_name: '打卡记录次数',
      get_value: -> (rst, options){
        rst['punching_counts'] ? rst['punching_counts'] : ''
      }
    }

    punching_exception_counts = {
      chinese_name: '考勤異常記錄次數',
      english_name: 'Punching Exception Counts',
      simple_chinese_name: '考勤异常记录次数',
      get_value: -> (rst, options){
        rst['punching_exception_counts'] ? rst['punching_exception_counts'] : ''
      }
    }

    table_fields = [status, month, employee_counts, roster_counts,
                    general_holiday_counts, punching_counts, punching_exception_counts]


  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '考勤月份審判'
    elsif select_language.to_s == 'english_name'
      'Attend Month Approval'
    else
      '考勤月份审批'
    end
  end

  def calc_compensate_reports
    ama = AttendMonthApproval.find(params[:id])
    month = ama.month
    year, month = month.split('/').map(& :to_i)
    CalcCompensateReportJob.perform_later(year, month)
  end
end
