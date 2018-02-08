# == Schema Information
#
# Table name: reserved_holiday_participators
#
#  id                          :integer          not null, primary key
#  reserved_holiday_setting_id :integer
#  user_id                     :integer
#  owned_days_count            :integer
#  taken_days_count            :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#
# Indexes
#
#  index_participators_on_reserved_holiday_setting_id  (reserved_holiday_setting_id)
#  index_reserved_holiday_participators_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_aeaa0245cf  (reserved_holiday_setting_id => reserved_holiday_settings.id)
#  fk_rails_e356d2e3dd  (user_id => users.id)
#

class ReservedHolidayParticipator < ApplicationRecord

  include StatementAble

  belongs_to :user
  belongs_to :reserved_holiday_setting

  validates :reserved_holiday_setting_id, :user_id, :owned_days_count, presence: true

  after_create :count_member
  after_destroy :count_member

  def count_member
    self.reserved_holiday_setting.update_member_count
  end

  class << self
    def setting_options
      ReservedHolidaySetting.where(id: self.select(:reserved_holiday_setting_id))
    end

    def position_options
      Position.where(id: self.joins(:user).select('users.position_id'))
    end

    def department_options
      Department.where(id: self.joins(:user).select('users.department_id'))
    end
  end

  scope :by_reserved_holiday_setting, -> (reserved_holiday_setting_id) {
    where(:reserved_holiday_settings => { id: reserved_holiday_setting_id }) if name
  }

  scope :by_name, -> (name) {
    where(user_id: User.where('chinese_name = :name OR english_name = :name', name: name).select(:id)) if name
  }

  scope :by_empoid, -> (empoid) {
    where(:users => {empoid: empoid}) if empoid
  }

  scope :by_department, -> (department) {
    where(:users => {department_id: department }) if department
  }

  scope :by_position, -> (position) {
    where(:users => {position_id: position}) if position
  }

  scope :by_grade, -> (grade) {
    where(:users => {grade: grade}) if grade
  }

  scope :by_division_of_job, ->(division_of_job) {
    if division_of_job && (division_of_job.is_a? Array)
      includes(user: :profile).where("profiles.data -> 'position_information' -> 'field_values' -> 'division_of_job' ?| array["+ division_of_job.map {|item| "'#{item}'"}.join(',') +"]")
    elsif division_of_job
      includes(user: :profile).where("profiles.data #>> '{position_information, field_values, division_of_job}' = :division_of_job", division_of_job: division_of_job)
    end
  }

  scope :by_employment_status, -> (employment_status) {
    where(:users => { employment_status: employment_status }) if employment_status
  }

  scope :by_owned_days_count, -> (owned_days_count) {
    where(owned_days_count: owned_days_count) if owned_days_count
  }

  scope :by_taken_days_count, -> (taken_days_count) {
    where(taken_days_count: taken_days_count) if taken_days_count
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

  scope :order_by, -> (sort_column, sort_direction) {
    if sort_column == :empoid
      order("users.empoid #{sort_direction}")
    elsif sort_column == :reserved_holiday_setting
      order("reserved_holiday_settings.chinese_name #{sort_direction}")
    elsif sort_column == :name
      order("users.chinese_name #{sort_direction}")
    elsif sort_column == :position
      order("users.position_id #{sort_direction}")
    elsif sort_column == :department
      order("users.department_id #{sort_direction}")
    elsif sort_column == :grade
      order("users.grade #{sort_direction}")
    elsif sort_column == :date_of_employment
      if sort_direction == :desc
        order("profiles.data #>> '{position_information, field_values, date_of_employment}' DESC")
      else
        order("profiles.data #>> '{position_information, field_values, date_of_employment}' ")
      end
    elsif sort_column == :employment_status
      order("users.employment_status #{sort_direction}")
    else
      order(sort_column => sort_direction)
    end
  }

end
