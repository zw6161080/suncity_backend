# coding: utf-8
# == Schema Information
#
# Table name: roster_items
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  shift_id    :integer
#  roster_id   :integer
#  date        :date
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  leave_type  :string
#  start_time  :datetime
#  end_time    :datetime
#  state       :integer          default("default")
#  is_modified :boolean
#  uneditable  :boolean
#
# Indexes
#
#  index_roster_items_on_roster_id  (roster_id)
#  index_roster_items_on_shift_id   (shift_id)
#  index_roster_items_on_user_id    (user_id)
#

class RosterItem < ApplicationRecord
  #用户
  belongs_to :user
  #班次
  belongs_to :shift
  #排班表
  belongs_to :roster

  has_many :roster_item_logs

  # after_save :create_roster_item_log
  after_save :sync_to_attendance_item
  before_save :set_from_shift_time
  validate :right_state

  enum state: {default: 0, holiday: 1, fixed: 2}

  scope :by_user, lambda { |user|
    where(user: user) if user
  }

  scope :by_date, lambda { |date|
    where(date: date) if date
  }

  scope :by_week, lambda { |day|
    if day
      tmp_day = day.split('-').map(&:to_i)
      format_day = Date.new(tmp_day[0], tmp_day[1], tmp_day[2])
      where(date: format_day.beginning_of_week .. format_day.end_of_week)
    end
  }

  scope :by_year_and_month, lambda { |year_and_month|
    if year_and_month
      tmp_day = year_and_month.split('/').map(&:to_i)
      format_day = Date.new(tmp_day[0], tmp_day[1])
      where(date: format_day.beginning_of_month .. format_day.end_of_month)
    end
  }

  def leave=(leave)
    self.leave_type = leave[:key]
  end

  def leave
    if self.leave_type
      Leave.find(self.leave_type)
    end
  end

  def update_shift!(update_shift_id)
    self.leave_type = nil
    self.state = :default
    self.shift_id = update_shift_id
    self.save!
  end

  def update_leave!(update_leave_type)
    self.shift_id = nil
    self.state = :holiday
    self.leave_type = update_leave_type
    self.save!
  end

  # def create_roster_item_log
  #   roster_item_log = RosterItemLog.new
  #   roster_item_log.roster_item_id = self.id
  #   roster_item_log.user_id = self.user_id
  #   roster_item_log.log_time = self.updated_at
  #   roster_item_log.log_type = 'update_roster'
  #   roster_item_log.log_type_id = self.id
  #   roster_item_log.save
  # end

  def sync_to_attendance_item
    if self.shift_id.to_i > 0
      att_item = AttendanceItem.find_or_create_by(roster_item_id: self.id)
      att_item.user = self.user
      att_item.position = self.user.position
      att_item.department = self.user.department
      att_item.shift_id = self.shift_id

      time_arr = self.class.caculate_time(self.date, self.shift.start_time, self.shift.end_time)

      att_item.plan_start_time = time_arr[:start_time]
      att_item.plan_end_time = time_arr[:end_time]
      att_item.attendance_date = self.date

      att_item.region = self.roster.region
      att_item.location_id = self.roster.location_id

      att_item.save

    elsif self.shift_id.to_i == 0
      #固定班
      if self.state.to_sym == :fixed
        att_item = AttendanceItem.find_or_create_by(roster_item_id: self.id)
        att_item.user = self.user
        att_item.position = self.user.position
        att_item.department = self.user.department
        att_item.shift_id = self.shift_id

        att_item.plan_start_time = self.date.saturday? || self.date.sunday? ? nil : self.start_time
        att_item.plan_end_time = self.date.saturday? || self.date.sunday? ? nil : self.end_time
        # att_item.plan_end_time = self.end_time
        att_item.attendance_date = self.date

        att_item.region = self.roster.region
        att_item.location_id = self.roster.location_id

        att_item.save

      # 重新排班后删除休息
      elsif self.state.to_sym == :holiday
        att_item = AttendanceItem.find_or_create_by(roster_item_id: self.id)
        att_item.user = self.user
        att_item.position = self.user.position
        att_item.department = self.user.department
        att_item.shift_id = self.shift_id
        att_item.attendance_date = self.date
        att_item.region = self.roster.region
        att_item.location_id = self.roster.location_id
        att_item.leave_type = self.leave_type

        att_item.plan_start_time = nil
        att_item.plan_end_time = nil

        att_item.save
        # att_item.delete if att_item
      else
        att_item = AttendanceItem.find_or_create_by(roster_item_id: self.id)
        att_item.user = self.user
        att_item.position = self.user.position
        att_item.department = self.user.department
        att_item.shift_id = -1

        att_item.attendance_date = self.date

        att_item.region = self.roster.region
        att_item.location_id = self.roster.location_id

        att_item.save
      end

    end
  end

  def self.caculate_time(the_date, start_time_str, end_time_str)
    st = start_time_str.in_time_zone
    sd = the_date

    et = end_time_str.in_time_zone
    ed = st.hour > et.hour ? sd.tomorrow : sd

    ast = Time.zone.local(sd.year, sd.month, sd.day, st.hour, st.min, st.sec).to_datetime
    aet = Time.zone.local(ed.year, ed.month, ed.day, et.hour, et.min, et.sec).to_datetime
    {start_time: ast, end_time: aet}
  end

  def update_from_shift_time
    if self.shift_id.to_i > 0
      self.set_from_shift_time
      self.save
    end
  end

  def set_from_shift_time
    if self.shift_id.to_i > 0
      sd = self.date

      st = self.shift.start_time.in_time_zone
      et = self.shift.end_time.in_time_zone

      ed = st.hour > et.hour ? self.date.tomorrow : self.date

      ast = Time.zone.local(sd.year, sd.month, sd.day, st.hour, st.min, st.sec).to_datetime
      aet = Time.zone.local(ed.year, ed.month, ed.day, et.hour, et.min, et.sec).to_datetime

      self.start_time = ast
      self.end_time = aet
    end
  end

  private
  def right_state
    if self.shift_id.to_i > 0 && ['fixed', 'holiday', '1', '2'].include?(state.to_s)
      errors.add(:state, "state #{self.state.to_s} not valid")
    end
  end

  def vlidate_date
    raise "Wrong date!" unless self.date && self.date <= self.roster.to && self.date >= self.roster.from
  end

end
