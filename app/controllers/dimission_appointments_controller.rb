# coding: utf-8
class DimissionAppointmentsController < ApplicationController
  included GenerateXlsxHelper

  before_action :set_dimission_appointment, only: [:show]

  def index
    authorize DimissionAppointment
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

  def show
    authorize DimissionAppointment
    response_json @dimission_appointment
  end

  def create
    authorize DimissionAppointment
    dimission_appointment = DimissionAppointment.create(dimission_appointment_params)
    response_json dimission_appointment.id
  end

  def update
    authorize DimissionAppointment
    ActiveRecord::Base.transaction do
      dimission_appointment = DimissionAppointment.find(params[:id])
      dimission_appointment.update(dimission_appointment_params)

      dimission_appointment.attend_attachments.each { |a| a.destroy }
      dimission_appointment.approval_items.each { |a| a.destroy }

      questionnaire = Questionnaire.find_by(id: dimission_appointment.questionnaire_id)
      if dimission_appointment.questionnaire_id == nil || (questionnaire && questionnaire.questionnaire_template_id != params[:questionnaire_template_id])
        if questionnaire && questionnaire.questionnaire_template_id != params[:questionnaire_template_id]
          questionnaire.destroy
        end

        questionnaire = Questionnaire.new
        questionnaire.region = params[:region]
        questionnaire.questionnaire_template_id = params[:questionnaire_template_id]
        questionnaire.user_id = params[:user_id]
        questionnaire.is_filled_in = false
        questionnaire.release_user_id = params[:inputter_id]
        questionnaire.release_date = Time.zone.now.strftime('%Y/%m/%d')
        questionnaire.save

        dimission_appointment.questionnaire_id = questionnaire.id
        dimission_appointment.save
      end

      if params[:approval_items]
        params[:approval_items].each do |approval_item|
          dimission_appointment.approval_items.create(approval_item.permit(:user_id, :datetime, :comment))
        end
      end

      if params[:attend_attachments]
        params[:attend_attachments].each do |attend_attachment|
          dimission_appointment.attend_attachments.create(attend_attachment.permit(:file_name, :comment, :attachment_id).merge({creator_id: current_user_id}))
        end
      end

      Message.add_notification(dimission_appointment, "receive_dimission_appointment", dimission_appointment['user_id'])
      Message.add_task(dimission_appointment, "fill_in_dimission_appointment_questionnaire", dimission_appointment['user_id'])

      response_json dimission_appointment.id
    end
  end

  def destroy
    authorize DimissionAppointment
    dimission_appointment = DimissionAppointment.find(params[:id])
    dimission_appointment.destroy
    response_json dimission_appointment.id
  end

  def options
    all_options = {}
    all_options[:status_types] = self.class.status_types
    all_options[:questionnaire_templates] = find_all_questionnaire_templates

    dimission_appointments = DimissionAppointment.all

    user_ids = dimission_appointments.pluck(:user_id)
    users = User.where(id: user_ids)

    department_ids = users.pluck(:department_id)
    departments = Department.where(id: department_ids)

    position_ids = users.pluck(:position_id)
    positions = Position.where(id: position_ids)

    all_options[:departments] = departments
    all_options[:positions] = positions

    all_options[:appointment_time] = dimission_appointments.pluck(:appointment_time).compact.uniq
    response_json all_options
  end

  def statistics
    authorize DimissionAppointment
    result = {}
    result[:all] = DimissionAppointment.all.count
    result[:have_not_started] = DimissionAppointment.where(status: 0).count
    result[:wait_for_filling_in_the_questionnaire] = DimissionAppointment.where(status: 1).count
    result[:wait_for_making_the_appointment] = DimissionAppointment.where(status: 2).count
    result[:finished] = DimissionAppointment.where(status: 3).count
    response_json result.as_json
  end

  def send_content
    authorize DimissionAppointment
    dimission_appointment = DimissionAppointment.find(params[:id])
    result = find_send_content(dimission_appointment)
    response_json result.as_json
  end

  def export_xlsx
    authorize DimissionAppointment
    all_result = search_query
    final_result = format_result(all_result.as_json(include: [], methods: []))
    over_time_export_num = Rails.cache.fetch('over_time_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ( "0000"+over_time_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('over_time_export_number_tag', over_time_export_num+1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json), controller_name: 'DimissionAppointmentsController', table_fields_methods: 'get_table_fields', table_fields_args: [], my_attachment: my_attachment)
    render json: my_attachment
  end

  private

  def set_dimission_appointment

    da = DimissionAppointment.find params[:id]
    # @dimission_appointment = DimissionAppointment.detail_by_id params[:id]

    @dimission_appointment = da.as_json(
      include: {
        user: {include: [:department, :location, :position ], methods: :career_entry_date},
        approval_items: {include: {user: {include: [:department, :location, :position ]}}},
        attend_attachments: {include: :creator},
      }
    )
  end

  def dimission_appointment_params
    params.require(:dimission_appointment).permit(
      :region,
      :user_id,
      :status,
      :questionnaire_template_id,
      :questionnaire_id,
      :last_working_date,
      :duration,
      :had_transfer,
      :last_transfer_date,
      :appointment_date,
      :appointment_time,
      :appointment_location,
      :appointment_description,
      :opinion,
      :other_opinion,
      :summary,
      :inputter_id,
      :input_date,
      :comment,
    )
  end

  def format_result(json)
    json.map do |hash|
      employee = hash['user_id'] ? User.find(hash['user_id']) : nil
      mobile_number = employee.profile.data['personal_information']['mobile_number'] rescue nil
      hash['employee'] = employee ?
      {
        id: hash['user_id'],
        chinese_name: employee['chinese_name'],
        english_name: employee['english_name'],
        simple_chinese_name: employee['chinese_name'],
        empoid: employee['empoid'],
        mobile_number: mobile_number,
        email: employee['email']
      } : nil

      department = employee ? employee.department : nil
      hash['department'] = department ?
      {
        id: department['id'],
        chinese_name: department['chinese_name'],
        english_name: department['english_name'],
        simple_chinese_name: department['chinese_name']
      } : nil

      position = employee ? employee.position : nil
      hash['position'] = position ?
      {
        id: position['id'],
        chinese_name: position['chinese_name'],
        english_name: position['english_name'],
        simple_chinese_name: position['chinese_name']
      } : nil

      template = (hash['questionnaire_template_id'] ? QuestionnaireTemplate.find(hash['questionnaire_template_id']) : nil) rescue nil
      hash['questionnaire_template'] = template ?
      {
        id: hash['questionnaire_template_id'],
        chinese_name: template['chinese_name'],
        english_name: template['english_name'],
        simple_chinese_name: template['chinese_name']
      } : nil

      hash['status_type_name'] = self.class.find_status_type_name(hash['status'])

      inputter = hash['inputter_id'] ? User.find(hash['inputter_id']) : nil
      hash['inputter'] = inputter ?
      {
        id: hash['inputter_id'],
        chinese_name: inputter['chinese_name'],
        english_name: inputter['english_name'],
        simple_chinese_name: inputter['chinese_name']
      } : nil

      hash
    end
  end

  def search_query
    tag = false
    region = params[:region]
    lang_key = params[:lang] || 'zh-TW'

    lang = if lang_key == 'zh-TW'
             'chinese_name'
           elsif lang_key == 'zh-US'
             'english_name'
           else
             'simple_chinese_name'
           end

    dimission_appointments = DimissionAppointment.where(region: region)
                               .by_employee_name(params[:employee_name], lang)
                               .by_empoid(params[:empoid])
                               .by_inputter_name(params[:inputter_name], lang)
                               .by_input_date(params[:input_date])
                               .by_appointment_date(params[:appointment_start_date], params[:appointment_end_date])
                               .by_last_working_date(params[:last_working_start_date], params[:last_working_end_date])
                               .by_status_type(params[:status])
                               .by_template_id(params[:questionnaire_template_id])
                               .by_appointment_time(params[:appointment_time])
                               .by_department_id(params[:department_id])
                               .by_position_id(params[:position_id])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'
      if params[:sort_column] == 'empoid' || params[:sort_column] == 'department_id' || params[:sort_column] == 'position_id'
        dimission_appointments = dimission_appointments.includes(:user).order("users.#{params[:sort_column]} #{params[:sort_direction]}")
      else
        dimission_appointments = dimission_appointments.order("#{params[:sort_column]} #{params[:sort_direction]}")
      end
      tag = true
    end

    dimission_appointments = dimission_appointments.order(created_at: :desc) if tag == false

    dimission_appointments
  end

  def self.find_status_type_name(type)
    type_options = status_types
    type_options.select { |op| op[:key] == type }.first
  end

  def self.status_types
    [
      {
        key: 'have_not_started',
        chinese_name: '未啟動',
        english_name: 'No start',
        simple_chinese_name: '未启动'
      },
      {
        key: 'wait_for_filling_in_the_questionnaire',
        chinese_name: '待填問卷',
        english_name: 'Fill in',
        simple_chinese_name: '待填问卷'
      },
      {
        key: 'wait_for_making_the_appointment',
        chinese_name: '待面談',
        english_name: 'Meeting',
        simple_chinese_name: '待面谈'
      },
      {
        key: 'finished',
        chinese_name: '已完成',
        english_name: 'Completed',
        simple_chinese_name: '已完成'
      }
    ]
  end

  def find_all_questionnaire_templates
    QuestionnaireTemplate.all.as_json
  end

  def self.get_table_fields
    status_type = {
      chinese_name: '入職面談狀態',
      english_name: 'Interview status',
      simple_chinese_name: '入职面谈状态',
      get_value: -> (rst, options){
        find_status_type_name(rst['status'])[options[:name_key]]
      }
    }

    name = {
      chinese_name: '員工姓名',
      english_name: 'Name',
      simple_chinese_name: '员工姓名',
      get_value: -> (rst, options){
        rst["employee"][options[:name_key]]
      }
    }

    employee_id = {
      chinese_name: '員工編號',
      english_name: 'ID',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        user = User.find(rst["user_id"])
        user["empoid"]
      }
    }

    department = {
      chinese_name: '部門',
      english_name: 'Department',
      simple_chinese_name: '部门',
      get_value: -> (rst, options){
        # user = User.find(rst["user_id"])
        # department = Department.find(user['department_id'])
        # department ? department[options[:name_key]] : ''
        rst['department'] ? rst['department'][options[:name_key]] : ''
      }
    }

    position = {
      chinese_name: '職位',
      english_name: 'Position',
      simple_chinese_name: '职位',
      get_value: -> (rst, options){
        # user = User.find(rst["user_id"])
        # position = Position.find(user['position_id'])
        # position ? position[options[:name_key]] : ''
        rst['position'] ? rst['position'][options[:name_key]] : ''
      }
    }

    last_working_date = {
      chinese_name: '最後工作日期',
      english_name: 'Last working date',
      simple_chinese_name: '最后工作日期',
      get_value: -> (rst, options){
        rst['last_working_date'] ? Time.zone.parse(rst['last_working_date']).strftime('%Y/%m/%d') : ''
      }
    }

    template = {
      chinese_name: '問卷模板',
      english_name: 'Questionnaire template',
      simple_chinese_name: '问卷模板',
      get_value: -> (rst, options){
        rst['questionnaire_template'] ? rst['questionnaire_template'][options[:name_key]] : ''
      }
    }

    appointment_date = {
      chinese_name: '面談日期',
      english_name: 'Interview date',
      simple_chinese_name: '面谈日期',
      get_value: -> (rst, options){
        rst['appointment_date'] ? Time.zone.parse(rst['appointment_date']).strftime('%Y/%m/%d') : ''
      }
    }

    appointment_time = {
      chinese_name: '面談時間',
      english_name: 'Interview time',
      simple_chinese_name: '面谈时间',
      get_value: -> (rst, options){
        rst['appointment_time'] ? rst['appointment_time'] : ''
      }
    }

    appointment_location = {
      chinese_name: '面談地點',
      english_name: 'Interview site',
      simple_chinese_name: '面谈地点',
      get_value: -> (rst, options){
        rst['appointment_location'] ? rst['appointment_location'] : ''
      }
    }

    appointment_description = {
      chinese_name: '面談說明',
      english_name: 'Interviews',
      simple_chinese_name: '面谈说明',
      get_value: -> (rst, options){
        rst['appointment_description'] ? rst['appointment_description'] : ''
      }
    }

    inputter = {
      chinese_name: '錄入人',
      english_name: 'Inputer',
      simple_chinese_name: '录入人',
      get_value: -> (rst, options){
        rst["inputter"] ? rst["inputter"][options[:name_key]] : ''
      }
    }

    input_date = {
      chinese_name: '錄入日期',
      english_name: 'Enter date',
      simple_chinese_name: '录入日期',
      get_value: -> (rst, options){
        rst["input_date"] ? Time.zone.parse(rst["input_date"]).strftime('%Y/%m/%d') : ''
      }
    }

    comment = {
      chinese_name: '備註',
      english_name: 'Remarks',
      simple_chinese_name: '备注',
      get_value: -> (rst, options){
        rst["comment"] ? rst["comment"] : ''
      }
    }

    [ status_type, name, employee_id, department, position, last_working_date,
                     template, appointment_date, appointment_time, appointment_location,
                     appointment_description, inputter, input_date, comment ]


  end

  def find_send_content(dimission_appointment)
    dimission_appointment = DimissionAppointment.find(params[:id])
    result = {}
    appointment_date = dimission_appointment.appointment_date ? dimission_appointment.appointment_date.strftime("%Y/%m/%d") : '0000/00/00'
    appointment_time = dimission_appointment.appointment_time ? dimission_appointment.appointment_time : '00:00-00-00'
    appointment_location = dimission_appointment.appointment_location ? dimission_appointment.appointment_location : ''
    year, month, day = appointment_date.split('/').map(& :to_i)
    start_time = appointment_time.split('-').first
    hour, min = start_time.split(':').map(& :to_i)

    result[:sms] = "太陽城集團人力資源部短訊：感謝您這段日子對集團的努力付出和貢獻！茲 通知閣下進行離職面談。
                   請於[#{year}年#{month}月#{day}日 #{hour}時#{min}分],
                    前來#{appointment_location}面談，務必提前填寫 離職面談調查問卷 ，謝謝。
                   如有任何疑問，請於辦公時間內致電太陽城人力資源部： +853 8891 1332"

    result[:email] = "感謝您這段日子對集團的努力付出和貢獻！請閣下務必提前填寫 離職面談調查問卷 ，并準時進行離職面談。
                     面談時間：[#{year}年#{month}月#{day}日 #{hour}時#{min}分]
                     面談地點：#{appointment_location}
                     如有任何疑問，請於辦公時間內致電太陽城人力資源部： +853 8891 1332"

    result
  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '離職面談記錄'
    elsif select_language.to_s == 'english_name'
      'Exit interview records'
    else
      '离职面谈记录'
    end

  end
end
