# == Schema Information
#
# Table name: museum_records
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  date_of_employment :datetime
#  deployment_type    :string
#  salary_calculation :string
#  location_id        :integer
#  comment            :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  valid_date         :datetime
#  invalid_date       :datetime
#  order_key          :string
#  career_record_id   :integer
#
# Indexes
#
#  index_museum_records_on_career_record_id  (career_record_id)
#  index_museum_records_on_user_id           (user_id)
#

class MuseumRecord < ApplicationRecord
  include RecordCallbackAble
  validates :user_id, :date_of_employment, :deployment_type, :salary_calculation, :location_id, :career_record_id, presence: true
  validates :deployment_type, inclusion: {in: %w(entry through_the_probationary_period transfer_by_employee_initiated
transfer_by_department_initiated through_the_transfer_probation_period promotion special_assessment museum lent
suspension_investigation other)}
  validates :salary_calculation, inclusion: {in: %w(do_not_adjust_the_salary adjust_the_salary_to_adjust_the_proportion_of_the_month
adjustments_are_not_adjusted_in_proportion_to_the_remuneration_of_the_month)}
  belongs_to :user
  belongs_to :career_record
  belongs_to :location
  before_validation :set_career_record_id
  after_save :update_location


  def update_location
    ProfileService.update_profile(self.user)
  end


  def set_career_record_id
    unless self.career_record_id
      career_record = TimelineRecordService.get_relative_career_record(self.user, self.date_of_employment)
      if career_record
        self.career_record_id = career_record.id
      end
    end
  end

  def self.can_museum_by_department?(department_id, location_id)
    Department.find(department_id).locations.include? Location.find(location_id)
  end


  def self.museum_information_options
    {
      deployment_type: Config.get_all_option_from_selects(:deployment_type),
      salary_calculation: Config.get_all_option_from_selects(:salary_calculation),
      location_id: Location.all
    }
  end

  def self.update_roster_after_create(record, current_user)
    user = User.find_by(id: record.user_id)
    date = record.date_of_employment.to_date

    should_change_roster_objects = RosterObject
                                     .where(user_id: user.id, is_active: ['active', nil])
                                     .where("roster_date >= ?", date)

    should_change_roster_objects.each do |ro|
      RosterObject.create(ro.attributes.merge({
                                                id: nil,
                                                is_active: 'inactive',
                                                special_type: 'transfer_location',
                                                created_at: nil,
                                                updated_at: nil
                                              }))
      ro.is_active = 'active'
      ro.special_type = 'transfer_location'
      # May Do
      # backup_class_setting_id = ro.class_setting_id
      ro.class_setting_id = ro.borrow_return_type || ro.adjust_type ? ro.class_setting_id : nil
      ro.location_id = record.location_id
      # ro.roster_list_id = nil
      ro.roster_list_id = RosterList.find_list(ro.roster_date, ro.location_id, ro.department_id)&.id
      ro.save

      ro.roster_object_logs.create(modified_reason: 'transfer_location',
                                   approver_id: current_user.id,
                                   approval_time: Time.zone.now.to_datetime,
                                   class_setting_id: ro.class_setting_id,
                                   is_general_holiday: ro.is_general_holiday,
                                   working_time: ro.working_time,
                                   holiday_type: ro.holiday_type,
                                   borrow_return_type: ro.borrow_return_type,
                                   working_hours_transaction_record_id: ro.working_hours_transaction_record_id,
                                  )
    end
  end

  def self.update_roster_after_destroy(record)
    user = User.find_by(id: record.user_id)
    date = record.date_of_employment.to_date

    should_change_roster_objects = RosterObject
                                     .where(user_id: user.id, is_active: ['active', nil])
                                     .where("roster_date >= ?", date)


    should_change_roster_objects.each do |ro|
      d_time = ro.roster_date.to_datetime.beginning_of_day
      o_location = ProfileService.location(user, d_time)
      o_department = ProfileService.department(user, d_time)

      should_destroy_ro = RosterObject.where(user_id: user.id, roster_date: ro.roster_date, location_id: o_location&.id, department_id: o_department&.id, is_active: 'inactive', special_type: 'transfer_location').first
      ro.destroy if should_destroy_ro
    end

    should_change_roster_objects.each do |ro|
      d_time = ro.roster_date.to_datetime.beginning_of_day
      o_location = ProfileService.location(user, d_time)
      o_department = ProfileService.department(user, d_time)

      should_change_ro = RosterObject.where(user_id: user.id, roster_date: ro.roster_date, location_id: record.location_id, department_id: o_department&.id, is_active: ['active', nil], special_type: 'transfer_location').first
      if should_change_ro
        should_change_ro.is_active = 'active'
        should_change_ro.special_type = nil
        should_change_ro.class_setting_id = ro.borrow_return_type || ro.adjust_type ? ro.class_setting_id : nil
        should_change_ro.location_id = o_location&.id
        # should_change_ro.roster_list_id = nil
        should_change_ro.roster_list_id = RosterList.find_list(should_change_ro.roster_date, should_change_ro.location_id, should_change_ro.department_id)&.id
        should_change_ro.save
      end
    end
  end

end
