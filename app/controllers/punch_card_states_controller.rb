# coding: utf-8
class PunchCardStatesController < ApplicationController
  include GenerateXlsxHelper
  def update
    authorize PunchCardState
    ActiveRecord::Base.transaction do
      pcs = PunchCardState.find(params[:id])
      pcs.update(punch_card_state_params)

      d = params[:effective_date].in_time_zone.to_date
      pcs.start_date = d
      pcs.effective_date = d

      time_now = Time.zone.now.to_date
      pcs.is_effective = pcs.effective_date <= time_now
      pcs.save!

      if pcs.start_date <= time_now
        current = pcs.histories.order(created_at: :desc).first

        if current
          # current.end_date = time_now
          current.end_date = pcs.start_date
          current.is_current = false
          current.save!
        end

        pcs.histories.create(
          pcs.attributes.merge({ id: nil, created_at: nil, updated_at: nil, source_id: nil, is_current: true })
        )
      end

      PunchCardState.update_attend_states(pcs)

      response_json :ok
    end
  end

  def histories
    params[:page] ||= 1
    meta = {}
    all_result = PunchCardState
                   .where(user_id: params[:user_id])
                   .where.not(source_id: nil)
                   .order(created_at: :desc)

    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    final_result = format_result(result.as_json(include: [], methods: []))

    response_json final_result, meta: meta
  end

  def report
    authorize PunchCardState
    params[:page] ||= 1
    meta = {}

    user_result = query_report

    meta['total_count'] = user_result.count
    result = user_result.page(params[:page].to_i).per(20)
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    new_result = format_report(result.as_json(include: [], methods: []))

    response_json new_result, meta: meta
  end

  def options
    all_options = [:employment_status].reduce({}) do |result, type|
      result[type] = Config.get('selects')[type.to_s]['options']
      result
    end

    response_json all_options.as_json
  end

  def report_export_xlsx
    authorize PunchCardState
    all_result = query_report
    final_result = format_report(all_result)
    language = select_language.to_s
    punch_card_state_report_export_num = Rails.cache.fetch('punch_card_state_report_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + punch_card_state_report_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('punch_card_state_report_export_number_tag', punch_card_state_report_export_num+1)

    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'PunchCardStatesController', table_fields_methods: 'get_punch_card_state_report_table_fields', table_fields_args: [] , my_attachment: my_attachment, sheet_name: 'PCSTable')
    render json: my_attachment
  end

  def update_is_current_for_all
    PunchCardState.where(source_id: nil).each do |pcs|
      current = pcs.histories.order(created_at: :desc).first
      if current
        current.is_current = true
        current.save
      end
    end
    response_json :ok
  end

  private

  def punch_card_state_params
    params.require(:punch_card_state).permit(
      :user_id,
      :is_need,
      :effective_date,
      :creator_id,
    )
  end

  def query_report
    user_query = User.all
    user_query_with_department = params[:department_id] ? user_query.where(department_id: params[:department_id]) : user_query
    user_result = params[:user_ids] ? user_query_with_department.where(id: params[:user_ids]) : user_query_with_department

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      default_order = "empoid ASC"
      default_order_with_self = "users.empoid ASC"

      if params[:sort_column] == 'department'
        user_result= user_result.order("department_id #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'position'
        user_result= user_result.order("position_id #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'date_of_employment'
        user_result = user_result.includes(:profile).order("profiles.data -> 'position_information' -> 'field_values' -> 'date_of_employment' #{params[:sort_direction]}", default_order)
      elsif params[:sort_column] == 'is_need'
        user_result = user_result.includes(:punch_card_states).where("punch_card_states.is_current", true).order("punch_card_states.is_need #{params[:sort_direction]}", default_order_with_self)
      elsif params[:sort_column] == 'effective_date'
        user_result = user_result.includes(:punch_card_states).where("punch_card_states.is_current", true).order("punch_card_states.effective_date #{params[:sort_direction]}", default_order_with_self)
      else
        user_result = user_result.order("#{params[:sort_column]} #{params[:sort_direction]}", default_order)
      end
    else
      user_result = user_result.order(empoid: :asc)
    end

    user_result
  end

  def format_result(json)
    json.map do |hash|
      creator = hash['creator_id'] ? User.find(hash['creator_id']) : nil
      hash['creator'] = creator ?
                            {
                                id: creator['id'],
                                chinese_name: creator['chinese_name'],
                                english_name: creator['english_name'],
                                simple_chinese_name: creator['chinese_name'],
                            } : nil

      hash
    end
  end

  def format_report(result)
    new_result = result.map do |u|
      user = User.find_by(id: u['id'])
      if user
        department = user.department_id ? Department.find_by(id: user.department_id) : nil
        position = user.position_id ? Position.find_by(id: user.position_id) : nil
        # punch_card_state = PunchCardState.where(user_id: user.id, source_id: nil).first
        # punch_card_state = PunchCardState.where(user_id: user.id, source_id: nil).first
        punch_card_state = PunchCardState.where(user_id: user.id, is_current: true).first
        {
          user: user,
          date_of_employment: user.profile.data['position_information']['field_values']['date_of_employment'],
          employment_status: user.profile.data['position_information']['field_values']['employment_status'],
          department: department,
          position: position,
          pach_card_state: punch_card_state,
        }
      end
    end
    new_result.as_json
  end

  def get_punch_card_state_report_table_fields
    empoid = {
      chinese_name: '員工編號',
      english_name: 'empoid',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        "\s#{rst["user"]["empoid"].rjust(8, '0')}"
      }
    }

    name = {
      chinese_name: '員工姓名',
      english_name: 'Name',
      simple_chinese_name: '员工姓名',
      get_value: -> (rst, options){
        rst["user"][options[:name_key].to_s]
      }
    }

    department = {
      chinese_name: '部門',
      english_name: 'Department',
      simple_chinese_name: '部门',
      get_value: -> (rst, options){
        rst['department'] ? rst['department'][options[:name_key].to_s] : ''
      }
    }

    position = {
      chinese_name: '職位',
      english_name: 'Position',
      simple_chinese_name: '职位',
      get_value: -> (rst, options){
        rst['position'] ? rst['position'][options[:name_key].to_s] : ''
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

    employment_status = {
      chinese_name: '在職類別',
      english_name: 'Employment Status',
      simple_chinese_name: '在职类别',
      get_value: -> (rst, options){
        ans = ''
        if rst['employment_status']
          ops = Config.get('selects')['employment_status']['options']
          op = ops.select { |o| o["key"] == rst['employment_status'] }.first
          ans = op[options[:name_key].to_s]
        end
        ans
      }
    }

    is_need = {
      chinese_name: '是否需要打卡',
      english_name: 'Is Need',
      simple_chinese_name: '是否需要打卡',
      get_value: -> (rst, options){
        ans = ''
        if rst['pach_card_state']
          ans = rst['pach_card_state']['is_need'] ? '是' : '否'
        end
        ans
      }
    }

    effective_date = {
      chinese_name: '生效日期',
      english_name: 'Effective Date',
      simple_chinese_name: '生效日期',
      get_value: -> (rst, options){
        rst['pach_card_state'] ? rst['pach_card_state']['effective_date'] : ''
      }
    }


    table_fields = [empoid, name, department, position, entry_date,
                    employment_status, is_need, effective_date]


  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '打卡設置報表'
    elsif select_language.to_s == 'english_name'
      'Punch Card State Report'
    else
      '打卡设置报表'
    end
  end
end
