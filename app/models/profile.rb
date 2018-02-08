# coding: utf-8
# == Schema Information
#
# Table name: profiles
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  region                      :string
#  data                        :jsonb
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  filled_attachment_types     :jsonb
#  attachment_missing_sms_sent :boolean          default(FALSE)
#  is_stashed                  :boolean          default(FALSE)
#  current_welfare_template_id :integer
#  current_template_type       :integer
#  welfare_template_effected   :boolean
#
# Indexes
#
#  index_profiles_on_region   (region)
#  index_profiles_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_e424190865  (user_id => users.id)
#

# User Profile Model
class Profile < ApplicationRecord
  include ProfileAble

  belongs_to :user
  has_many :profile_attachments
  has_many :contract_informations
  has_many :work_experences
  has_many :education_informations
  has_many :family_declaration_items
  has_many :professional_qualifications
  has_one :medical_insurance_participator

  has_one :provident_fund
  has_one :love_fund
  #assistant_profile记录有薪病假奖励假的发放情况
  has_many :assistant_profile
  #assistant_profile_to_annual_work_award 记录全年勤工奖发放情况
  has_many :assistant_profile_to_annual_work_award
  before_save :on_save
  after_initialize :fill_sections
  after_create :update_filled_attachment_types

  scope :of_region, ->(region_key) { where(region: region_key) }
  scope :not_stashed, -> { where(is_stashed: false) }
  scope :stashed, -> { where(is_stashed: true) }
  enum current_template_type: {none_template: 0, has_template: 1}

  scope :by_up_to_blue_card, lambda {
    where("data -> 'personal_information' -> 'field_values' -> 'type_of_id' ?| array['hong_kong_identity_card', 'valid_exit_entry_permit_eep_to_hk_macau', 'passport']")
  }

  scope :by_date_of_employment, lambda { |from, to|
    if from && to
      where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
        .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    elsif from
      where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
    elsif to
      where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    end
  }


  scope :by_resigned_date, lambda { |from, to|
    if from && to
      where("profiles.data #>> '{position_information, field_values, resigned_date}' >= :from", from: from)
        .where("profiles.data #>> '{position_information, field_values, resigned_date}' <= :to", to: to)
    elsif from
      where("profiles.data #>> '{position_information, field_values, resigned_date}' >= :from", from: from)
    elsif to
      where("profiles.data #>> '{position_information, field_values, resigned_date}' <= :to", to: to)
    end
  }


  scope :by_on_duty, lambda{|from, to|
    if from && to
      where("(profiles.data #>> '{position_information, field_values, resigned_date}' is NULL AND profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to)
              OR (profiles.data #>> '{position_information, field_values, resigned_date}' >= :from)", from: from, to: to)
    elsif from
      where("profiles.data #>> '{position_information, field_values, resigned_date}' is NULL AND profiles.data #>> '{position_information, field_values, resigned_date}' >= :from", from: from)
    elsif to
      where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    end
  }

  scope :by_working_status, lambda{|working_status, from, to|
    status_start_date = Time.zone.parse(from).strftime('%Y/%m/%d') rescue nil
    status_end_date = Time.zone.parse(to).strftime('%Y/%m/%d') rescue nil
    if working_status == 'entry'
      self.by_date_of_employment(status_start_date, status_end_date)
    elsif working_status == 'in_service'
      self.by_on_duty(status_start_date, status_end_date)
    else working_status == 'leave'
      self.by_resigned_date(status_start_date, status_end_date)
    end
  }



  def sections_with_resignation_info
    sections.map do |item|
      if item.key == 'position_information' && (self.is_a? Profile)
        result = item.as_json
        result['field_values'] = result['field_values'].merge(self.resignation_record_for_profile)
        result['fields'] = result['fields'].map! do |field|
          if (ProfileService.respond_to? field['key'])
            if %w(location group department position).include? field['key']
              field['value'] = ProfileService.send(field['key'],self.user)&.id
            elsif field['type'] =='date'
              field['value'] = ProfileService.send(field['key'],self.user)&.strftime("%Y/%m/%d")
            else
              field['value'] = ProfileService.send(field['key'],self.user)
            end
            field
          else
            field
          end
        end
        result
      else
        item
      end
    end
  end

  def resignation_record_for_profile
    {
      'resigned_date' => ProfileService.resigned_date(self.user)&.strftime('%Y/%m/%d'),
      'final_work_date'=> ProfileService.final_work_date(self.user)&.strftime('%Y/%m/%d'),
      'notice_date'=> ProfileService.notice_date(self.user)&.strftime('%Y/%m/%d'),
      'compensation_year'=> ProfileService.compensation_year(self.user),
      'notice_period_compensation'=> ProfileService.notice_period_compensation(self.user),
      'is_in_whitelist'=> ProfileService.is_in_whitelist(self.user),
      'resigned_reason'=> ProfileService.resigned_reason(self.user),
      'reason_for_resignation'=> ProfileService.reason_for_resignation(self.user),
    }
  end



  def update_information
    self.fill_sections
    self.save
  end

  def publish(event_name, params)
    self.user.call(event_name, params)
  end

  def update_filled_attachment_types
    attachment_types = attachment_types_with_attachments.map(&:id).sort
    self.filled_attachment_types = attachment_types
    self.save
  end

  def attachment_types_with_attachments
    ProfileAttachmentType.includes(:profile_attachments).where(:profile_attachments => {:profile_id => self})
  end

  def attachment_result(attachment_type_ids, lang='chinese_name')
    attachment_type_ids.reduce({}) do |type_result, type_id|
      if 'chinese_name' == lang
        result = filled_attachment_types.include?(type_id.to_i) ? '已提交' : '未提交'
      else
        result = filled_attachment_types.include?(type_id.to_i) ? 'Filled' : 'Not Filled'
      end
      type_result[type_id] = result
      type_result
    end
  end

  def self.with_blank_attachments
    where.not('filled_attachment_types @> ?', ProfileAttachmentType.all.pluck(:id).sort.to_json)
  end

  def self.update_all_filled_attachment_types
    self.with_blank_attachments.each do |p|
      p.update_filled_attachment_types
    end
  end

  # 是否是本地员工
  def is_local_employee?
    !ProfileService.whether_foreign_employee(self.user)
  end

  #判断是否为正式职工
  def is_permanent_staff?
    Config.get(:constants_collection)['FormalEmployeeType'].include? self.data['position_information']['field_values']['employment_status']
  end

  # 判断是否是兼职
  def is_part_time_staff?
    Config.get(:constants_collection)['PartTimeEmployeeType'].include? self.data['position_information']['field_values']['employment_status']
  end

  def shift_state
    user = User.find(self['user_id'])
    if (shift_state = ShiftState.where(user_id: user['id']).first) != nil
      shift_state
    else
      ShiftState.create(user_id: user.id)
    end
  end

  def shift_status
    user = User.find(self['user_id'])
    if (shift_status = ShiftStatus.where(user_id: user['id']).first) != nil
      shift_status
    else
      ShiftStatus.create_default_one(user['id'])
    end
  end

  def punch_card_state
    user = User.find_by(id: self['user_id'])
    if (punch_card_state = PunchCardState.where(user_id: user.id, source_id: nil).order(created_at: :desc).last) != nil
      # notice for current_state: 正常 current_state 不需要条件判定, 之所以需要后面的分支, 是补充一开始第一次创建档案时, 忘了创建第一次 punch_card_state 的第一次历史
      # （现在代码都会自动创建, 之前一开始有的没创建导致第一次创建 punch_card_state 后没有历史）
      {
        test: true,
        state_id: punch_card_state.id,
        future_state: punch_card_state.is_effective == true ? nil : punch_card_state,
        current_state: punch_card_state.histories.count != 0 ? punch_card_state.histories.order(created_at: :desc).first : punch_card_state.histories.create(punch_card_state.attributes.merge({ id: nil, created_at: nil, updated_at: nil }))
      }
    else
      default_one = PunchCardState.create_default_one(user.id)
      {
        test: false,
        state_id: default_one.id,
        future_state: nil,
        current_state: default_one.histories.order(created_at: :desc).first
      }
    end
  end

  def roster_model_state
    user = User.find_by(id: self['user_id'])
    if (roster_model_state = RosterModelState.where(user_id: user['id'], source_id: nil).order(created_at: :desc).last) != nil
      # notice for current_state: 正常 current_state 不需要条件判定, 之所以需要后面的分支, 是补充一开始第一次创建档案时, 忘了创建第一次 roster_model_state 的第一次历史
      # （现在代码都会自动创建, 之前一开始有的没创建导致第一次创建 roster_model_state 后没有历史）
      f_state = roster_model_state.is_effective == true ? nil : roster_model_state
      # c_state = roster_model_state.histories.count != 0 ? roster_model_state.histories.order(created_at: :desc).first : roster_model_state.histories.create(roster_model_state.attributes.merge({ id: nil }))
      c_state = roster_model_state.histories.count != 0 ? roster_model_state.histories.order(created_at: :desc).first : nil
      {
        state_id: roster_model_state.id,
        user_state: roster_model_state,
        future_state: f_state == nil ? nil : f_state.as_json(include: [ :roster_model ]),
        current_state: c_state == nil ? nil : c_state.as_json(include: [ :roster_model ]),
      }
    else
      {
        state_id: nil,
        future_state: nil,
        current_state: nil,
      }
    end
  end

  def roster_info
    user = User.find(self['user_id'])
    day = Time.zone.now.to_date.to_s
    user_rosters = RosterItem.where(user_id: user['id'])
    rosters = format_for_week(user_rosters.by_week(day))
    is_first = user_rosters.where("date < ?", Time.zone.now.beginning_of_week.to_date).length == 0
    is_last = user_rosters.where("date > ?", Time.zone.now.end_of_week.to_date).length == 0
    {
        rosters: rosters,
        shifts: Shift.where(roster_id: user_rosters.pluck('roster_id')),
        is_first: is_first,
        is_last: is_last
    }
  end

  def roster_object_info
    user = User.find_by(id: self['user_id'])
    day = Time.zone.now.to_date.to_s

    public_and_sealed_list_ids = RosterList.where("status = ? OR status = ?", 1, 2).pluck(:id).uniq
    user_roster_objects = RosterObject.where(user_id: user['id'], roster_list_id: public_and_sealed_list_ids)
    roster_objects = format_objects_for_week(user_roster_objects.by_week(day))

    {
      roster_objects: roster_objects,
      class_settings: ClassSetting.where(id: user_roster_objects.pluck('class_setting_id').compact.uniq),
    }
  end


  def roster_instruction
    self.user.roster_instruction
  end

  def language_skill
    self.user.language_skill
  end
  def family_member_information
    self.user.family_member_information
  end
  def profit_conflict_information
    self.user.profit_conflict_information
  end
  def background_declaration
    self.user.background_declaration
  end



  def get_days_in_office(begin_date)
    date_of_employment = self.data['position_information']['field_values']['date_of_employment']
    return 0 if date_of_employment.nil? || date_of_employment.to_s.empty? || !(date_validate? date_of_employment)
    year, month, day = date_of_employment.split('/')
    date_of_employment = Time.zone.local(year, month, day).midnight
    year, month, day = begin_date.split('/')
    begin_date = Time.zone.local(year, month, day).midnight
    end_date = get_end_date_time(year, month, day)
    if date_of_employment< begin_date
      365
    elsif date_of_employment >= begin_date && date_of_employment < end_date
      ((date_of_employment-begin_date)/(3600*24)).round+1
    elsif date_of_employment >= end_date
      0
    end
  end

  def is_up_to_standard?(begin_date)
    year, month, day = begin_date.split('/')
    begin_date = Time.zone.local(year, month, day).midnight
    end_date = get_end_date_time(year, month, day)
    # holiday_type 为影响全年勤工奖的的类型
    result = Profile.joins(user: {holidays: :holiday_items}).where(holiday_items: {
        holiday_type: [4, 5, 6, 7, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18]}, id: self.id).where(
        "start_time >= :begin_date  AND end_time < :end_date", {begin_date: begin_date,
                                                                end_date: end_date})
    if result.count >0
      holiday_requirement = false
    else
      holiday_requirement = true
    end
    attendance_requirement= true
    items = AttendanceItem.where(user_id: self.user_id, attendance_date: begin_date...end_date)
    items.each do |item|
      a, b, c, d, e, f, g = '上班打卡異常', '下班打卡異常', '遲到', '早退', '曠工', '即告', '借鍾'
      if /(#{a}|#{b}|#{c}|#{d}|#{e}|#{f}|#{g})/.match(item.states)
        attendance_requirement = false
      end
    end
    others = true
    resigned_date = self.data['position_information']['field_values']['resigned_date']

    if resigned_date && !resigned_date.to_s.empty? && (date_validate? resigned_date)
      year, month, day = resigned_date.split('/')
      resigned_date = Time.zone.local(year, month, day).midnight
      others = false if resigned_date < end_date
    end
    if holiday_requirement && attendance_requirement && others
      1
    else
      0
    end
  end

  def get_money_of_award(begin_date, num_of_award)
    days_in_office = self.get_days_in_office(begin_date)
    year, month, day = begin_date.split('/')
    begin_date = Time.zone.local(year, month, day).midnight
    end_date = get_end_date_time(year, month, day)
    days_for_work_injury = Profile.joins(
        user: {holidays: :holiday_items}
    ).where(
        holiday_items: {holiday_type: [13]}, id: self.id
    ).where(
        "start_time >= :begin_date  AND end_time < :end_date",
        {begin_date: begin_date, end_date: end_date}
    ).sum("duration"
    )
    days_for_work_injury = days_for_work_injury-30 >0 ? days_for_work_injury-30 >0 : 0
    final_days = days_in_office - days_for_work_injury >0 ? days_in_office- days_for_work_injury : 0
    (final_days.to_f/365*num_of_award).round(2)
  end

  def get_has_used_days(begin_date)
    year, month, day = begin_date.split('/')
    begin_date = Time.zone.local(year, month, day).midnight
    end_date = get_end_date_time(year, month, day)
    Profile.joins(
        user: {holidays: :holiday_items}
    ).where(
        holiday_items: {holiday_type: [Config.get(:constants_collection)['PaidIllnessLeaveType']]}, id: self.id
    ).where(
        "start_time >= :begin_date  AND end_time < :end_date",
        {begin_date: begin_date, end_date: end_date}
    ).sum("duration"
    )
  end


  # 根据该档案 获取 当期生效的有薪病假奖励假的总天数
  def get_offered_reward_leave_days
    now_time = Time.zone.now.to_s.split[0].split('-').join('/')
    self.assistant_profile.joins(
        :paid_sick_leave_award
    ).where(
        "has_offered = 1 AND due_date>:now_time", now_time: now_time
    ).sum(
        "days_of_award"
    )
  end

  #根据该档案 获取 生效的有薪病假奖励假 最早发放的时间
  def get_offer_date
    now_time = Time.zone.now.to_s.split[0].split('-').join('/')
    self.assistant_profile.joins(
        :paid_sick_leave_award
    ).where(
        "has_offered = 1 AND due_date>:now_time", now_time: now_time
    ).order(
        'begin_date ASC'
    ).limit(1).select(
        'paid_sick_leave_awards.updated_at'
    )
  end

  #计算该员工在正在生效的奖励假中,使用了多少假期
  #offer_range 为 发放日期至当前日期
  def get_used_reward_leave_days (offer_range)
    User.joins(
        {holidays: [:holiday_items]}).select("sum(holiday_items.duration) as sum1"
    ).where(
        id: self.user_id, holidays: {holiday_items: {holiday_type: Config.get(:constants_collection)['BonusHolidayType'], start_time: offer_range}}
    ).group(
        "users.id"
    ).first.try(:sum1).to_i
  end

  def total_annual_leave_days_has_got(to_date)
    date_of_employment = self.data['position_information']['field_values']['date_of_employment']
    annual_leave_standard = self.data['holiday_information']['field_values']['annual_leave'].to_i
    division_of_job = self.data['position_information']['field_values']['division_of_job']
    front_office_name = Config.get(:selects)['division_of_job']['options'].select { |hash| hash['key'] == 'front_office' }[0].fetch_values('chinese_name', 'english_name')
    back_office_name = Config.get(:selects)['division_of_job']['options'].select { |hash| hash['key'] == 'back_office' }[0].fetch_values('chinese_name', 'english_name')
    if ((front_office_name.include? division_of_job) && has_worked_for_a_year?) || (back_office_name.include? division_of_job && is_permanent_staff?)
      get_total_annual_leave_before(has_worked_time_in_year(date_of_employment, to_date), annual_leave_standard) + get_annual_leave_this_year(has_worked_time_in_year(date_of_employment, to_date), annual_leave_standard, date_of_employment, to_date)
    else
      0
    end
  end

  def total_annual_leave_has_used
    User.joins(
        {holidays: [:holiday_items]}
    ).select(
        "sum(holiday_items.duration) as sum1"
    ).where(
        id: self.user_id, holidays: {holiday_items: {holiday_type: Config.get(:constants_collection)['AnnualLeaveType']}}
    ).group(
        "users.id"
    ).first.try(:sum1).to_i
  end

  def has_worked_for_a_year?
    date_of_employment = self.data['position_information']['field_values']['date_of_employment']
    year, month, day = date_of_employment.split('/')
    date_of_employment_time = Time.zone.local(year, month, day)
    Time.zone.now > date_of_employment_time + 1.year
  end

  def respond_to?(method_id, include_private = false)
    return true unless method_fetch_rows_section(method_id.to_s).nil?
    return true unless method_add_row_section(method_id.to_s).nil?
    super
  end

  def method_missing(method_id, *args, &block)
    # 捕獲 fetch_xxx_section_rows 方法
    unless (section = method_fetch_rows_section(method_id.to_s)).nil?
      return section.as_json['rows']
    end

    # 捕獲 add_xxx_section_row 方法
    unless (section = method_add_row_section(method_id.to_s)).nil?
      return add_section_row(section, args.first)
    end

    super
  end

  def head_title
    resignation_record = self.user.resignation_records.order(created_at: :desc).first
    department = Department.find(self.data['position_information']['field_values']['department']) rescue nil
    position = Position.find(self.data['position_information']['field_values']['position']) rescue nil
    location = Location.find(self.data['position_information']['field_values']['location']) rescue nil
    {
      photo: self.data['personal_information']['field_values']['photo'],
      chinese_name: self.data['personal_information']['field_values']['chinese_name'],
      english_name: self.data['personal_information']['field_values']['english_name'],
      nick_name: self.data['personal_information']['field_values']['nick_name'],
      empoid: self.data['position_information']['field_values']['empoid'],
      mobile_number: self.data['personal_information']['field_values']['mobile_number'],
      department: department,
      position: position,
      location: location,
      date_of_employment: self.data['position_information']['field_values']['date_of_employment'],
      position_resigned_date: self.data['position_information']['field_values']['resigned_date'],
      employment_status: self.data['position_information']['field_values']['employment_status'],
      resignation_record: resignation_record.nil? ? {} : {status: resignation_record.status, time_arrive: resignation_record.time_arrive} ,
      salary_templates:  SalaryTemplate.where("belongs_to -> '#{self.data['position_information']['field_values']['department']}' ?| array['#{self.data['position_information']['field_values']['position']}'] "),
      welfare_templates: WelfareTemplate.where("belongs_to -> '#{self.data['position_information']['field_values']['department']}' ?| array['#{self.data['position_information']['field_values']['position']}'] "),
      is_suspension_investigation: self.user.career_records.by_current_valid_record_for_career_info&.first&.deployment_type == 'suspension_investigation',
      options: {
        division_of_job: Config.get_all_option_from_selects('employment_status')
      }
    }
  end


  private

  # 解析 fetch_xxx_section_rows 的section對象
  def method_fetch_rows_section(method_name)
    return nil unless method_name =~ /fetch_(\w+)_section_rows/
    section = self.sections.find($1)
    section&.is_table? ? section : nil
  end

  # 解析 add_xxx_section_row 的section對象
  def method_add_row_section(method_name)
    return nil unless method_name =~ /add_(\w+)_section_row/
    section = self.sections.find($1)
    section&.is_table? ? section : nil
  end

  # 爲 section 添加row數據
  def add_section_row(section, row_data_hash)
    row_data = row_data_hash
                 .with_indifferent_access
                 .slice *section.schema_keys
    params = { section_key: section.key, new_row: row_data }
    self.sections.add_row(params.with_indifferent_access)
    self.save
  end




  def has_worked_time_in_year(date_of_employment, to_date = nil)
    year, month, day = date_of_employment.split('/')
    date_of_employment = Time.zone.local(year, month, day)
    if to_date
      year, month, day = to_date.split('/')
      to_date = Time.zone.local(year, month, day)
    else
      to_date = Time.zone.now.midnight
    end
    result = ((to_date - date_of_employment)/Config.get(:constants_collection)['OneYear']).floor
    result >= 1 ? result : 0
  end

  def get_total_annual_leave_before(had_worked_time_in_years, annual_leave_standard)
    final_result = 0
    had_worked_time_in_years.times do |i|
      case annual_leave_standard
        when 7
          if (annual_leave_standard + i) < 12
            final_result += annual_leave_standard + i
          else
            final_result += 12
          end
        when 12
          final_result += 12
        when 15
          final_result += 15
        else
          final_result = 0
      end
    end
    final_result
  end

  def get_annual_leave_this_year(had_worked_time_in_years, annual_leave_standard, date_of_employment, to_date)
    final_result = 0
    case annual_leave_standard
      when 7
        if (annual_leave_standard + had_worked_time_in_years) < 12
          final_result = calculate_working_days_in_this_year_for_annual_leave(had_worked_time_in_years, had_worked_time_in_years + annual_leave_standard, date_of_employment, to_date)
        else
          final_result = calculate_working_days_in_this_year_for_annual_leave(had_worked_time_in_years, 12, date_of_employment, to_date)
        end
      when 12
        final_result = calculate_working_days_in_this_year_for_annual_leave(had_worked_time_in_years, 12, date_of_employment, to_date)
      when 15
        final_result = calculate_working_days_in_this_year_for_annual_leave(had_worked_time_in_years, 15, date_of_employment, to_date)
      else
        final_result = 0
    end
    final_result
  end

  def calculate_working_days_in_this_year_for_annual_leave(had_worked_time_in_years, now_annual_leave_standard, date_of_employment, to_date)
    year, month, day = date_of_employment.split('/')
    date_of_employment = Time.zone.local(year, month, day)
    if to_date
      year, month, day = to_date.split('/')
      to_date = Time.zone.local(year, month, day)
    else
      to_date = Time.zone.now.midnight
    end
    (((to_date - (date_of_employment + had_worked_time_in_years.year))/Config.get(:constants_collection)['OneDay']/365)*now_annual_leave_standard).floor
  end

  def update_time_has_arrived? (effective_date)
    year, month, day = effective_date.split('/')
    (Time.zone.local(year, month, day) + 6.hour <=> Time.zone.now.midnight) <= 0
  end

  def get_end_date_time(year, month, day)
    if day == '29' && month == '02'
      (Time.zone.local(year, month, day) + 1.year + 1.day).midnight
    else
      (Time.zone.local(year, month, day) + 1.year).midnight
    end
  end

  def format_for_week(rosters)
    if rosters.length == 7
      rosters
    # elsif rosters.length == 0
    #   []
    else
      # day = rosters[0]['date']
      day = rosters.length == 0 ? Time.zone.now.to_datetime : rosters[0]['date']
      duration = [*day.beginning_of_week.to_date .. day.end_of_week.to_date]
      duration.map do |date|
        roster = rosters.find { |r| r['date'] == date }
        roster != nil ? roster : {date: date, shift_id: nil}
      end
    end
  end

  def format_objects_for_week(roster_objects)
    if roster_objects.length == 7
      roster_objects
    # elsif rosters.length == 0
    #   []
    else
      # day = rosters[0]['date']
      date = roster_objects.length == 0 ? Time.zone.now.to_date : roster_objects[0]['roster_date']
      duration = [*date.beginning_of_week.to_date .. date.end_of_week.to_date]
      duration.map do |d|
        roster_object = roster_objects.find { |r| r['roster_date'] == d }
        roster_object != nil ? roster_object : {roster_date: d, class_setting_id: nil, is_general_holiday: nil}
      end
    end
  end

  def time_to_date_string
    self.to_date.to_s
  end

  def date_validate?(date)
    if date =~ /(([0-9]{3}[1-9]|[0-9]{2}[1-9][0-9]{1}|[0-9]{1}[1-9][0-9]{2}|[1-9][0-9]{3})\/(((0[13578]|1[02])\/(0[1-9]|[12][0-9]|3[01]))|((0[469]|11)\/(0[1-9]|[12][0-9]|30))|(02\/(0[1-9]|[1][0-9]|2[0-8]))))|((([0-9]{2})(0[48]|[2468][048]|[13579][26])|((0[48]|[2468][048]|[3579][26])00))\/02\/29)/
      true
    else
      false
    end
  end
end
