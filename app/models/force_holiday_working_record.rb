# == Schema Information
#
# Table name: force_holiday_working_records
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  holiday_setting_id :integer
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  attend_id          :integer
#
# Indexes
#
#  index_force_holiday_working_records_on_attend_id           (attend_id)
#  index_force_holiday_working_records_on_holiday_setting_id  (holiday_setting_id)
#  index_force_holiday_working_records_on_user_id             (user_id)
#
# Foreign Keys
#
#  fk_rails_d2d8f61a6a  (user_id => users.id)
#  fk_rails_f0b964457b  (holiday_setting_id => holiday_settings.id)
#  fk_rails_fe2f5b874f  (attend_id => attends.id)
#

class ForceHolidayWorkingRecord < ApplicationRecord

  include StatementAble

  belongs_to :user
  belongs_to :holiday_setting
  belongs_to :attend

  def self.load_force_holiday_date_and_user
    HolidaySetting.where(category: 'force_holiday').each do |holiday|
      attends = Attend.all.joins(:roster_object => :class_setting)
                    .where(attend_date: holiday.holiday_date)
                    .where.not(roster_object_id: nil)
                    .where.not(:roster_objects => { class_setting_id: nil })
      attends.each do |attend|
        ForceHolidayWorkingRecord.find_or_create_by(
            user_id: attend.user_id,
            holiday_setting_id: holiday.id,
            attend_id: attend.id
        )
      end
    end
  end

  class << self
    def joined_query(param_id = nil)
      query = self.left_outer_joins(
          [
              {
                  user: [:department, :location, :position, :profile]
              },
              :holiday_setting,
              {
                  attend: [:roster_object]
              }
          ].concat(extra_joined_association_names)
      )
      query.where('holiday_settings.holiday_date < ?', Time.zone.now)
          .where.not(:attends => { roster_object_id: nil })
          .where.not(:roster_objects => { class_setting_id: nil })
    end
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
      when :force_holiday_working_date  then order("holiday_settings.holiday_date #{sort_direction}")
    end
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

  scope :by_date_of_employment, -> (date_of_employment) {
    from = Time.zone.parse(date_of_employment[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(date_of_employment[:end]).end_of_day rescue nil
    if from && to
      where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
      where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    elsif from
      where("profiles.data #>> '{position_information, field_values, date_of_employment}' >= :from", from: from)
    elsif to
      where("profiles.data #>> '{position_information, field_values, date_of_employment}' <= :to", to: to)
    end
  }

  scope :by_force_holiday_working_date, -> (force_holiday_working_date) {
      from = Time.zone.parse(force_holiday_working_date[:begin]).beginning_of_day rescue nil
      to = Time.zone.parse(force_holiday_working_date[:end]).end_of_day rescue nil
      if from && to
        where("holiday_settings.holiday_date >= :from", from: from).where("holiday_settings.holiday_date <= :to", to: to)
      elsif from
        where("holiday_settings.holiday_date >= :from", from: from)
      elsif to
        where("holiday_settings.holiday_date <= :to", to: to)
      end
  }

  scope :by_user_id, -> (user_id) {
    where(user_id: user_id) if user_id
  }

  scope :by_name, -> (name) {
    where(user_id: User.where('chinese_name = :name OR english_name = :name', name: name).select(:id))
  }

  scope :by_empoid, -> (empoid) {
    where(:users => { empoid: empoid })
  }

end
