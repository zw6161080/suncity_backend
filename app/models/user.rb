# coding: utf-8
# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  empoid              :string
#  chinese_name        :string
#  english_name        :string
#  password_digest     :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  position_id         :integer
#  location_id         :integer
#  department_id       :integer
#  id_card_number      :string
#  email               :string
#  superior_email      :string
#  company_name        :string
#  employment_status   :string
#  simple_chinese_name :string
#  grade               :integer
#  group_id            :integer
#
# Indexes
#
#  index_users_on_chinese_name       (chinese_name)
#  index_users_on_company_name       (company_name)
#  index_users_on_department_id      (department_id)
#  index_users_on_email              (email)
#  index_users_on_employment_status  (employment_status)
#  index_users_on_empoid             (empoid)
#  index_users_on_english_name       (english_name)
#  index_users_on_group_id           (group_id)
#  index_users_on_id_card_number     (id_card_number)
#  index_users_on_location_id        (location_id)
#  index_users_on_position_id        (position_id)
#  index_users_on_superior_email     (superior_email)
#
# Foreign Keys
#
#  fk_rails_f40b3f4da6  (group_id => groups.id)
#

class User < ApplicationRecord
  AUTH_FIELD = 'empoid'
  has_secure_password validations: false

  include JsonWebTokenAble
  include AuthAble
  has_many :month_salary_change_records
  has_many :my_attachments
  has_many :special_schedule_remarks
  has_many :holiday_records
  has_many :salary_values
  has_many :medical_records
  has_many :love_fund_records
  has_many :career_records
  has_many :lent_records
  has_many :museum_records
  has_many :resignation_records
  has_many :salary_records
  has_many :welfare_records
  has_many :award_records
  has_many :air_ticket_reimbursements
  has_many :assess_relationships, :class_name => 'AssessRelationship', :foreign_key => 'assessor_id'
  has_one :love_fund
  has_one :provident_fund
  has_one :profile
  has_one :shift_state
  has_one :roster_instruction
  has_one :language_skill
  has_one :family_member_information
  has_one :background_declaration
  has_one :profit_conflict_information
  has_one :love_fund
  belongs_to :position
  belongs_to :location
  belongs_to :department
  belongs_to :group
  has_many :interviewers
  has_many :audiences
  has_many :application_logs
  has_and_belongs_to_many :roles
  has_and_belongs_to_many :trains
  has_and_belongs_to_many :train_classes
  has_and_belongs_to_many :titles
  has_many :entry_lists

  has_many :training_absentees
  has_many :permissions, through: :roles

  has_many :roster_items
  has_many :shift_user_settings
  has_many :medical_reimbursements
  has_many :holidays

  has_one :shift_state
  has_one :card_profile

  has_one :shift_status
  has_many :roster_model_states
  has_many :punch_card_states

  has_many :staff_feedbacks
  has_many :staff_feedback_tracks
  has_many :punishments
  has_many :attendance_month_report_items

  has_many :appraisal_questionnaires, :class_name => 'AppraisalQuestionnaire', :foreign_key => 'assessor_id'

  has_many :dimissions

  has_and_belongs_to_many :trains

  has_one :appraisal_employee_setting

  has_many :attend_monthly_reports

  after_save :determine_head_of_department, :update_job_need_number, :update_appraisal_employee_setting

  attr_accessor :current_region

  scope :join_department_position_profile, lambda {
    joins(:department, :position, :profile)
  }

  scope :by_empoid, lambda { |empoid|
    where(users: {empoid: empoid})
  }

  scope :by_name, lambda { |name|
    where(users: {select_language => name})
  }

  scope :by_department_id, lambda { |department_id|
    where(users: {department_id: department_id})
  }

  scope :by_position_id, lambda { |position_id|
    where(users: {position_id: position_id})
  }
  scope :by_location_id, lambda { |location_id|
    where(users: {location_id: location_id})
  }

  scope :by_grade, lambda { |grade|
    where(users: {grade: grade})
  }

  scope :by_division_of_job, lambda { |division_of_job|
    if division_of_job && (division_of_job.is_a? Array )
      includes(:profile).where("profiles.data -> 'position_information' -> 'field_values' -> 'division_of_job' ?| array["+ division_of_job.map{|item| "'#{item}'"}.join(',') +"]" )
    elsif division_of_job
      includes(:profile).where("profiles.data #>> '{position_information,field_values, division_of_job}' = :division_of_job", division_of_job: division_of_job)
    end
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

  scope :order_by, lambda {|sort_column, sort_direction|
    case sort_column
      when :empoid then order("users.empoid #{sort_direction}")
      when :name   then order("users.#{select_language.to_s} #{sort_direction}")
      when :department_id then order("users.department_id #{sort_direction}")
      when :position_id   then order("users.position_id #{sort_direction}")
      when :date_of_employment
        case sort_direction
          when :desc then order("profiles.data #>> '{position_information, field_values, date_of_employment}' DESC")
          else order("profiles.data #>> '{position_information, field_values, date_of_employment}' ")
        end
      else order(sort_column => sort_direction)
    end

  }

  scope :by_company_name, lambda { |company_name|
    where(company_name: company_name) if company_name
  }

  scope :by_chinese_name, lambda { |chinese_name|
    where('chinese_name like ?', "%#{chinese_name}%") if chinese_name
  }

  scope :by_english_name, lambda { |english_name|
    where('english_name like ?', "%#{english_name}%") if english_name
  }

  scope :by_empoid, lambda { |empoid|
    where(empoid: empoid) if empoid
  }
  scope :has_not_been_used_in_blue_card, lambda { |has_been_used_empoid|
    where.not(empoid: has_been_used_empoid) if has_been_used_empoid
  }
  scope :profile_to_blue_card, lambda {
    user_ids = Profile.by_up_to_blue_card.pluck(:user_id).compact.uniq
    where(id: user_ids)
  }

  scope :select_show_information, lambda {
    select(User.create_params)
  }

  scope :by_location_with_departments, lambda {|location|
    where(location_id: location.id, department_id: location.departments.ids)
  }

  scope :by_location_with_departments_without_suncity, lambda {|location|
    where(location_id: location.id, department_id: location.departments.without_suncity_department.ids)
  }



  def completed_trains
    self.trains.where(status: :completed)
  end

  def group_id
    ProfileService.group(self)&.id
  end

  def head_index
    self.my_attachments.limit(5).order(created_at: :desc)
  end

  def all_index(params)
    query =  self.my_attachments.by_query_key(params[:query_key])
    total_count = query.count
    show_count = 10 * (params[:more_record_count]&.to_i || 1 )
    meta = total_count > show_count
    {query: query.limit(show_count).order(created_at: :desc), meta: meta}
  end

  def simple_chinese_name
    chinese_name
  end

  def train_info
    {
        total_training_credits: self.total_training_credits,
        training_attend_percentage:self.training_attend_percentage,
        passing_trainning_percentage: self.passing_trainning_percentage,
        is_can_be_absent: self.is_can_be_absent,
    }
  end

  def create_career_record_for_suspension_investigation(params)
    self.career_records.create!(self.merge_params_for_suspension_investigation(params))
  end

  def finish_career_record_for_suspension_investigation(params)
    career_record = user.career_records.where(career_begin: params[:career_begin], salary_calculation: :do_not_adjust_the_salary).first rescue nil
    if career_record
      career_record.update(self.merge_params_for_suspension_investigation(params).without([:inputer_id, [:deployment_instructions]]))
    else
      create_career_record_for_suspension_investigation(params)
    end
  end

  def merge_params_for_suspension_investigation(params)
    params.merge(
      deployment_type: :suspension_investigation,
      salary_calculation: :do_not_adjust_the_salary,
      company_name: self.company_name,
      location_id: self.location_id,
      department_id: self.department_id,
      position_id: self.position_id,
      grade: self.grade,
      employment_status: self.employment_status,
      division_of_job: ProfileService.division_of_job(self)
    )
  end


  def self.by_entry_list(query, train_id)
    ids_without_this_train = query.select do |item|
      item   if item.entry_lists.where(entry_lists: {train_id: train_id}).empty?
    end&.map{|item| item.id}
    {
        users_with_this_train: query.where(entry_lists: {train_id: train_id}),
        users_without_this_train: query.where(id: ids_without_this_train),
        limit_number: Train.find(train_id).limit_number,
        titles: Train.find(train_id).titles.map{|title| title.as_json.merge(
            {
                total_count: EntryList.where(title_id: title.id).count,
                department_count: EntryList.where(title_id: title.id, user_id: query.pluck(:id).uniq ).count
            }
        )},
        total_count_in_all_titles: EntryList.by_train_id(train_id).count,
        department_count_in_all_titles: EntryList.where(train_id: train_id, user_id: query.pluck(:id).uniq ).count
    }
  end

  def self.field_options_all_trains
    user_query = self.left_outer_joins(:department, :position)
    positions = user_query.select('positions.*').distinct.as_json
    departments = user_query.select('departments.*').distinct.as_json
    return {
        positions: positions,
        departments: departments
    }
  end

  def self.field_options_get_user
    user_query = self.left_outer_joins(:department, :position, :profile)
    positions = user_query.select('positions.*').distinct.as_json
    departments = user_query.select('departments.*').distinct.as_json
    grades = Config.get('selects')['grade']['options']
    division_of_jobs = Config.get('selects')['division_of_job']['options']
    return {
        positions: positions,
        departments: departments,
        grades: grades,
        division_of_jobs: division_of_jobs
    }
  end

  def self.salary_calculation_users
    User.all.order(id: :desc).limit(20)
  end

  def key
    id.to_s
  end

  def call(event_name, params)
    self.send(event_name, params)
  end

  def method_missing(method_id, *arguments, &block)
    match = /^sync_with_user_(?<attribute>\w+)/.match(method_id.to_s)

    if match
      attribute_name = match[:attribute]
      validate_empoid_uniqueness(*arguments) if :empoid == attribute_name.to_sym
      self.update_column(attribute_name, *arguments)
      self.update_job_need_number if [:region, :department_id, :position_id].include?(attribute_name.to_sym)
    else
      super
    end
  end

  def profile_id
    profile ? profile.id : nil
  end

  def career_entry_date
    ProfileService.date_of_employment(self)
  end

  def resignation_date
    ProfileService.date_of_employment(self)
  end

  def date_of_employment
    personal_information = profile&.data['position_information']['field_values']
    personal_information.nil? ? nil : Time.zone.parse(personal_information['date_of_employment'])
  end

  def date_of_birth
    personal_information = profile&.data['personal_information']['field_values']['date_of_birth']
    personal_information.nil? ? nil : Time.zone.parse(personal_information['date_of_birth'])
  end

  def employment_of_status
    resign_date = self.resignation_date
    if resign_date && resign_date > Time.now
      Config.get(:constants_collection)['employment_of_status']['leave_out']
    else
      Config.get(:constants_collection)['employment_of_status']['on_working']
    end
  end

  #Determin Head of Department
  def determine_head_of_department
    user_position = self.position
    user_department = self.department
    user_grade = self.grade

    set_head = false

    if user_position and user_department
      if user_department.head
        head_grade = user_department.head.grade

        if user_grade < head_grade
          set_head = true
        end
      else
        set_head = true
      end
    end

    if set_head
      user_department.head_id = self.id
      user_department.save
    end
  end

  def has_role?(role)
    roles.exists?(role.id)
  end

  def add_role(role)
    roles << role unless has_role?(role)
  end

  def remove_role(role)
    roles.delete(role) if has_role?(role)
  end

  def has_permission?(action, resource=:global, region=nil)

    region = self.profile.region unless region

    permission = {
      action: action,
      resource: resource,
      region: region
    }

    permissions.exists?(permission)

  end
  alias_method :can?, :has_permission?

  def shift_user_settings_of_roster(roster_id)
    self.shift_user_settings.find_by_roster_id(roster_id)
  end

  def validate_empoid_uniqueness(new_empoid)
    unless User.all.where.not(id: self.id).find_by_empoid(new_empoid).blank?
      raise LogicError, { message: "Illegal empoid!" }.to_json
    end
  end

  def self.of_permission(action, resource, region)
    self.joins(:permissions).where('permissions.action = ?', action).where('permissions.resource = ?', resource).where('permissions.region = ?',  region)
  end

  def update_job_need_number
    Job.recaculate_need_number
  end

  def update_appraisal_employee_setting
    AppraisalEmployeeSetting.generate
  end

  def division_of_job
    division_of_job_key = self.profile.data['position_information']['field_values']['division_of_job']
    Config.get(:selects)['division_of_job']['options'].select { |op| op['key'] == division_of_job_key }.first
  end

  def punch_card_state_of_date(d)
    pcs = self.punch_card_states.where("effective_date <= ? AND (end_date >= ? OR end_date is null)", d, d).order("effective_date desc")&.last
    (pcs != nil && pcs&.is_need == true) ? true : false
  end
end
