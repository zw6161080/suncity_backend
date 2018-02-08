# == Schema Information
#
# Table name: lent_records
#
#  id                              :integer          not null, primary key
#  user_id                         :integer
#  lent_begin                      :datetime
#  lent_end                        :datetime
#  deployment_type                 :string
#  original_hall_id                :integer
#  temporary_stadium_id            :integer
#  calculation_of_borrowing        :string
#  return_compensation_calculation :string
#  comment                         :string
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#  valid_date                      :datetime
#  invalid_date                    :datetime
#  order_key                       :string
#  career_record_id                :integer
#
# Indexes
#
#  index_lent_records_on_career_record_id  (career_record_id)
#  index_lent_records_on_user_id           (user_id)
#

class LentRecord < ApplicationRecord
  include RecordCallbackAble
  # include LentRecordValidators
  # validates_with UserCanLentRecordValidator
  validates :user_id, :lent_begin, :deployment_type, :original_hall_id, :temporary_stadium_id, :calculation_of_borrowing,
            presence:  true
  validates :deployment_type, inclusion: {in: %w(entry through_the_probationary_period transfer_by_employee_initiated
transfer_by_department_initiated through_the_transfer_probation_period promotion special_assessment museum lent
suspension_investigation other)}
  validates :calculation_of_borrowing, inclusion: {in: %w(do_not_adjust_the_salary adjust_the_salary_to_adjust_the_proportion_of_the_month
adjustments_are_not_adjusted_in_proportion_to_the_remuneration_of_the_month)}
  validates :return_compensation_calculation, inclusion: {in: %w(do_not_adjust_the_salary adjust_the_salary_to_adjust_the_proportion_of_the_month
adjustments_are_not_adjusted_in_proportion_to_the_remuneration_of_the_month)}, unless: :return_compensation_calculation_not_filled?
  belongs_to :user
  belongs_to :career_record
  belongs_to :original_hall, class_name: :Location, foreign_key: :original_hall_id
  belongs_to :temporary_stadium, class_name: :Location, foreign_key: :temporary_stadium_id
  before_validation :set_career_record_id
  after_save :update_location


  scope :by_search_for_one_day, lambda { |one_day|
    where("lent_begin <= :one_day AND ( lent_end >= :one_day OR lent_end is null)", one_day: one_day.beginning_of_day).order(lent_begin: :desc)
  }

  def update_location
    ProfileService.update_profile(self.user)
  end



  def set_career_record_id
    unless self.career_record_id
      career_record = TimelineRecordService.get_relative_career_record(self.user, self.lent_begin, self.lent_end)
      if career_record
        self.career_record_id = career_record.id
      end
    end
  end

  def return_compensation_calculation_not_filled?
    self.return_compensation_calculation.nil?
  end


  def self.lent_information_options
    {
      deployment_type: Config.get_all_option_from_selects(:deployment_type),
      calculation_of_borrowing: Config.get_all_option_from_selects(:salary_calculation),
      return_compensation_calculation: Config.get_all_option_from_selects(:salary_calculation),
      original_hall_id: Location.all
    }
  end

  def self.can_lent_by_department?(department_id, location_id)
    Department.find(department_id).locations.include? Location.find(location_id)
  end


  def self.update_roster_after_create(record, current_user)
    if record.lent_begin && record.lent_end
      user = User.find(record.user_id)

      start_date = record.lent_begin.to_date
      end_date = record.lent_end.to_date
      before_date = start_date - 1.day

      (start_date .. end_date).each do |d|
        ro = RosterObject.where(user_id: user.id, is_active: ['active', nil], roster_date: d, location_id: record.original_hall_id).first
        if ro
          RosterObject.create(ro.attributes.merge({
                                                    id: nil,
                                                    is_active: 'inactive',
                                                    special_type: 'lent_temporarily',
                                                    created_at: nil,
                                                    updated_at: nil
                                                  }))

          ro.is_active = 'active'
          ro.special_type = 'lent_temporarily'
          ro.class_setting_id = ro.borrow_return_type || ro.adjust_type ? ro.class_setting_id : nil
          ro.location_id = record.temporary_stadium_id
          # ro.roster_list_id = nil
          ro.roster_list_id = RosterList.find_list(ro.roster_date, ro.location_id, ro.department_id)&.id
          ro.save

          ro.roster_object_logs.create(modified_reason: 'lent_temporarily',
                                       approver_id: current_user.id,
                                       approval_time: Time.zone.now.to_datetime,
                                       class_setting_id: ro.class_setting_id,
                                       is_general_holiday: ro.is_general_holiday,
                                       working_time: ro.working_time,
                                       holiday_type: ro.holiday_type,
                                       borrow_return_type: ro.borrow_return_type,
                                       working_hours_transaction_record_id: ro.working_hours_transaction_record_id,
          )
        else
          # d_time = Time.zone.local(d.year, d.month, d.day).to_datetime.beginning_of_day
          d_time = before_date.to_datetime.beginning_of_day
          # o_location = ProfileService.location(user, d_time)
          o_department = ProfileService.department(user, d_time)

          inactive_ro = RosterObject.create(user_id: user.id,
                                            roster_date: d,
                                            location_id: record.original_hall_id,
                                            department_id: o_department.id,
                                            is_active: 'inactive',
                                            special_type: 'lent_temporarily')

          active_ro = RosterObject.create(user_id: user.id,
                                          roster_date: d,
                                          location_id: record.temporary_stadium_id,
                                          department_id: o_department&.id,
                                          is_active: 'active',
                                          special_type: 'lent_temporarily')

          active_ro.roster_object_logs.create(modified_reason: 'lent_temporarily',
                                              approver_id: current_user.id,
                                              approval_time: Time.zone.now.to_datetime,
                                              class_setting_id: active_ro.class_setting_id,
                                              is_general_holiday: active_ro.is_general_holiday,
                                              working_time: active_ro.working_time,
                                              holiday_type: active_ro.holiday_type,
                                              borrow_return_type: active_ro.borrow_return_type,
                                              working_hours_transaction_record_id: active_ro.working_hours_transaction_record_id,
          )
        end
      end
    end
  end

  def self.update_roster_after_destroy(record)
    if record.lent_begin && record.lent_end
      user = User.find(record.user_id)
      start_date = record.lent_begin.to_date
      end_date = record.lent_end.to_date

      (start_date .. end_date).each do |d|
        d_time = Time.zone.local(d.year, d.month, d.day).to_datetime.beginning_of_day
        # o_location = ProfileService.location(user, d_time)
        o_department = ProfileService.department(user, d_time)

        ro = RosterObject.where(user_id: user.id, roster_date: d, location_id: record.original_hall_id, department_id: o_department&.id, is_active: 'inactive', special_type: 'lent_temporarily').first
        ro.destroy if ro
      end

      (start_date .. end_date).each do |d|
        d_time = Time.zone.local(d.year, d.month, d.day).to_datetime.beginning_of_day
        o_department = ProfileService.department(user, d_time)

        ro = RosterObject.where(user_id: user.id, roster_date: d, location_id: record.temporary_stadium_id, department_id: o_department&.id, is_active: 'active', special_type: 'lent_temporarily').first
        if ro
          ro.class_setting_id = nil
          ro.is_general_holiday = nil
          ro.working_time = nil
          ro.holiday_type = nil
          ro.location_id = record.original_hall_id,
            ro.department_id = o_department.id
          ro.is_active = 'active'
          ro.special_type = nil
          ro.save
        end
      end
    end
  end
end
