# coding: utf-8
# == Schema Information
#
# Table name: attendance_items
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  position_id         :integer
#  department_id       :integer
#  attendance_id       :integer
#  shift_id            :integer
#  attendance_date     :datetime
#  start_working_time  :datetime
#  end_working_time    :datetime
#  comment             :text
#  region              :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  states              :string           default("")
#  location_id         :integer
#  updated_states_from :string
#  roster_item_id      :integer
#  plan_start_time     :datetime
#  plan_end_time       :datetime
#  is_modified         :boolean
#  overtime_count      :integer
#  leave_type          :string
#
# Indexes
#
#  index_attendance_items_on_attendance_date  (attendance_date)
#  index_attendance_items_on_attendance_id    (attendance_id)
#  index_attendance_items_on_department_id    (department_id)
#  index_attendance_items_on_location_id      (location_id)
#  index_attendance_items_on_position_id      (position_id)
#  index_attendance_items_on_roster_item_id   (roster_item_id)
#  index_attendance_items_on_shift_id         (shift_id)
#  index_attendance_items_on_user_id          (user_id)
#
# Foreign Keys
#
#  fk_rails_37f11f4b3f  (location_id => locations.id)
#  fk_rails_bd644c4e86  (roster_item_id => roster_items.id)
#

class AttendanceItem < ApplicationRecord
  belongs_to :user
  belongs_to :position
  belongs_to :department
  belongs_to :attendance
  belongs_to :shift

  has_many :attendance_item_logs

  validates :region, presence: true
  validates :user_id, presence: true
  validates :location_id, presence: true
  validates :department_id, presence: true

  scope :by_date, lambda { |year, month|
    if (year && month)
      from_date = Date.new(year.to_i, month.to_i)
      end_date = from_date.end_of_month
      where(attendance_date: from_date .. end_date)
    end
  }


  # scope :by_month, lambda { |month|
  #   where(:month => month) if month
  # }

  # scope :by_year, lambda { |year|
  #   where(:year => year) if year
  # }

  scope :by_location_id, lambda { |location_id|
    where(:location_id => location_id) if location_id
  }

  scope :by_department_id, lambda { |department_id|
    where(:department_id => department_id) if department_id
  }

  scope :by_region, lambda { |region|
    where(:region => region) if region
  }

  scope :by_day, lambda { |day|
    where(attendance_date: day) if day
  }

  scope :by_user, lambda { |user_id|
    where(user_id: user_id) if user_id
  }

  def self.update_working_time(datetime = Time.zone.now.to_datetime)

    logs = RosterEventLog.of_ymd(datetime.year, datetime.month, datetime.day).map(&:attributes).reduce({}) do |coll, log|
      coll[log['nUserID']] = Array(coll[log['nUserID']]).push(log['convertDatetime']) if log['convertDatetime'] && log['nUserID']
      coll
    end
    log_empoids = logs.keys.uniq.map { |empoid| empoid.to_s.rjust(8, '0') }
    user_ids = User.where(empoid: log_empoids).pluck(:id, :empoid).to_h
    start_date = datetime.to_date - 1.day
    end_date = datetime.to_date
    att_items = self.where(attendance_date: start_date .. end_date).where(user_id: user_ids.keys).includes(:shift)

    att_items.each do |att_item|

      user_logs = logs[att_item.user.empoid.to_i]
      shift = att_item.shift

      if (shift && shift.id > 0) || (!shift && att_item.plan_start_time != nil)
        earliest = att_item.plan_start_time - 240.minutes # 最早上班时间
        latest = att_item.plan_end_time + 240.minutes # 最晚下班时间

        # 應上班時間
        should_start = att_item.plan_start_time
        # 應下班時間
        should_end = att_item.plan_end_time
        # 中間
        mid_time = Time.zone.at((should_start.to_i + should_end.to_i) / 2)

        # 應上班時間 + 允許遲到
        # be_late = should_start.advance(minutes: shift.allow_be_late_minute.to_i)
        # 應下班時間 + 允許早退
        # leave_early = should_end.advance(minutes: -shift.allow_leave_early_minute.to_i)

        # fixed
        be_late = shift ? should_start.advance(minutes: att_item.shift.allow_be_late_minute.to_i) : should_start ; # 應上班時間 + 允許遲到
        leave_early = shift ? should_end.advance(minutes: -att_item.shift.allow_leave_early_minute.to_i) : should_end ; # 應下班時間 + 允許早退

        # 曠班
        absent = should_start.advance(minutes: 120)

        if (datetime > mid_time && datetime <= (mid_time + 1.hour)) # 更新時間 大與 中間時間, 並保證不會重複更新, 1.hour 是定時任務時間
          punching_card_records = user_logs.select { |log| log >= earliest && log <= mid_time }

          if punching_card_records.count == 0
            att_item.add_state('上班打卡異常', 'auto_generate')
          else
            swt = punching_card_records.sort.first # 最早的時間為上班時間
            att_item.start_working_time = swt

            if swt > be_late && swt < mid_time
              att_item.add_state('遲到', 'auto_generate')
            end

            if swt > absent && swt < mid_time
              att_item.add_state('曠班', 'auto_generate')
            end
          end
        end

        if (datetime > latest && datetime <= (latest + 1.hour)) # 可調整時間, 保證不會重複更新, 1.hour 是定時任務時間
          punching_card_records = user_logs.select { |log| log > mid_time && log <= latest }

          if punching_card_records.count == 0
            att_item.add_state('下班打卡異常', 'auto_generate')
          else
            pcr = punching_card_records.select { |log| log >= should_end && log <= latest }

            # 最早時間為下班時間
            ewt = pcr.count > 0 ? pcr.sort.first : punching_card_records.select { |log| log >= mid_time && log <= should_end }.sort.first
            att_item.end_working_time = ewt

            if ewt > mid_time && ewt < leave_early
              att_item.add_state('早退', 'auto_generate')
            end
          end
        end

        att_item.save!
      end
    end
  end

  def add_state(new_state, source)
    ss = self.states == nil ? '' : self.states
    new_states =
      case source
      when 'auto_generate'
        deal_with_auto_generate_type(ss, new_state)
      when 'modify_item'
        deal_with_modify_item_type(ss, new_state)
      when 'create_record'
        deal_with_create_record_type(ss, new_state)
      else
        ss
      end

    true_source = source == 'modify_item' || source == 'create_record' || updated_states_from == nil ?
                    source : updated_states_from

    self.update(states: new_states, updated_states_from: true_source)
  end

  def deal_with_create_record_type(states, new_state)
    if states == ""
      new_state
    else
      n_state = states.end_with?('@', '|') ? " #{new_state}" : ", #{new_state}"
      states + n_state
    end
  end

  def deal_with_auto_generate_type(states, new_state)
    deal_with_type(states, new_state, '@', '|')
  end

  def deal_with_modify_item_type(states, new_state)
    deal_with_type(states, new_state, '|', '@')
  end

  def deal_with_type(states, new_state, add_sep, rm_sep)
    if states == ""
      "#{new_state}#{add_sep}"
    elsif states.index(rm_sep) # for "type(rm_sep) type" or "type(rm_sep)"
      "#{new_state}#{add_sep}#{states.split(rm_sep)[1..-1].last}"
    elsif states.index(add_sep) # for "type(add_sep) type" or "type(add_sep)"
      states_array = states.split(add_sep)
      "#{states_array.first}, #{new_state}#{add_sep}#{states_array.second}"
    else
      states
    end
  end

  def format_states
    if states
      tmp_states = states.gsub(/[@|]/, ',')
      tmp_states.end_with?(',') ? tmp_states.split(',').join(',') : tmp_states
    else
      ""
    end
  end

  def duration
    ewt = self.try(:end_working_time).to_i
    swt = self.try(:start_working_time).to_i
    if ewt > 0 && swt > 0
      gap_sec = ewt - swt
      h = gap_sec / 3600
      m = gap_sec % 3600 / 60
      "#{h}h#{m}m"
    else
      "0"
    end
  end
end
