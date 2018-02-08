# coding: utf-8
# == Schema Information
#
# Table name: welfare_records
#
#  id                     :integer          not null, primary key
#  change_reason          :string
#  welfare_begin          :datetime
#  welfare_end            :datetime
#  annual_leave           :decimal(10, 2)
#  sick_leave             :decimal(10, 2)
#  office_holiday         :decimal(10, 2)
#  welfare_template_id    :integer
#  holiday_type           :string
#  probation              :decimal(10, 2)
#  notice_period          :decimal(10, 2)
#  double_pay             :boolean
#  reduce_salary_for_sick :boolean
#  provide_uniform        :boolean
#  salary_composition     :string
#  over_time_salary       :string
#  force_holiday_make_up  :string
#  comment                :string
#  user_id                :integer
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  valid_date             :datetime
#  invalid_date           :datetime
#  order_key              :string
#  position_type          :string
#  work_days_every_week   :integer
#
# Indexes
#
#  index_welfare_records_on_user_id              (user_id)
#  index_welfare_records_on_welfare_template_id  (welfare_template_id)
#

class WelfareRecord < ApplicationRecord
  include RecordCallbackAble
  include StatementAble
  # include WelfareRecordValidators
  validates :change_reason, :user_id, presence: true
  validates :welfare_begin, presence: true
  validates :annual_leave, :sick_leave, :office_holiday, :probation, :notice_period, :over_time_salary,
            :force_holiday_make_up, presence: true, unless: :template_is_filled?
  #entry:入职
  #through_the_probationary_period：通過入職試用期
  #transfer_by_employee_initiated：調職（員工發起）
  #transfer_by_department_initiated：調職（部門發起）
  #through_the_transfer_probation_period：通過調職試用期
  #promotion:晉升
  #special_assessment:特別評估
  #museum:調館
  #lent:暂借
  #suspension_investigation：停職調查
  #other：其他
  validates :change_reason, inclusion: {in: %W(entry through_the_probationary_period transfer_by_employee_initiated
 transfer_by_department_initiated through_the_transfer_probation_period promotion special_assessment museum lent suspension_investigation
other)}
  #none_holiday：无
  #force_holiday：强制性假期
  #force_public_holiday: 强制性公共假期
  validates :holiday_type, inclusion: {in: %W(none_holiday force_holiday force_public_holiday)}, unless: :template_is_filled?
  #fixed: 固定
  #float: 浮动
  validates :salary_composition, inclusion: {in: %w(fixed float)}, unless: :template_is_filled?
  #one_point_two_times :1.2倍
  #one_point_two_and_two_times: 1.2倍及2倍
  validates :over_time_salary, inclusion: {in: %w(one_point_two_times one_point_two_and_two_times)}, unless: :template_is_filled?
  #one_money_and_one_holiday: 一钱一假
  #two_money: 两钱
  #two_holiday: 两假
  validates :force_holiday_make_up, inclusion: {in: %w(one_money_and_one_holiday two_money two_holiday)}, unless: :template_is_filled?
  validates :double_pay, inclusion: {in: [false, true]}, unless: :template_is_filled?
  validates :reduce_salary_for_sick, inclusion: {in: [false, true]}, unless: :template_is_filled?
  validates :provide_uniform, inclusion: {in: [false, true]}, unless: :template_is_filled?
  # validates_with WelfareRecordValidator
  # validates_numericality_of :work_days_every_week, :in => 5..6
  # validates :position_type, inclusion: {in: %w(business_staff_48 business_staff_40 non_business_staff_48 non_business_staff_40)}
  belongs_to :user
  belongs_to :welfare_template
  before_destroy :valid_status

  after_save :update_reports
  after_destroy :update_reports

  scope :by_current_valid_record_for_welfare_info, lambda {
    valid_record = by_current_valid_record.order(welfare_begin: :desc)
    if valid_record.count >= 1
      valid_record
    else
      valid_record = where("welfare_begin < :today", today: Time.zone.now.beginning_of_day).order(welfare_begin: :desc)
      if valid_record.count >= 1
        valid_record
      else
        where("welfare_begin > :today", today: Time.zone.now.beginning_of_day).order(welfare_begin: :asc)
      end
    end
  }


  scope :by_current_valid_record, lambda {
    where("welfare_begin <= :today AND ( welfare_end >= :today OR welfare_end is null)", today: Time.zone.now.beginning_of_day)
  }

  scope :by_search_for_one_day, lambda { |one_day|
    where("welfare_begin <= :one_day AND ( welfare_end >= :one_day OR welfare_end is null)", one_day: one_day.beginning_of_day).order(welfare_begin: :desc)
  }


  scope :by_date_range, -> (date_begin, date_end) {
    where.not('welfare_begin > :date_end OR (welfare_end < :date_begin AND welfare_end IS NOT NULL)', date_begin: date_begin, date_end: date_end)
  }

  scope :by_company_name, -> (company_name) {
    where(:users => { company_name: company_name })
  }

  scope :by_location, -> (location) {
    where(:users => { location_id: location })
  }

  scope :by_department, -> (department) {
    where(:users => { department_id: department })
  }

  scope :by_query_date, -> (query_date) {
    from = Time.zone.parse(query_date[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(query_date[:end]).end_of_day rescue nil
    if from && to
      where("welfare_begin >= :from", from: from).where("welfare_begin <= :to", to: to)
    elsif from
      where("welfare_begin >= :from", from: from)
    elsif to
      where("welfare_begin <= :to", to: to)
    end
  }

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
      when :valid_date          then order("valid_date #{sort_direction}")
    end
  }




  def template_is_filled?
    !self.welfare_template_id.nil?
  end



  def is_being_valid?
    self.user.welfare_records.count == 1 && (self.user.welfare_records.include? self)
  end

  def self.welfare_information_options
    {
      annual_leave: Config.get_all_option_from_selects(:annual_leave),
      sick_leave: Config.get_all_option_from_selects(:sick_leave),
      office_holiday: Config.get_all_option_from_selects(:office_holiday),
      holiday_type: Config.get_all_option_from_selects(:holiday_type),
      probation: Config.get_all_option_from_selects(:probation),
      notice_period: Config.get_all_option_from_selects(:notice_period),
      double_pay: Config.get_all_option_from_selects(:double_pay),
      reduce_salary_for_sick: Config.get_all_option_from_selects(:reduce_salary_for_sick),
      provide_uniform: Config.get_all_option_from_selects(:provide_uniform),
      salary_composition: Config.get_all_option_from_selects(:salary_composition),
      over_time_salary: Config.get_all_option_from_selects(:over_time_salary),
      force_holiday_make_up: Config.get_all_option_from_selects(:force_holiday_make_up),
      provide_airfare: Config.get_all_option_from_selects(:provide_airfare),
      provide_accommodation: Config.get_all_option_from_selects(:provide_accommodation),
      change_reason: Config.get_all_option_from_selects(:change_reason),
      position_type: Config.get_all_option_from_selects(:position_type),
      work_days_every_week: Config.get_all_option_from_selects(:work_days_every_week)
    }
  end

  def update_reports
    AttendMonthlyReport.where(user_id: self.user_id).each do |r|
      RefreshAttendMonthlyReportJob.perform_later(r)
    end

    AttendAnnualReport.where(user_id: self.user_id).each do |r|
      RefreshAttendAnnualReportJob.perform_later(r)
    end
  end
end
