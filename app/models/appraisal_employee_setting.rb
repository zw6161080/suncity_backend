# == Schema Information
#
# Table name: appraisal_employee_settings
#
#  id                              :integer          not null, primary key
#  user_id                         :integer
#  appraisal_group_id              :integer
#  appraisal_department_setting_id :integer
#  level_in_department             :integer
#  has_finished                    :boolean
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
# Indexes
#
#  employee_on_department_setting                           (appraisal_department_setting_id)
#  index_appraisal_employee_settings_on_appraisal_group_id  (appraisal_group_id)
#  index_appraisal_employee_settings_on_user_id             (user_id)
#
# Foreign Keys
#
#  fk_rails_07f7e35534  (appraisal_group_id => appraisal_groups.id)
#  fk_rails_71af4268f0  (user_id => users.id)
#

class AppraisalEmployeeSetting < ApplicationRecord
  include StatementAble

  belongs_to :user
  belongs_to :appraisal_department_setting
  has_one :appraisal_group
  has_one :appraisal_participator

  def get_appraisal_record_details
    report_details = {}
    completed_ids = Appraisal.where(appraisal_status: %w(completed performance_interview)).collect(&:id)
    AppraisalParticipator.where(user_id: self.user.id).where(appraisal_id: completed_ids).each do |participator|
      report_details["appraisal_#{participator.appraisal_id}"] = participator.appraisal_report.as_json
      report_details["appraisal_#{participator.appraisal_id}"]["appraisal_participator_#{participator.id}"] =  ActiveModelSerializers::SerializableResource.new(participator)
    end
    report_details
  end

  def reset_candidate_relationship
    AppraisalParticipator
      .joins(:appraisal)
      .joins(:user)
      .where(:appraisals => {appraisal_status: ['unpublished', 'to_be_assessed']})
      .where(:users => { location_id: self.user.location_id})
      .where(:users => { department_id: self.user.department_id})
      .each { |participator| participator.create_candidate_participators }
  end

  def self.field_options
    user_query = self.left_outer_joins(user: [:location, :position, :department])
    locations = user_query.select('locations.*').distinct.as_json
    departments = user_query.select('departments.*').distinct.as_json
    positions = user_query.select('positions.*').distinct.as_json
    has_finished = [
      { key: 'true', chinese_name: '已完成', simple_chinese_name: '已完成', english_name: 'Completed'},
      { key: 'false', chinese_name: '未完成', simple_chinese_name: '未完成', english_name: 'Not Completed'}
    ]
    working_status = [
      { key: 'on_duty', chinese_name: '在職', english_name: 'on_duty', simple_chinese_name: '在职' },
      { key: 'leave', chinese_name: '離職', english_name: 'Turnover', simple_chinese_name: '离职' }
    ]
    division_of_job = [
      { key: 'front_office', chinese_name: '前線', english_name: 'Front Office', simple_chinese_name: '前线' },
      { key: 'back_office', chinese_name: '後勤', english_name: 'Back Office', simple_chinese_name: '后勤' }
    ]
    grades = [
      { key: '1', chinese_name: '1', english_name: '1', simple_chinese_name: '1' },
      { key: '2', chinese_name: '2', english_name: '2', simple_chinese_name: '2' },
      { key: '3', chinese_name: '3', english_name: '3', simple_chinese_name: '3' },
      { key: '4', chinese_name: '4', english_name: '4', simple_chinese_name: '4' },
      { key: '5', chinese_name: '5', english_name: '5', simple_chinese_name: '5' },
    ]
    return {
      grade: grades,
      division_of_job: division_of_job,
      working_status: working_status,
      has_finished: has_finished,
      location: locations,
      position: positions,
      department: departments
    }
  end

  def self.generate
    ActiveRecord::Base.transaction do
      User.where("grade <= ?", 5).each do |user|
        if user.location_id && user.department_id
          appraisal_department_setting = AppraisalDepartmentSetting.find_by(
            location_id: user.location_id,
            department_id: user.department_id)
          if appraisal_department_setting
            self.find_or_create_by(user_id: user.id) do |setting|
              setting.appraisal_department_setting_id = appraisal_department_setting.id
              setting.has_finished = false
              setting.save!
            end
          end
        end
      end
    end
  end

  def update_status
    if self.appraisal_department_setting.whether_group_inside
      self.update(has_finished: self.appraisal_group_id? && self.level_in_department?)
    else
      self.update(has_finished: self.level_in_department?)
    end
  end

  def clear_level_in_department
    self.update(level_in_department: nil, has_finished: false)
  end

  def clear_appraisal_group
    self.update(appraisal_group_id: nil, has_finished: false)
  end


  def self.whether_setting_has_finished(params)
    not_finished = AppraisalEmployeeSetting.all.joins(:user => :profile)
                     .by_location(params[:location])
                     .by_department(params[:department])
                     .by_position(params[:position])
                     .by_grade(params[:grade])
                     .by_division_of_job(params[:division_of_job])
                     .by_date_of_employment(params[:date_of_employment])
                     .where(has_finished: false)
    return not_finished.size == 0
  end

  scope :by_has_finished, -> (has_finished) {
    where(has_finished: has_finished) if has_finished
  }

  scope :by_level_in_department, -> (level_in_department) {
    where(level_in_department: level_in_department) if level_in_department
  }

  scope :by_user, -> (name) {
    where(:users => {id: User.where('chinese_name = :name OR english_name = :name OR simple_chinese_name = :name', name: name).select(:id)}) if name
  }

  scope :by_name, -> (name) {
    where(:users => {id: User.where('chinese_name = :name OR english_name = :name OR simple_chinese_name = :name', name: name).select(:id)}) if name
  }

  scope :by_location, -> (location_ids) {
    where(:users => {location_id: location_ids}) if location_ids
  }

  scope :by_department, -> (department_ids) {
    where(:users =>  {department_id: department_ids}) if department_ids
  }

  scope :by_position, -> (position_ids) {
    where(:users =>  {position_id: position_ids}) if position_ids
  }

  scope :by_grade, -> (grade) {
    where(:users =>  {grade: grade}) if grade
  }

  scope :by_division_of_job, -> (division_of_job) {
    if division_of_job && (division_of_job.is_a? Array )
      includes(user: :profile).where("profiles.data -> 'position_information' -> 'field_values' -> 'division_of_job' ?| array["+ division_of_job.map{|item| "'#{item}'"}.join(',') +"]" )
    elsif division_of_job
      includes(user: :profile).where("profiles.data #>> '{position_information,field_values, division_of_job}' = :division_of_job", division_of_job: division_of_job)
    end
  }

  scope :by_position_resigned_date, -> (position_resigned_date) {
    from = Time.zone.parse(position_resigned_date[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(position_resigned_date[:end]).end_of_day rescue nil
    if from && to
      includes(user: :profile)
      .where("profiles.data #>> '{position_information, field_values, resigned_date}' >= :from", from: from)
          .where("profiles.data #>> '{position_information, field_values, resigned_date}' <= :to", to: to)
    elsif from
      includes(user: :profile)
      .where("profiles.data #>> '{position_information, field_values, resigned_date}' >= :from", from: from)
    elsif to
      includes(user: :profile)
      .where("profiles.data #>> '{position_information, field_values, resigned_date}' <= :to", to: to)
    end
  }


  scope :by_on_duty, -> (on_duty) {
    from = Time.zone.parse(on_duty[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(on_duty[:end]).end_of_day rescue nil
    if from && to
      includes(user: :profile)
      .where("(profiles.data #>> '{position_information, field_values, resigned_date}' is NULL AND profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to)
              AND (profiles.data #>> '{position_information, field_values, resigned_date}' >= :from)", from: from, to: to)
    elsif from
      includes(user: :profile)
      .where("profiles.data #>> '{position_information, field_values, resigned_date}' is NULL AND profiles.data #>> '{position_information, field_values, resigned_date}' >= :from", from: from)
    elsif to
      includes(user: :profile)
      .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    end
  }

  scope :by_working_status, -> (working_status) {
    status_start_date = Time.zone.parse(working_status[:begin]).strftime('%Y/%m/%d') rescue nil
    status_end_date = Time.zone.parse(working_status[:end]).strftime('%Y/%m/%d') rescue nil
    if working_status == 'on_duty'
      self.by_on_duty(status_start_date, status_end_date)
    elsif working_status == 'leave'
      self.by_position_resigned_date(status_start_date, status_end_date)
    end
  }

  scope :order_by, -> (sort_column, sort_direction) {
    case sort_column.to_sym
      when :empoid                then order("users.empoid #{sort_direction}")
      when :id                    then order("users.empoid #{sort_direction}")
      when :user                  then order("users.chinese_name #{sort_direction}")
      when :name                  then order("users.chinese_name #{sort_direction}")
      when :location              then order("users.location_id #{sort_direction}")
      when :department            then order("users.department_id #{sort_direction}")
      when :position              then order("users.position_id #{sort_direction}")
      when :grade                 then order("users.grade #{sort_direction}")
      when :division_of_job       then
        if sort_direction == :desc
          order("profiles.data #>> '{position_information, field_values, division_of_job}' DESC")
        else
          order("profiles.data #>> '{position_information, field_values, division_of_job}' ")
        end
      when :working_status         then order("working_status #{sort_direction}")
      else
        order(sort_column => sort_direction)
    end
  }

  scope :by_id, -> (empoid) {
    where(users: {empoid: empoid}) if empoid
  }

  scope :by_empoid, -> (empoid) {
    where(users: {empoid: empoid}) if empoid
  }

  scope :by_date_of_employment, ->(date_of_employment) {
    from = Time.zone.parse(date_of_employment[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(date_of_employment[:end]).end_of_day rescue nil
    if from && to
      includes(user: :profile)
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
          .where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    elsif from
      includes(user: :profile).where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
    elsif to
      includes(user: :profile).where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    end
  }

  def self.by_users_employee_name(query, name)
    query = query.where(users: {chinese_name: name}).or(query.where(users: { english_name: name })) if name
    query
  end

end
