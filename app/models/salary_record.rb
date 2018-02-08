# == Schema Information
#
# Table name: salary_records
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  change_reason       :string
#  salary_begin        :datetime
#  salary_end          :datetime
#  salary_template_id  :integer
#  basic_salary        :decimal(10, 2)   default(0.0)
#  bonus               :decimal(10, 2)   default(0.0)
#  attendance_award    :decimal(10, 2)   default(0.0)
#  new_year_bonus      :decimal(10, 2)   default(0.0)
#  project_bonus       :decimal(10, 2)   default(0.0)
#  product_bonus       :decimal(10, 2)   default(0.0)
#  tea_bonus           :decimal(10, 2)   default(0.0)
#  kill_bonus          :decimal(10, 2)   default(0.0)
#  performance_bonus   :decimal(10, 2)   default(0.0)
#  charge_bonus        :decimal(10, 2)   default(0.0)
#  commission_bonus    :decimal(10, 2)   default(0.0)
#  receive_bonus       :decimal(10, 2)   default(0.0)
#  exchange_rate_bonus :decimal(10, 2)   default(0.0)
#  guest_card_bonus    :decimal(10, 2)   default(0.0)
#  respect_bonus       :decimal(10, 2)   default(0.0)
#  comment             :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  region_bonus        :decimal(10, 2)   default(0.0)
#  valid_date          :datetime
#  invalid_date        :datetime
#  order_key           :string
#  house_bonus         :decimal(15, 2)   default(0.0)
#  service_award       :decimal(15, 2)
#  internship_bonus    :decimal(15, 2)
#  performance_award   :decimal(15, 2)
#  special_tie_bonus   :decimal(15, 2)
#
# Indexes
#
#  index_salary_records_on_invalid_date        (invalid_date)
#  index_salary_records_on_salary_begin        (salary_begin)
#  index_salary_records_on_salary_end          (salary_end)
#  index_salary_records_on_salary_template_id  (salary_template_id)
#  index_salary_records_on_user_id             (user_id)
#  index_salary_records_on_valid_date          (valid_date)
#

class SalaryRecord < ApplicationRecord
  include RecordCallbackAble
  include StatementAble
  # include SalaryRecordValidators
  validates :user_id, :change_reason, presence:  true
  validates :salary_begin, presence:  true

  validates :change_reason, inclusion: {in: %w(entry through_the_probationary_period transfer_by_employee_initiated
 transfer_by_department_initiated through_the_transfer_probation_period promotion special_assessment museum lent suspension_investigation
other)}
  # validates_with SalaryRecordValidator
  belongs_to :user
  belongs_to :salary_template
  after_create :reset_salary_change_records
  after_update :reset_salary_change_records
  before_destroy :valid_status
  before_destroy :destroy_salary_change_records
  after_destroy :reset_salary_change_records
  after_save :update_valid_and_invalid_date


  def update_valid_and_invalid_date
    TimelineRecordService.update_salary_record_valid_date(self.user)
  end

  scope :order_by, -> (sort_column, sort_direction) {
      case sort_column
        when :empoid              then order("users.empoid #{sort_direction}")
        when :name                then order("users.chinese_name #{sort_direction}")
        when :location            then order("users.location_id #{sort_direction}")
        when :department          then order("users.department_id #{sort_direction}")
        when :position            then order("users.position_id #{sort_direction}")
        when :grade               then order("users.grade #{sort_direction}")
        when :date_of_employment  then
          if sort_direction == :desc
            order("profiles.data #>> '{position_information, field_values, date_of_employment}' DESC")
          else
            order("profiles.data #>> '{position_information, field_values, date_of_employment}' ")
          end
        when :salary_begin          then order("salary_begin #{sort_direction}")
      end
  }

  scope :latest_record, -> (latest_record) {
  }

  scope :by_current_valid_record_for_salary_info, lambda {
    valid_record = by_current_valid_record.order(salary_begin: :desc)
    if  valid_record.count >= 1
      valid_record
    else
      valid_record  = where("salary_begin < :today", today: Time.zone.now.beginning_of_day).order(salary_begin: :desc)
      if valid_record.count >= 1
        valid_record
      else
        where("salary_begin > :today", today: Time.zone.now.beginning_of_day).order(salary_begin: :asc)
      end
    end
  }

  scope :by_current_valid_record, lambda {
    where("salary_begin <= :today AND ( salary_end >= :today OR salary_end is null)", today: Time.zone.now.beginning_of_day)
  }

  scope :by_search_for_one_day, lambda { |one_day|
    where("salary_begin <= :one_day AND ( salary_end >= :one_day OR salary_end is null)", one_day: one_day.beginning_of_day).order(salary_begin: :desc)
  }

  scope :by_company_name, lambda {|company_name|
    where(users: {company_name: company_name}) if company_name
  }

  scope :by_location, lambda {|location_id|
    where(users: {location_id: location_id}) if location_id
  }

  scope :by_position, lambda {|position_id|
    where(users: {position_id: position_id}) if position_id
  }

  scope :by_department, lambda {|department_id|
    where(users: {department_id: department_id}) if department_id
  }

  scope :by_change_date, lambda {|change_date|
    from = Time.zone.parse(change_date[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(change_date[:end]).end_of_day rescue nil
    if from && to
      where("salary_begin >= :from", from: from).where("salary_begin <= :to", to: to)
    elsif from
      where("salary_begin >= :from", from: from)
    elsif to
      where("salary_begin <= :to", to: to)
    end
  }

  scope :by_salary_begin_and_end, lambda { |salary_begin, salary_end|
    where.not('(salary_end IS NOT NULL AND salary_end <= :salary_begin) OR salary_begin > :salary_end ',
              salary_begin: salary_begin,
              salary_end: salary_end)
  }

  scope :by_salary_date, lambda { |date|
    where('salary_begin <= :date AND (salary_end IS NULL OR salary_end >= :date)', date: date)
  }




  def reset_salary_change_records
    SalaryRecordService.reset_change_record(self.user)
  end

  def destroy_salary_change_records
    self.user.month_salary_change_records.destroy_all
  end


  def not_filled?
    self.salary_template_id.nil?
  end



  def is_being_valid?
    self.user.salary_records.count == 1 && (self.user.salary_records.exists? self)
  end


  def self.salary_information_options
    {
      unit: Config.get_all_option_from_selects(:salary_unit),
      change_reason: Config.get_all_option_from_selects(:change_reason)
    }
  end
end
