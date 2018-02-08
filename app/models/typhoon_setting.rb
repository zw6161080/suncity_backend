# == Schema Information
#
# Table name: typhoon_settings
#
#  id             :integer          not null, primary key
#  start_date     :date
#  end_date       :date
#  start_time     :datetime
#  end_time       :datetime
#  qualify_counts :integer
#  apply_counts   :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class TyphoonSetting < ApplicationRecord
  has_many :typhoon_qualified_records

  scope :by_start_date, lambda { |start_date|
    where(start_date: start_date["begin"] .. start_date["end"]) if start_date
  }

  scope :by_end_date, lambda { |end_date|
    where(end_date: end_date["begin"] .. end_date["end"]) if end_date
  }

  scope :by_qualify_counts, lambda { |count|
    where(qualify_counts: count) if count
  }

  scope :by_apply_counts, lambda { |count|
    where(apply_counts: count) if count
  }

  def self.create_typhoon_qualified_records(ts)
    in_date_attends = Attend.where(attend_date: ts.start_date .. ts.end_date)
    # in_date_attend.joins(roster_object: [:class_setting]).where("roster_object.is_general_holiday = ? AND roster_object", false, )

    in_date_attends.each do |att|
      roster_object = att.roster_object_id ? RosterObject.find_by(id: att.roster_object_id) : nil

      if roster_object
        should_create, fmt_start_time, fmt_end_time = TyphoonSetting.check_if_create(roster_object, ts)

        if should_create
          w_hours = "#{fmt_start_time}-#{fmt_end_time}"

          # year, month = "#{att.attend_date.year}".rjust(4, '0'), "#{att.attend_date.month}".rjust(2, '0')
          # fmt_month = "#{year}/#{month}"
          # status = AttendMonthApproval.where(month: fmt_month).first.try(:status)
          # is_compensate = status == 'approval' ? true : false

          ts.typhoon_qualified_records.create(user_id: att.user_id,
                                              is_compensate: nil,
                                              qualify_date: att.attend_date,
                                              is_apply: false,
                                              money: 0,
                                              working_hours: w_hours
                                             )
          ts.qualify_counts = ts&.qualify_counts.to_i + 1
          ts.save
        end
      end
    end
  end

  def self.update_qualified_records_for_roster_object(ro, is_holiday)
    date = ro.roster_date
    if ro.is_general_holiday == true || ro.holiday_type || is_holiday
      TyphoonQualifiedRecord.where(user_id: ro.user_id, qualify_date: date).each do |tq|
        ts = tq.typhoon_setting
        ts.qualify_counts = ts&.qualify_counts.to_i - 1
        ts.save
        tq.destroy
      end
    elsif ro.class_setting_id || ro.working_time
      tss = TyphoonSetting.where("start_date <= ? AND end_date >= ?", date, date)

      tss.each do |ts|

        should_create, fmt_start_time, fmt_end_time = TyphoonSetting.check_if_create(ro, ts)

        if should_create
          w_hours = "#{fmt_start_time}-#{fmt_end_time}"
          exist_record = ts.typhoon_qualified_records.where(user_id: ro.user_id, qualify_date: ro.roster_date).first
          if exist_record
            exist_record.working_hours = w_hours
            exist_record.save
          else
            ts.typhoon_qualified_records.create(user_id: ro.user_id,
                                                is_compensate: nil,
                                                qualify_date: ro.roster_date,
                                                is_apply: false,
                                                money: 0,
                                                working_hours: w_hours
                                               )
            ts.qualify_counts = ts&.qualify_counts.to_i + 1
            ts.save
          end
        end
      end
    end
  end

  def self.check_if_create(ro, ts)
    date = ro.roster_date
    date_of_employment = ro.user.profile.data['position_information']['field_values']['date_of_employment']
    entry = date_of_employment ? date_of_employment.in_time_zone.to_date : nil

    position_resigned_date = ro.user.profile.data['position_information']['field_values']['resigned_date']
    leave = position_resigned_date ? position_resigned_date.in_time_zone.to_date : nil

    is_entry = (entry && (date >= entry))
    not_leave = (leave == nil || (date <= leave))

    should_create = false
    fmt_start_time = nil
    fmt_end_time = nil

    if is_entry && not_leave && ro && (ro.class_setting_id || ro.working_time) && ro.is_general_holiday != true && ro.holiday_type == nil

      tsd = ts.start_date
      tst = ts.start_time
      ts_start_time = Time.zone.local(tsd.year, tsd.month, tsd.day, tst.hour, tst.min).to_datetime

      ted = ts.end_date
      tet = ts.end_time
      ts_end_time = Time.zone.local(ted.year, ted.month, ted.day, tet.hour, tet.min).to_datetime

      if ro.class_setting_id
        cs = ClassSetting.find_by(id: ro.class_setting_id)
        if cs

          d_of_start_time = cs.is_next_of_start ? ro.roster_date + 1.day : ro.roster_date
          start_time = cs.start_time

          cs_start_time = Time.zone.local(d_of_start_time.year, d_of_start_time.month, d_of_start_time.day, start_time.hour, start_time.min).to_datetime

          d_of_end_time = cs.is_next_of_end ? ro.roster_date + 1.day : ro.roster_date
          end_time = cs.end_time

          cs_end_time = Time.zone.local(d_of_end_time.year, d_of_end_time.month, d_of_end_time.day, end_time.hour, end_time.min).to_datetime

          unless ((cs.is_next_of_start == true && cs.is_next_of_end == true) ||
                  ((cs.is_next_of_start != true && cs_start_time > ts_end_time) && cs.is_next_of_end == true) ||
                  ((cs.is_next_of_start != true && cs_start_time > ts_end_time) && (cs.is_next_of_end != true && cs_end_time > ts_end_time)) ||
                  ((cs.is_next_of_start != true && cs_start_time < ts_start_time) && (cs.is_next_of_end != true && cs_end_time < ts_start_time)))

            fmt_start_time = cs_start_time.strftime("%H:%M")
            fmt_end_time = cs_end_time.strftime("%H:%M")
            should_create = true
          end
        end
      elsif ro.working_time
        working_time = ro.working_time
        roster_date = ro.roster_date

        tmp_start_time = working_time.split('-').first
        tmp_end_time = working_time.split('-').last

        tmp_start_hour = tmp_start_time[0, 2].to_i
        true_start_hour = tmp_start_hour % 24
        true_start_date = roster_date + (tmp_start_hour / 24).days

        true_start_min = tmp_start_time[3, 2].to_i

        tmp_end_hour = tmp_end_time[0, 2].to_i
        true_end_hour = tmp_end_hour % 24
        true_end_date = roster_date + (tmp_end_hour / 24).days

        true_end_min = tmp_end_time[3, 2].to_i

        wk_start_time = Time.zone.local(true_start_date.year,
                                        true_start_date.month,
                                        true_start_date.day,
                                        true_start_hour,
                                        true_start_min).to_datetime

        wk_end_time = Time.zone.local(true_end_date.year,
                                      true_end_date.month,
                                      true_end_date.day,
                                      true_end_hour,
                                      true_end_min).to_datetime

        unless ((wk_start_time > ts_end_time && wk_end_time > ts_end_time) ||
                (wk_start_time < ts_start_time && wk_end_time < ts_start_time))

          fmt_start_time = wk_start_time.strftime("%H:%M")
          fmt_end_time = wk_end_time.strftime("%H:%M")
          should_create = true
        end
      end
    end

    [should_create, fmt_start_time, fmt_end_time]
  end
end
