# coding: utf-8
class AttendsController < ApplicationController
  include GenerateXlsxHelper

  def index_by_ids
    query = Attend.where(id: params[:ids])
    final_result = self.class.format_result(query.as_json(
        include: { attend_states: {} },
        methods: []))
    response_json final_result
  end

  def raw_index
    params[:page] ||= 1
    meta = {}
    all_result = self.class.search_query(params)
    meta['total_count'] = all_result.count
    result = all_result.page( params[:page].to_i).per(20)
    meta['total_count'] = result.total_count
    meta['total_page'] = result.total_pages
    meta['current_page'] = result.current_page

    final_result = self.class.format_result(result.as_json(
      include: { attend_states: {} },
      methods: []))

    response_json final_result, meta: meta

  end


  def index_by_current_user
    raw_index
  end


  def index_by_department
    authorize Attend
    raw_index
  end

  def index
    authorize Attend
    raw_index
  end

  def options
    result = {}

    reserve_holiday_settings = ReservedHolidaySetting.all.map do |setting|
      {
        key: "#{setting.id}",
        chinese_name: setting.chinese_name,
        english_name: setting.english_name,
        simple_chinese_name: setting.simple_chinese_name,
      }
    end

    result[:attend_states_table] = AttendState.state_table + reserve_holiday_settings
    response_json result.as_json
  end

  def import
    authorize Attend
    raise LogicError, {id: 422, message: '参数不完整'}.to_json unless params[:file]
    file = params[:file]
    raise LogicError, {id: 422, message: '时间不正确'}.to_json if params[:start_filter_date] > params[:end_filter_date]
    start_filter_date = params[:start_filter_date] ? params[:start_filter_date].in_time_zone.to_datetime : nil
    end_filter_date = params[:end_filter_date] ? params[:end_filter_date].in_time_zone.to_datetime : nil

    attends_xlsx = Roo::Spreadsheet.open(file, extension: :xlsx)
    # attends = []
    att_ids = []

    header = attends_xlsx.sheet(attends_xlsx.sheets.first).row(1)

    table_data = (2..attends_xlsx.last_row).reduce({}) do |coll, i|
      row = Hash[[header, attends_xlsx.row(i)].transpose]
      row_user = User.find_by(empoid: row["員工編號"].to_s.rjust(8, '0'))

      if row['打卡時間'] && row_user
        date_time = row["打卡時間"].split(' ')
        row_time_arr = date_time.last.split(':').map(& :to_i)
        row_date_arr = date_time.first.split('/').map(& :to_i)

        if date_time.length != 2 || row_time_arr.length != 3 || row_date_arr.length != 3
          response_json ({ message: 'time format is wrong, the correct format: 2017/1/1 08:00:00', is_ok: false })
          return
        end

        row_time = Time
                     .zone
                     .local(row_date_arr[0], row_date_arr[1], row_date_arr[2],
                            row_time_arr[0], row_time_arr[1], row_time_arr[2])
                     .to_datetime

        row_date = nil

        if start_filter_date && end_filter_date
          if row_time.to_date >= start_filter_date.to_date && row_time.to_date <= end_filter_date.to_date + 1.day
            coll[row_user.id] = Array(coll[row_user.id]).push(row_time)
            row_date = Time.zone.local(row_date_arr[0], row_date_arr[1], row_date_arr[2]).to_date
          end
        else
          coll[row_user.id] = Array(coll[row_user.id]).push(row_time)
          row_date = Time.zone.local(row_date_arr[0], row_date_arr[1], row_date_arr[2]).to_date
        end

        if row_date
          if (att = Attend.find_attend_by_user_and_date(row_user.id, row_date)) != nil
            # attends.push(att)
            att_ids.push(att.id)
          else
            new_att = Attend.create(user_id: row_user.id, attend_date: row_date, attend_weekday: row_date.wday)
            # attends.push(new_att)
            att_ids.push(new_att.id)
          end

          if (before_att = Attend.find_attend_by_user_and_date(row_user.id, (row_date - 1.day))) != nil
            att_ids.push(before_att.id)
          else
            new_before_row_date = row_date - 1.day
            new_before_att = Attend.create(user_id: row_user.id, attend_date: new_before_row_date, attend_weekday: new_before_row_date.wday)
            att_ids.push(new_before_att.id)
          end
        end

        coll
      else
        coll
      end
    end

    attends = Attend.where(id: att_ids.compact.uniq)

    if table_data.empty? || attends.empty?
      response_json ({ message: 'Import Unsuccessful', is_ok: false })
    else
      all_overtime_records = OvertimeRecord.all
      all_holiday_records = HolidayRecord.all
      all_sign_card_records = SignCardRecord.all
      attends.each do |att|
        if att.roster_object # 有排班才更新
          can_punch = att&.user.punch_card_state_of_date(att.attend_date) == true
          user_data = table_data[att.user_id]

          roster_object = att.roster_object
          is_general_holiday = roster_object.is_general_holiday
          class_setting = roster_object.class_setting
          roster_date = roster_object.roster_date



          if (is_general_holiday == nil || is_general_holiday == false) && (!class_setting.nil? || roster_object.working_time != nil)
            punching_card_records = user_data.select do |record|
              attend_date = att.attend_date.to_date
              record.to_date == attend_date ||
                record.to_date == (attend_date + 1.day)
              # (record > att.attend_date && record <= (att.attend_date + 1.day))
            end

            if punching_card_records.count > 0

              # initial all
              att.attend_states.where.not(auto_state: nil).each { |state| state.destroy if state }

              true_records = WorkingHoursTransactionRecord.where(source_id: nil, is_deleted: [false, nil])

              whts = true_records.where(user_a_id: roster_object.user_id, apply_date: roster_object.roster_date)
                       .or(true_records.where(user_b_id: roster_object.user_id, apply_date: roster_object.roster_date))

              wht = whts.first

              plan_start_time = nil
              plan_end_time = nil
              tmp_plan_start_time = nil
              tmp_plan_end_time = nil

              if class_setting
                # 正常开始、结束时间
                tmp_plan_start_time, tmp_plan_end_time = att.compute_time(roster_date, class_setting)
              elsif roster_object.working_time
                tmp_plan_start_time, tmp_plan_end_time = att.transform_working_time(roster_date, roster_object.working_time)
              end

              if wht
                wht_start_time, wht_end_time = wht.fmt_final_time

                should_merge = (wht.apply_type == 'borrow_hours' && wht.user_a_id == roster_object.user_id) || (wht.apply_type == 'return_hours' && wht.user_b_id == roster_object.user_id) ? false : true

                if should_merge
                  plan_start_time = tmp_plan_start_time < wht_start_time ? tmp_plan_start_time : wht_start_time
                  plan_end_time = tmp_plan_end_time > wht_end_time ? tmp_plan_end_time : wht_end_time
                else
                  if tmp_plan_start_time == wht_start_time
                    plan_start_time = wht_end_time < tmp_plan_end_time ? wht_end_time : tmp_plan_end_time
                  else
                    plan_start_time = tmp_plan_start_time < wht_start_time ? tmp_plan_start_time : wht_start_time
                  end

                  if tmp_plan_end_time == wht_end_time
                    plan_end_time = wht_start_time > tmp_plan_start_time ? wht_start_time : tmp_plan_start_time
                  else
                    plan_end_time = tmp_plan_end_time > wht_end_time ? tmp_plan_end_time : wht_end_time
                  end
                end
              end

              plan_start_time = plan_start_time ? plan_start_time : tmp_plan_start_time
              plan_end_time = plan_end_time ? plan_end_time : tmp_plan_end_time

              # 迟到时间点
              late_be_allowed_minutes = class_setting ? class_setting&.late_be_allowed&.to_i : 0
              late_time = plan_start_time + late_be_allowed_minutes.minute
              # 早退时间点
              leave_be_allowed_minutes = class_setting ? class_setting&.leave_be_allowed&.to_i : 0
              leave_early_time = plan_end_time - leave_be_allowed_minutes.minute

              # 中间时间点
              mid_time = Time.zone.at((plan_start_time.to_i + plan_end_time.to_i) / 2).to_datetime

              # 最晚上班时间点、最早下班时间点
              latest_start_punch = earliest_end_punch = mid_time
              # 最早上班时间点
              earliest_start_punch = plan_start_time - 120.minute
              # 最晚下班时间点
              latest_end_punch = plan_end_time + 120.minute

              on_punching_card_records = punching_card_records.select { |record| record >= earliest_start_punch && record <= latest_start_punch }
              if on_punching_card_records.count == 0 && att.on_work_time == nil
                # att.on_work_time = punching_card_records.sort.first
                att.attend_states.find_or_create_by(auto_state: 'on_work_punching_exception') if can_punch
              else
                swt = on_punching_card_records.sort.first # 最早的時間為上班時間
                true_swt = swt ? swt : att.on_work_time
                att.on_work_time = true_swt

                if true_swt > late_time
                  att.attend_states.find_or_create_by(auto_state: 'late') if can_punch
                end
              end

              # 处理下班
              off_punching_card_records = punching_card_records.select { |record| record > earliest_end_punch && record <= latest_end_punch }
              if off_punching_card_records.count == 0 && att.off_work_time == nil
                # att.off_work_time = punching_card_records.sort.last
                att.attend_states.find_or_create_by(auto_state: 'off_work_punching_exception') if can_punch
              else
                # 应下班 - 最迟下班
                pcr = off_punching_card_records.select { |log| log >= plan_end_time && log <= latest_end_punch }

                # 最迟時間為下班時間
                ewt = pcr.count > 0 ? pcr.sort.last : off_punching_card_records.select { |log| log >= earliest_end_punch && log <= plan_end_time }.sort.last
                true_ewt = ewt ? ewt : att.off_work_time
                att.off_work_time = true_ewt

                if true_ewt < leave_early_time
                  att.attend_states.find_or_create_by(auto_state: 'leave_early_by_auto') if can_punch
                end
              end

              att.save!

              overtime_records = all_overtime_records
                                   .where(user_id: att.user_id,
                                          source_id: nil,
                                          is_deleted: [false, nil])
                                   .where("overtime_start_date <= ? AND overtime_end_date >= ?", att.attend_date, att.attend_date)
              has_overtime_records = overtime_records.count > 0

              holiday_records = all_holiday_records
                                  .where(user_id: att.user_id,
                                         source_id: nil,
                                         is_deleted: [false, nil])
                                  .where("start_date <= ? AND end_date >= ?", att.attend_date, att.attend_date)
              has_holiday_records = holiday_records.count > 0

              sign_card_records = all_sign_card_records
                                    .where(user_id: att.user_id,
                                           source_id: nil,
                                           is_deleted: [false, nil])
                                    .where(sign_card_date: att.attend_date)
              has_sign_card_records = sign_card_records.count > 0

              if (att.on_work_time != nil || att.off_work_time != nil || has_sign_card_records) &&
                 has_holiday_records &&
                 !has_overtime_records
                att.attend_states.find_or_create_by(auto_state: 'punching_card_on_holiday_exception') if can_punch
              end
            end
          end
        end
      end
    end

    attends.map { |att| att.attend_date }.uniq.map { |a_d| a_d.strftime('%Y/%m') }.compact.uniq.map do |d_str|
      y = d_str.split('/').first.to_i
      m = d_str.split('/').second.to_i
      Time.zone.local(y, m, 1).to_date
    end.each { |att_d| AttendMonthApproval.update_data(att_d) }
  end

  def all_attends
    result = Attend.all
    final_result = self.class.format_result(result.as_json(
                                   include: { attend_states: {} },
                                   methods: []))

    response_json final_result
  end

  def export_xlsx
    authorize Attend
    attend_export_num = Rails.cache.fetch('attend_export_number_tag', :expires_in => 24.hours) do
      1
    end
    export_id = ("0000" + attend_export_num.to_s).match(/\d{4}$/)[0]
    Rails.cache.write('attend_export_number_tag', attend_export_num+1)
    my_attachment = current_user.my_attachments.create(status: :generating, file_name: "#{export_title}_#{Time.zone.now.strftime('%Y%m%d')}#{export_id}.xlsx")
    GenerateAttendExportContainSelectJob.perform_later(params.with_indifferent_access, my_attachment)
    render json: my_attachment
  end

  def self.select_and_generate_report(params, my_attachment)
    all_result = search_query(params)
    final_result = format_result(all_result.as_json(include: { attend_states: {} }, methods: []))
    GenerateAttendReportJob.perform_later(result: JSON.parse(final_result.to_json),controller_name: 'AttendsController', table_fields_methods: 'get_attend_table_fields', table_fields_args: [], my_attachment: my_attachment, sheet_name: 'AttendTable')
  end


  def self.search_query(params)
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

    Attend.complete_attend_table_for(params[:location_ids],
                                     params[:department_ids],
                                     params[:user_ids],
                                     params[:attend_start_date].in_time_zone.to_date,
                                     params[:attend_end_date].in_time_zone.to_date
                                    )

    attends = Attend
                .by_location_ids(params[:location_ids], params[:attend_start_date], params[:attend_end_date])
                .by_department_ids(params[:department_ids], params[:attend_start_date], params[:attend_end_date])
                .by_users(params[:user_ids])
                .by_no_admin
                .by_attend_date(params[:attend_start_date], params[:attend_end_date])
                .by_attend_states(params[:attend_states])

    if params[:sort_column]
      params[:sort_direction] ||= 'asc'

      attend_date_order = "attend_date asc"
      attend_date_order_with_self = "attends.attend_date asc"
      # default_order = "created_at DESC"

      if params[:sort_column] == 'department' || params[:sort_column] == 'position'
        attends = attends.includes(:user).order("users.#{params[:sort_column]}_id #{params[:sort_direction]}", "users.empoid asc", attend_date_order_with_self)
      elsif params[:sort_column] == 'user.empoid'
        attends = attends.includes(:user).order("users.empoid #{params[:sort_direction]}", attend_date_order_with_self)
      elsif params[:sort_column] == 'user'
        attends = attends.order("user_id #{params[:sort_direction]}", attend_date_order)
      else
        attends = attends.order("#{params[:sort_column]} #{params[:sort_direction]}")
      end
      tag = true
    end

    # attends = attends.order(created_at: :desc) if tag == false
    attends = attends.includes(:user).order("users.empoid asc", "attends.attend_date asc") if tag == false
    # attends = attends.includes(:user).order("users.empoid ASC, attends.created_at ASC") if tag == false
    attends
  end

  def self.format_result(json)
    json.map do |hash|
      attend = Attend.find(hash['id'])
      att_datetime = attend&.attend_date&.to_datetime
      user = hash['user_id'] ? User.find(hash['user_id']) : nil

      date_of_employment = user ? user.profile.data['position_information']['field_values']['date_of_employment'] : nil
      entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil
      not_entry = attend.attend_date < entry

      roster_object = hash['roster_object_id'] ? RosterObject.find_by(id: hash['roster_object_id']) : nil
      hash['user'] = user ?
      {
        id: hash['user_id'],
        chinese_name: user['chinese_name'],
        english_name: user['english_name'],
        simple_chinese_name: user['chinese_name'],
        empoid: user['empoid'],
      } : nil

      location = user ? ProfileService.location(user, att_datetime) : nil
      hash['location'] = location ?
      {
        id: location['id'],
        chinese_name: location['chinese_name'],
        english_name: location['english_name'],
        simple_chinese_name: location['chinese_name']
      } : nil

      department = user ? ProfileService.department(user, att_datetime) : nil
      hash['department'] = department ?
      {
        id: department['id'],
        chinese_name: department['chinese_name'],
        english_name: department['english_name'],
        simple_chinese_name: department['chinese_name']
      } : nil

      position = user ? ProfileService.position(user, att_datetime) : nil
      hash['position'] = position ?
      {
        id: position['id'],
        chinese_name: position['chinese_name'],
        english_name: position['english_name'],
        simple_chinese_name: position['chinese_name']
      } : nil

      hash['roster_object'] = roster_object ?
      {
        id: roster_object.id,
        is_general_holiday: roster_object.is_general_holiday,
        class_setting: (roster_object.class_setting.as_json rescue nil),
        working_time: roster_object.working_time,
        holiday_type: roster_object.holiday_type,
        holiday_record_id: roster_object.holiday_record_id,
        holiday_record: (roster_object.holiday_record.as_json rescue nil),
        special_type: roster_object.special_type,
        is_active: roster_object.is_active,
        borrow_return_type: roster_object.borrow_return_type,
        working_hours_transaction_record_id: roster_object.working_hours_transaction_record_id,
        working_hours_transaction_record: (roster_object.working_hours_transaction_record.as_json rescue nil)
      } : nil

      roster_list = RosterList.find_by(id: roster_object.try(:roster_list_id))
      is_roster_object_draft = roster_list ? roster_list.status == 'is_draft' : nil
      hash['is_roster_object_draft'] = is_roster_object_draft
      roster_list_is_draft = (roster_list && roster_list.status == 'is_draft')

      original_work = AttendCalculateService.cal_original_work_time(attend)
      hash['original_work_time'] = is_roster_object_draft || not_entry ? nil : original_work[:original_work_time]
      hash['original_work_hours'] = is_roster_object_draft || not_entry ? nil : original_work[:original_work_hours]
      hash['holiday_type'] = original_work[:holiday_type]


      not_roster = (roster_object == nil)
      roster_list_is_draft = (roster_list && roster_list.status == 'is_draft')
      has_annual_leave = HolidayRecord.where(user_id: user.try(:id),
                                             source_id: nil,
                                             holiday_type: 'annual_leave',
                                             is_deleted: [false, nil])
                           .where("start_date <= ? AND end_date >= ?", hash['attend_date'], hash['attend_date']).count > 0

      hash['should_show_annual_leave'] = (not_roster || roster_list_is_draft) && has_annual_leave ? true : false

      # signcard
      on_signcard_records = SignCardRecord.where(user_id: user.try(:id),
                                                 source_id: nil,
                                                 is_get_to_work: true,
                                                 is_deleted: [false, nil],
                                                 sign_card_date: hash['attend_date'])
      has_on_signcard = on_signcard_records.count > 0
      on_signcard = on_signcard_records.first
      signcard_on_work_time = has_on_signcard ? on_signcard.sign_card_time.strftime("%H:%M") : nil
      signcard_on_work_time_is_next = has_on_signcard ? on_signcard.is_next : nil
      hash['has_on_signcard'] = has_on_signcard
      hash['signcard_on_work_time'] = signcard_on_work_time
      hash['signcard_on_work_time_is_next'] = signcard_on_work_time_is_next

      off_signcard_records = SignCardRecord.where(user_id: user.try(:id),
                                                  source_id: nil,
                                                  is_get_to_work: false,
                                                  is_deleted: [false, nil],
                                                  sign_card_date: hash['attend_date'])

      has_off_signcard = off_signcard_records.count > 0
      off_signcard = off_signcard_records.first
      signcard_off_work_time = has_off_signcard ? off_signcard.sign_card_time.strftime("%H:%M") : nil
      signcard_off_work_time_is_next = has_off_signcard ? off_signcard.is_next : nil
      hash['has_off_signcard'] = has_off_signcard
      hash['signcard_off_work_time'] = signcard_off_work_time
      hash['signcard_off_work_time_is_next'] = signcard_off_work_time_is_next

      holiday_records = HolidayRecord
                          .where(user_id: user&.id,
                                 source_id: nil,
                                 is_deleted: [false, nil])
                          .where("start_date <= ? AND end_date >= ?", hash['attend_date'], hash['attend_date'])
      hash['has_holiday_records'] = holiday_records.count > 0

      overtime_records = OvertimeRecord
                           .where(user_id: user&.id,
                                  source_id: nil,
                                  is_deleted: [false, nil])
                           .where("overtime_start_date <= ? AND overtime_end_date >= ?", hash['attend_date'], hash['attend_date'])
      hash['has_overtime_records'] = overtime_records.count > 0
      is_holiday_or_general_holiday = ((holiday_records.count > 0) || (roster_object && roster_object.is_general_holiday == true))
      hash['is_holiday_or_general_holiday'] = is_holiday_or_general_holiday
      # 实际工作时间 实际工作时长
      real_work = AttendCalculateService.cal_real_work_time_and_hours(
        attend,
        signcard_on_work_time,
        signcard_off_work_time,
        signcard_on_work_time_is_next,
        signcard_off_work_time_is_next,
        is_holiday_or_general_holiday
      )
      # hash['cell_color_type'] = real_work[:color_type]x
      hash['real_work_time'] = real_work[:real_work_time]
      hash['real_work_hours'] = real_work[:real_work_hours]

      hash
    end
  end

  def self.get_attend_table_fields
    empoid = {
      chinese_name: '員工編號',
      english_name: 'empoid',
      simple_chinese_name: '员工编号',
      get_value: -> (rst, options){
        "#{rst["user"][:empoid]&.rjust(8, '0')}"
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

    location = {
      chinese_name: '場館',
      english_name: 'Location',
      simple_chinese_name: '场馆',
      get_value: -> (rst, options){
        rst['location'] ? rst['location'][options[:name_key]] : ''
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

    attend_date = {
      chinese_name: '考勤日期',
      english_name: 'Attend date',
      simple_chinese_name: '考勤日期',
      get_value: -> (rst, options){
        rst['attend_date'] ? rst['attend_date'] : ''
      }
    }

    attend_weekday = {
      chinese_name: '星期',
      english_name: 'Weekday',
      simple_chinese_name: '星期',
      get_value: -> (rst, options){
        rst['attend_weekday'] ? dict_of_weekday(rst['attend_weekday'].to_i) : ''
      }
    }

    work_hours = {
      chinese_name: '工作時間',
      english_name: 'Work Hours',
      simple_chinese_name: '工作时间',
      get_value: -> (rst, options){
        ans = ''
        if rst['has_holiday_records']
          htt = HolidayRecord.holiday_type_table
          attend_states = rst['attend_states']
          attend_states.each do |state|
            true_s = htt.select { |s| s[:key] == state['state'] }.first
            ans = true_s ? "#{true_s[options[:name_key]]}" : ""
          end
        elsif rst['should_show_annual_leave']
          ans = '年假'
        else
          ro = RosterObject.find_by(id: rst['roster_object_id'])
          if ro
            if ro.is_general_holiday == true
              ans = '公休'
            else
              attend_states = rst['attend_states']

              wht_states = attend_states.select do |s|
                s['state'] == 'borrow_hours_as_a' ||
                  s['state'] == 'return_hours_as_a' ||
                  s['state'] == 'borrow_hours_as_b' ||
                  s['state'] == 'return_hours_as_a'
              end

              wht = WorkingHoursTransactionRecord.where(apply_date: rst['attend_date']).where("user_a_id = ? OR user_b_id = ?", rst['user']['id'], rst['user']['id']).first if wht_states.count > 0
              # wht_start_time = ''
              # wht_end_time = ''
              # wht_is_start_next = ''
              # wht_is_end_next = ''
              # wht_start_int = 0
              # wht_end_int = 0

              # if wht_states.count > 0 && wht
              #   wht_start_time = wht.start_time.strftime("%H%M")
              #   wht_end_time = wht.start_time.strftime("%H%M")
              #   wht_is_start_next = wht.is_start_next == true ? '次日 ' : ''
              #   wht_is_end_next = wht.is_end_next == true ? '次日 ' : ''
              #   wht_start_int = wht.is_start_next == true ? (10000 + wht_start_time.to_i) : wht_start_time.to_i
              #   wht_end_int = wht.is_end_next == true ? (10000 + wht_end_time.to_i) : wht_end_time.to_i
              # end

              cs = ClassSetting.find_by(id: ro.class_setting_id)
              if cs
                start_time = cs.start_time ? cs.start_time.strftime("%H%M") : ''
                end_time = cs.end_time ? cs.end_time.strftime("%H%M") : ''
                is_start_next = cs.is_next_of_start ? '次日 ' : ''
                is_end_next = cs.is_next_of_end ? '次日 ' : ''

                if wht_states.count > 0
                  wht_start_time = wht.start_time.strftime("%H%M")
                  wht_end_time = wht.end_time.strftime("%H%M")
                  wht_is_start_next = wht.is_start_next == true ? '次日 ' : ''
                  wht_is_end_next = wht.is_end_next == true ? '次日 ' : ''
                  wht_start_int = wht.is_start_next == true ? (10000 + wht_start_time.to_i) : wht_start_time.to_i
                  wht_end_int = wht.is_end_next == true ? (10000 + wht_end_time.to_i) : wht_end_time.to_i

                  c_start_int = cs.is_next_of_start ? (10000 + start_time.to_i) : start_time.to_i
                  c_end_int = cs.is_next_of_end ? (10000 + end_time.to_i) : end_time.to_i

                  if wht_states.select { |s| s['state'] == 'borrow_hours_as_a' }.count > 0
                    if wht_start_int == c_start_int
                      ans = "#{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                    elsif wht_end_int == c_end_int
                      ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time}"
                    else
                      ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time} #{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                    end
                  elsif wht_states.select { |s| s['state'] == 'return_hours_as_a' }.count > 0
                    ans = "#{is_start_next}#{start_time} - #{is_end_next}#{end_time} #{wht_is_start_next}#{wht_start_time} - #{wht_is_end_next}#{wht_end_time}"
                  elsif wht_states.select { |s| s['state'] == 'borrow_hours_as_b' }.count > 0
                    ans = "#{is_start_next}#{start_time} - #{is_end_next}#{end_time} #{wht_is_start_next}#{wht_start_time} - #{wht_is_end_next}#{wht_end_time}"
                  elsif wht_states.select { |s| s['state'] == 'return_hours_as_b' }.count > 0
                    if wht_start_int == c_start_int
                      ans = "#{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                    elsif wht_end_int == c_end_int
                      ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time}"
                    else
                      ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time} #{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                    end
                  end
                else
                  ans = "#{is_start_next}#{start_time} - #{is_end_next}#{end_time}"
                end

              elsif ro.working_time
                wk_time= ro.working_time
                tmp_start_time = wk_time.split('-').first
                tmp_start_hour = tmp_start_time.split(':').first.to_i
                true_start_hour = (tmp_start_hour % 24).to_s.rjust(2, '0')
                true_start_min = tmp_start_time.split(':').second.to_i.to_s.rjust(2, '0')
                start_time = "#{true_start_hour}#{true_start_min}"
                is_start_next = tmp_start_hour / 24 == 1 ? '次日 ' : ''

                tmp_end_time = wk_time.split('-').last
                tmp_end_hour = tmp_end_time.split(':').first.to_i
                true_end_hour = (tmp_end_hour % 24).to_s.rjust(2, '0')
                true_end_min = tmp_end_time.split(':').second.to_i.to_s.rjust(2, '0')
                end_time = "#{true_end_hour}#{true_end_min}"
                is_end_next = tmp_end_hour / 24 == 1 ? '次日 ' : ''

                if wht_states.count > 0
                  wht_start_time = wht.start_time.strftime("%H%M")
                  wht_end_time = wht.end_time.strftime("%H%M")
                  wht_is_start_next = wht.is_start_next == true ? '次日 ' : ''
                  wht_is_end_next = wht.is_end_next == true ? '次日 ' : ''
                  wht_start_int = wht.is_start_next == true ? (10000 + wht_start_time.to_i) : wht_start_time.to_i
                  wht_end_int = wht.is_end_next == true ? (10000 + wht_end_time.to_i) : wht_end_time.to_i

                  c_start_int = tmp_start_hour / 24 == 1 ? (10000 + start_time.to_i) : start_time.to_i
                  c_end_int = tmp_end_hour / 24 == 1 ? (10000 + end_time.to_i) : end_time.to_i

                  if wht_states.select { |s| s['state'] == 'borrow_hours_as_a' }.count > 0
                    if wht_start_int == c_start_int
                      ans = "#{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                    elsif wht_end_int == c_end_int
                      ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time}"
                    else
                      ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time} #{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                    end
                  elsif wht_states.select { |s| s['state'] == 'return_hours_as_a' }.count > 0
                    ans = "#{is_start_next}#{start_time} - #{is_end_next}#{end_time} #{wht_is_start_next}#{wht_start_time} - #{wht_is_end_next}#{wht_end_time}"
                  elsif wht_states.select { |s| s['state'] == 'borrow_hours_as_b' }.count > 0
                    ans = "#{is_start_next}#{start_time} - #{is_end_next}#{end_time} #{wht_is_start_next}#{wht_start_time} - #{wht_is_end_next}#{wht_end_time}"
                  elsif wht_states.select { |s| s['state'] == 'return_hours_as_b' }.count > 0
                    if wht_start_int == c_start_int
                      ans = "#{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                    elsif wht_end_int == c_end_int
                      ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time}"
                    else
                      ans = "#{is_start_next}#{start_time} - #{wht_is_start_next}#{wht_start_time} #{wht_is_end_next}#{wht_end_time} - #{is_end_next}#{end_time}"
                    end
                  end
                else
                  ans = "#{is_start_next}#{start_time} - #{is_end_next}#{end_time}"
                end
              end
            end
          end
        end
        ans
      }
    }

    on_work_time = {
      chinese_name: '上班打卡',
      english_name: 'Punch On',
      simple_chinese_name: '上班打卡',
      get_value: -> (rst, options){
        ans = ''
        if rst['has_on_signcard']
          time = rst['signcard_on_work_time']
          is_next = rst['signcard_on_work_time_is_next'] ? '次日' : ''
          ans = "#{is_next} #{time}"
        else
          ans = rst['on_work_time'] ? Time.zone.parse(rst["on_work_time"]).strftime("%H:%M") : ''
        end
        ans
      }
    }

    off_work_time = {
      chinese_name: '下班打卡',
      english_name: 'Punch Off',
      simple_chinese_name: '下班打卡',
      get_value: -> (rst, options){
        ans = ''
        if rst['has_off_signcard']
          time = rst['signcard_off_work_time']
          is_next = rst['signcard_off_work_time_is_next'] ? '次日' : ''
          ans = "#{is_next} #{time}"
        else
          ans = rst['off_work_time'] ? Time.zone.parse(rst["off_work_time"]).strftime("%H:%M") : ''
        end
        ans
      }
    }

    attend_states = {
      chinese_name: '出勤狀態',
      english_name: 'Attend States',
      simple_chinese_name: '出勤状态',
      get_value: -> (rst, options){
        ans = ""
        state_table = AttendState.state_table
        attend_states = rst['attend_states']
        has_punching_card_on_holiday_state = attend_states.select { |s| s["auto_state"] == 'punching_card_on_holiday_exception' }.count > 0
        attend_states = has_punching_card_on_holiday_state || rst['has_holiday_records'] || rst['has_on_signcard'] ? attend_states.select { |s| s["auto_state"] != 'late' && s["auto_state"] != 'on_work_punching_exception' } : attend_states
        attend_states = has_punching_card_on_holiday_state || rst['has_holiday_records'] || rst['has_off_signcard'] ? attend_states.select { |s| s["auto_state"] != 'leave_early_by_auto' && s["auto_state"] != 'off_work_punching_exception' } : attend_states
        attend_states.each do |state|
          true_s = state_table.select { |s| s[:key] == state['state'] || s[:key] == state['auto_state'] || s[:key] == state['sign_card_state'] }.first
          if true_s[:key] == 'overtime'
            ans += ", #{true_s[options[:name_key]]} (#{state['remark']})"
          else
            ans += ", #{true_s[options[:name_key]]}"
          end
        end
        ans == "" ? ans : ans.split(", ")[1 .. -1].join(", ")
      }
    }


    table_fields = [empoid, name, location, department, position, attend_date, attend_weekday,
                    work_hours, on_work_time, off_work_time, attend_states]


  end

  def export_title
    if select_language.to_s == 'chinese_name'
      '考勤表'
    elsif select_language.to_s == 'english_name'
      'Attend Table'
    else
      '考勤表'
    end
  end

  def self.dict_of_weekday(d)
    case d
    when 0
      ans = "日"
    when 1
      ans = "一"
    when 2
      ans = "二"
    when 3
      ans = "三"
    when 4
      ans = "四"
    when 5
      ans = "五"
    when 6
      ans = "六"
    else
      ans = ""
    end
    ans
  end
end
