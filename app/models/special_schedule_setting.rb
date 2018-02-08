# == Schema Information
#
# Table name: special_schedule_settings
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  date_begin           :datetime
#  date_end             :datetime
#  comment              :text
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  target_location_id   :integer
#  target_department_id :integer
#
# Indexes
#
#  index_special_schedule_settings_on_target_department_id  (target_department_id)
#  index_special_schedule_settings_on_target_location_id    (target_location_id)
#  index_special_schedule_settings_on_user_id               (user_id)
#
# Foreign Keys
#
#  fk_rails_4a2cf75ee4  (target_location_id => locations.id)
#  fk_rails_50378f24c6  (target_department_id => departments.id)
#  fk_rails_f8e636b64d  (user_id => users.id)
#

class SpecialScheduleSetting < ApplicationRecord

  include StatementAble

  validates :user_id, :date_begin, :date_end, :target_location_id, :target_department_id, presence: true

  belongs_to :user
  belongs_to :target_location, class_name: 'Location', foreign_key: 'target_location_id'
  belongs_to :target_department, class_name: 'Department', foreign_key: 'target_department_id'

  def self.can_create(params)
    # 本体判明
    user = User.find(params[:user_id])
    if user.location_id == params[:target_location_id].to_i
      if user.department_id == params[:target_department_id].to_i
        return false
      end
    end
    # 已有记录判明
    begin_date_unmatch = SpecialScheduleSetting.where(user_id: user.id)
                             .where("date_begin >= :begin", begin: Time.zone.parse(params[:date_begin]).beginning_of_day)
                             .where("date_begin <= :end", end: Time.zone.parse(params[:date_end]).end_of_day)
    end_date_unmatch = SpecialScheduleSetting.where(user_id: user.id)
                           .where("date_end >= :begin", begin: Time.zone.parse(params[:date_begin]).beginning_of_day)
                           .where("date_end <= :end", end: Time.zone.parse(params[:date_end]).end_of_day)
    # result = begin_date_unmatch.or(end_date_unmatch)
    # if result.count != 0
    if (begin_date_unmatch.count != 0) || (end_date_unmatch.count != 0)
      return false
    end
    # 职称信息判明
    # user_id date_begin date_end target_location_id target_department_id
    career_records = CareerRecord
                         .where(user_id: params[:user_id])
                         .where("career_begin >= :date_begin", date_begin: Time.zone.parse(params[:date_begin]).beginning_of_day)
                         .where("career_begin <= :date_end", date_end: Time.zone.parse(params[:date_end]).end_of_day)
    invalid_locations = Location.where(id: career_records.select(:location_id))
    invalid_departments = Department.where(id: career_records.select(:department_id))
    if invalid_locations.include? *Location.where(id:params[:target_location_id])
      if invalid_departments.include? *Department.where(id: params[:target_department_id])
        return false
      end
      return true
    end
    return true
  end

  class << self
    def location_options
      Location.where(id: self.joins(:user).select('users.location_id'))
    end
    def department_options
      Department.where(id: self.joins(:user).select('users.department_id'))
    end

    def position_options
      Position.where(id: self.joins(:user).select('users.position_id'))
      end
    def target_department_options
      Department.where(id: self.select(:target_department_id))
    end

    def target_location_options
      Location.where(id: self.select(:target_location_id))
    end
  end

  scope :by_empoid, -> (empoid) {
    where(:users => { empoid: empoid }) if empoid
  }

  scope :by_name, -> (name) {
    where(user_id: User.where('chinese_name = :name OR english_name = :name', name: name).select(:id))
  }

  scope :by_location, -> (location) {
    where(:users => { location_id: location }) if location
  }

  scope :by_department, -> (department) {
    where(:users => { department_id: department }) if department
  }

  scope :by_position, -> (position) {
    where(:users => { position_id: position }) if position
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

  scope :by_target_location, -> (target_location) {
    where(target_location_id: target_location) if target_location
  }

  scope :by_target_department, -> (target_department) {
    where(target_department_id: target_department) if target_department
  }

  scope :by_schedule_date, -> (schedule_date) {
    from = Time.zone.parse(schedule_date[:begin]).beginning_of_day rescue nil
    to = Time.zone.parse(schedule_date[:end]).end_of_day rescue nil
    if from && to
      where("date_begin >= :from", from: from).where("date_begin <= :to", to: to)
    elsif from
      where("date_begin >= :from", from: from)
    elsif to
      where("date_begin <= :to", to: to)
    end
  }

  scope :order_by, -> (sort_column, sort_direction) {
    case sort_column
      when :empoid              then order("users.empoid #{sort_direction}")
      when :name                then order("users.chinese_name #{sort_direction}")
      when :location            then order("users.location_id #{sort_direction}")
      when :department          then order("users.department_id #{sort_direction}")
      when :position            then order("users.position_id #{sort_direction}")
      when :target_location     then order("target_location_id #{sort_direction}")
      when :target_department   then order("target_department_id #{sort_direction}")
      when :date_of_employment  then if sort_direction == :desc
                                       order("profiles.data #>> '{position_information, field_values, date_of_employment}' DESC")
                                     else
                                       order("profiles.data #>> '{position_information, field_values, date_of_employment}' ")
                                     end
      when :schedule_date       then order("date_begin #{sort_direction}")
      else order(sort_column => sort_direction)
    end
  }

end
