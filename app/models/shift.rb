# == Schema Information
#
# Table name: shifts
#
#  id                       :integer          not null, primary key
#  chinese_name             :string
#  start_time               :string
#  end_time                 :string
#  time_length              :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  roster_id                :integer
#  english_name             :string
#  allow_be_late_minute     :integer
#  allow_leave_early_minute :integer
#  is_next                  :boolean
#
# Indexes
#
#  index_shifts_on_roster_id  (roster_id)
#

class TimeAtValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    begin
      if value.split(':').length == 2
        hour = value.split(':')[0]
        minute = value.split(':')[1]
        regex = /\A\d{2}\z/

        if regex =~ hour and regex =~ minute
          if minute.to_i < 60
            return
          end
        end
      end
    rescue

    end
    record.errors[attribute] << (options[:message] || "is not a time")
  end
end


class Shift < ApplicationRecord
  belongs_to :roster
  validates :start_time, presence: true, time_at: true
  validates :end_time, presence: true, time_at: true

  before_save :fill_time_length

  has_many :shift_employee_count_settings

  def start_time_at
    start_time.split(':')
  end

  def end_time_at
    end_time.split(':')
  end

  def start_hour
    start_time_at.first.to_i
  end

  def start_minute
    start_time_at.last.to_i
  end

  def end_hour
    end_time_at.first.to_i
  end

  def end_minute
    end_time_at.last.to_i
  end

  def positions
    self.roster.department.positions
  end

  private
  def fill_time_length
    hour_diff = end_hour - start_hour
    minutes_diff = end_minute - start_minute

    self.time_length = hour_diff * 60 + minutes_diff
  end
end
