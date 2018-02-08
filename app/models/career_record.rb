# coding: utf-8
# == Schema Information
#
# Table name: career_records
#
#  id                           :integer          not null, primary key
#  user_id                      :integer
#  career_begin                 :datetime
#  career_end                   :datetime
#  deployment_type              :string
#  trial_period_expiration_date :datetime
#  salary_calculation           :string
#  company_name                 :string
#  location_id                  :integer
#  position_id                  :integer
#  department_id                :integer
#  grade                        :integer
#  division_of_job              :string
#  deployment_instructions      :string
#  inputer_id                   :integer
#  comment                      :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  employment_status            :string
#  valid_date                   :datetime
#  invalid_date                 :datetime
#  order_key                    :string
#  group_id                     :integer
#
# Indexes
#
#  index_career_records_on_career_begin   (career_begin)
#  index_career_records_on_career_end     (career_end)
#  index_career_records_on_department_id  (department_id)
#  index_career_records_on_group_id       (group_id)
#  index_career_records_on_inputer_id     (inputer_id)
#  index_career_records_on_invalid_date   (invalid_date)
#  index_career_records_on_position_id    (position_id)
#  index_career_records_on_user_id        (user_id)
#  index_career_records_on_valid_date     (valid_date)
#

class CareerRecord < ApplicationRecord
  include StatementAble
  include RecordCallbackAble
  # include CareerRecordValidators
  validates :user_id, :career_begin, :deployment_type, :salary_calculation, :company_name, :location_id, :position_id,
            :department_id, :grade, :division_of_job, :inputer_id, :employment_status, presence: true

  #entry: 入职
  #through_the_probationary_period： 通過入職試用期
  #transfer_by_employee_initiated： 調職（員工發起）
  #transfer_by_department_initiated： 調職（部門發起）
  #through_the_transfer_probation_period： 通過調職試用期
  #promotion： 晉升
  #special_assessment： 特別評估
  #museum： 調館
  #lent： 暫借
  #suspension_investigation： 停職調查
  #other： 其他

  validates :deployment_type, inclusion: {in: %w(entry through_the_probationary_period transfer_by_employee_initiated
transfer_by_department_initiated through_the_transfer_probation_period promotion special_assessment museum lent
suspension_investigation other)}
  validates :salary_calculation, inclusion: {in: %w(do_not_adjust_the_salary adjust_the_salary_to_adjust_the_proportion_of_the_month
adjustments_are_not_adjusted_in_proportion_to_the_remuneration_of_the_month)}
  validates :company_name, inclusion: {in: %w(suncity_gaming_promotion_company_limited suncity_group_commercial_consulting
suncity_group_tourism_limited tian_mao_yi_hang)}
  validates :grade, inclusion: {in: [1, 2, 3, 4, 5, 6]}
  validates :division_of_job, inclusion: {in: %w(front_office back_office)}

  validates :employment_status, inclusion: {in: %w(informal_employees formal_employees director president director_in_informal
president_in_informal part_time trainee)}
  validates :location_id, presence: true
  # validates_with CareerRecordValidator
  belongs_to :user
  belongs_to :inputer, class_name: 'User', foreign_key: 'inputer_id'
  belongs_to :location
  belongs_to :department
  belongs_to :position
  belongs_to :group
  has_many :lent_records
  has_many :museum_records
  before_destroy :valid_status
  after_save :update_user

  def update_user
    TimelineRecordService.update_valid_date(self.user)
    ProfileService.update_profile(self.user)
  end


  def self.create_initial_record(params)
    CareerRecord.create(
      user_id: params[:user_id], career_begin: (params[:career_begin]||Time.zone.now.beginning_of_day), deployment_type: :entry,
      trial_period_expiration_date: params[:trial_period_expiration_date],  salary_calculation: :do_not_adjust_the_salary,
      company_name: params[:company_name], location_id: params[:location_id], position_id: params[:position_id],
      department_id: params[:department_id], grade: params[:grade], division_of_job: params[:division_of_job],
      deployment_instructions: nil, inputer_id: params[:inputer_id], employment_status: params[:employment_status], group_id: params[:group_id]
    )
  end


  def is_being_valid?
    self.user.career_records.count == 1 && (self.user.career_records.exists? self)
  end

  def self.career_information_options
    {
      deployment_type: Config.get_all_option_from_selects(:deployment_type),
      salary_calculation: Config.get_all_option_from_selects(:salary_calculation),
      company_name: Config.get_all_option_from_selects(:company_name),
      location_id: Location.all,
      department_id: Department.all,
      position_id: Position.all,
      grade: Config.get_all_option_from_selects(:grade),
      group_id: Group.all,
      division_of_job: Config.get_all_option_from_selects(:division_of_job),
      employment_status: Config.get_all_option_from_selects(:employment_status)
    }
  end

  def self.update_roster_after_create(record, current_user)
    user = User.find_by(id: record.user_id)
    date_begin = record.career_begin.to_date
    date_end = record.career_end ? record.career_end.to_date : nil

    if record.deployment_type == 'museum'
      # Museum.update_roster_after_create(record, current_user)
      RosterObject.update_open_time(user, date_begin, current_user, record.location_id, 'transfer_location', nil)
    elsif record.deployment_type == 'lent'
      # LentRecord.update_roster_after_create(record, current_user)
      RosterObject.update_close_time(user, date_begin, date_end, current_user, record.location_id, 'lent_temporarily', nil)
    else
      if date_end
        RosterObject.update_close_time(user, date_begin, date_end, current_user, record.location_id, 'transfer_position', record.department_id)
      else
        RosterObject.update_open_time(user, date_begin, current_user, record.location_id, 'transfer_position', record.department_id)
      end
    end
  end

  def self.update_roster_after_destroy(record)
    user = User.find_by(id: record.user_id)
    date_begin = record.career_begin.to_date
    date_end = record.career_end ? record.career_end.to_date : nil

    if record.deployment_type == 'museum'
      RosterObject.destroy_open_time(user, date_begin, record.location_id, 'transfer_location', nil)
    elsif record.deployment_type == 'lent'
      RosterObject.destroy_close_time(user, date_begin, date_end, record.location_id, 'lent_temporarily', nil)
    else
      if date_end
        RosterObject.destroy_close_time(user, date_begin, date_end, record.location_id, 'transfer_position', record.department_id)
      else
        RosterObject.destroy_open_time(user, date_begin, record.location_id, 'transfer_position', record.department_id)
      end
    end
  end

  scope :by_search_for_one_day, lambda { |one_day|
    where("valid_date <= :one_day AND ( invalid_date >= :one_day)", one_day: one_day.beginning_of_day)
  }

  scope :by_current_valid_record_for_career_info, lambda {
    by_current_valid_record.order(career_begin: :desc)
  }


  scope :by_current_valid_record, lambda {
    where("valid_date <= :today AND ( invalid_date >= :today)", today: Time.zone.now.beginning_of_day)
  }


  scope :by_trial_period_expiration_date, -> (trial_period_expiration_date) {
    from = Time.zone.parse(trial_period_expiration_date[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(trial_period_expiration_date[:end]).end_of_day rescue nil
    if from && to
      where('trial_period_expiration_date >= :from', from: from).where('trial_period_expiration_date <= :to', to: to)
    elsif from
      where('trial_period_expiration_date >= :from', from: from)
    elsif to
      where('trial_period_expiration_date <= :to', to: to)
    end
  }

  scope :by_empoid, -> (empoid) {
    includes(:user).where(:users => { empoid: empoid })
  }

  scope :by_name, -> (name) {
    includes(:user).where(user_id: User.where('chinese_name = :name OR english_name = :name', name: name).select(:id))
  }

  scope :by_company_name, -> (company_name) {
    where(company_name: company_name)
  }

  scope :by_location, -> (location) {
    where(location_id: location)
  }

  scope :by_department, -> (department) {
    where(department_id: department)
  }

  scope :by_position, -> (position) {
    where(position_id: position)
  }

  scope :order_by, -> (sort_column, sort_direction) {
    case sort_column
      when :empoid                        then order("users.empoid #{sort_direction}")
      when :name                          then order("users.chinese_name #{sort_direction}")
      when :location                      then order("location_id #{sort_direction}")
      when :department                    then order("department_id #{sort_direction}")
      when :group                         then order("group_id #{sort_direction}")
      when :position                      then order("position_id #{sort_direction}")
      else
        order(sort_column => sort_direction)
    end
  }

end
