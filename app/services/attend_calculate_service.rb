# coding: utf-8
class AttendCalculateService
  class << self
    def cal_original_work_time(attend)
      roster_object = attend.roster_object
      att_date = attend.attend_date
      original_work_time = nil
      original_work_hours = nil
      holiday_type = nil
      class_work_time = get_original_work_time(attend)
      class_begin = class_work_time[:from]
      class_end = class_work_time[:to]
      if roster_object
        original_work_time = "#{'次日' if class_begin.day > att_date.day}#{class_begin.strftime('%H%M')}-#{'次日' if class_end.day > att_date.day}#{class_end.strftime('%H%M')}" rescue nil
        original_work_hours = ((class_begin - class_end) / 1.hour).abs.round(2) rescue nil
        # 公休
        original_work_time = 'general_holiday' if roster_object.is_general_holiday
        original_work_hours = nil if roster_object.is_general_holiday
        # 假期
        if attend.attend_states.where(record_type: 'holiday_record').count > 0
          original_work_time = 'holiday'
          original_work_hours = nil
          holiday_type = HolidayRecord.holiday_type_table.select { |op| op[:key] == roster_object.holiday_type }.first
        end
      end
      { original_work_time: original_work_time, original_work_hours: original_work_hours, holiday_type: holiday_type }
    end

    def cal_real_work_time_and_hours(attend, signcard_on, signcard_off, signcard_on_is_next, signcard_off_is_next, is_holiday)
      attend_date = attend.attend_date
      states = attend.attend_states
      class_work_time = get_original_work_time(attend)
      class_begin = class_work_time[:from]
      class_end = class_work_time[:to]
      real_work_time = nil
      real_work_hours = nil
      # return { real_work_time: nil, real_work_hours: nil } if is_holiday
      overtime_state = states.where(record_type: 'overtime_record').first
      ot_from = nil
      ot_end = nil
      # # 有加班
      if overtime_state
        overtime_record = OvertimeRecord.find(overtime_state.record_id)
        time_range = get_overtime_time_range_and_hours(overtime_record)
        ot_from = time_range[:from]
        ot_end = time_range[:to]
        # ot_t = "#{'次日' if ot_from.day > attend_date.day}#{ot_from.strftime('%H%M')}-#{'次日' if ot_end.day > attend_date.day}#{ot_end.strftime('%H%M')}" rescue nil
        # ot_h = ((ot_from - ot_end) / 1.hour).abs.round(2) rescue nil
        # res_t = "#{real_work_time if real_work_time}#{ot_t if ot_t}"
        # return { :real_work_time => res_t, :real_work_hours => [ot_h, real_work_hours].compact.sum, :color_type => 'overtime' }
      end
      return {
          real_work_time: ("#{'次日' if ot_from.day > attend_date.day}#{ot_from.strftime('%H%M')}-#{'次日' if ot_end.day > attend_date.day}#{ot_end.strftime('%H%M')}" rescue nil),
          real_work_hours: (((ot_from - ot_end) / 1.hour).abs.round(2) rescue nil)
      } if is_holiday
      # 实际上班时间 实际下班时间
      off_work_time = attend.off_work_time rescue nil
      on_work_time = attend.on_work_time rescue nil
      signcard_off_work_time = Time.zone.parse(signcard_off)
                                   .change(year: attend_date.year, month: attend_date.month, day: attend_date.day) rescue nil
      signcard_on_work_time = Time.zone.parse(signcard_on)
                                  .change(year: attend_date.year, month: attend_date.month, day: attend_date.day) rescue nil
      signcard_off_work_time = (signcard_off_work_time.change(day: attend_date.day + 1) rescue nil) if signcard_off_is_next
      signcard_on_work_time = (signcard_on_work_time.change(day: attend_date.day + 1) rescue nil) if signcard_on_is_next
      on_work_time = signcard_on_work_time if signcard_on_work_time
      off_work_time = signcard_off_work_time if signcard_off_work_time
      _begin = [on_work_time, class_begin].compact.max if on_work_time
      _end = [off_work_time, class_end].compact.min if off_work_time
      # 不存在原定工作时间
      _begin = _end = nil unless class_begin && class_end
      # _begin = [signcard_on_work_time, _begin].compact.max if signcard_on_work_time
      # _end = [signcard_off_work_time, _end].compact.min if signcard_off_work_time

      # if _begin && _end
      #   next_on = _begin.day > attend_date.day rescue false
      #   next_off = _end.day > attend_date.day rescue false
      #   real_work_time = "#{'次日' if next_on}#{_begin.strftime('%H%M')}-#{'次日' if next_off}#{_end.strftime('%H%M')}"
      #   real_work_hours = ((_end - _begin) / 1.hour).abs.round(2)
      #   # real_work_time = nil if _end > _begin
      #   # real_work_hours = nil if _end > _begin
      # end
      # 结束时间大雨开始时间
      _begin = _end = nil if (_begin > _end rescue true)
      result = compact_time_range(attend_date, _begin, _end, ot_from, ot_end)
      { real_work_time: result[:time], real_work_hours: result[:hours] }
    end



    private
    def get_overtime_time_range_and_hours(overtime_record)
      from_d = Time.zone.parse(overtime_record.overtime_true_start_date.to_s)
      to_d = Time.zone.parse(overtime_record.overtime_end_date.to_s)
      from_t = Time.zone.parse(overtime_record.overtime_start_time.to_s)
      to_t = Time.zone.parse(overtime_record.overtime_end_time.to_s)
      _from = Time.zone.local(from_d.year, from_d.month, from_d.day, from_t.hour, from_t.min, from_t.sec)
      _to = Time.zone.local(to_d.year, to_d.month, to_d.day, to_t.hour, to_t.min, to_t.sec)
      # real_work_time = "#{_from.strftime('%H%M')}-#{_to.strftime('%H%M')}"
      # real_work_hours = ((_to.to_time - _from.to_time) / 1.hour).abs.round(2)
      # return { :range => real_work_time, :hours => real_work_hours }
      { from: _from, to: _to }
    end

    def get_original_work_time(attend)
      roster_object = attend.roster_object
      att_date = attend.attend_date
      _start_time = nil
      _end_time = nil
      if roster_object
        # 公休
        return { from: _start_time, to: _end_time } if roster_object.is_general_holiday
        # 排班
        if roster_object.class_setting_id
          class_setting = roster_object.class_setting
          _start_time = class_setting.start_time.change(year: att_date.year, month: att_date.month, day: att_date.day)
          _end_time = class_setting.end_time.change(year: att_date.year, month: att_date.month, day: att_date.day)
          _start_time = _start_time.change(day: att_date.day + 1) if class_setting.is_next_of_start
          _end_time = _end_time.change(day: att_date.day + 1) if class_setting.is_next_of_end
          # _end_time = _end_time.change(day: att_date.day + 2) if (class_setting.is_next_of_start && class_setting.is_next_of_end)
        end
        # 手动输入的时间
        if roster_object.working_time
          begin_day = 0
          end_day = 0
          begin_hour = 0
          begin_min = 0
          end_hour = 0
          end_min = 0
          times = roster_object.working_time.split('-')
          times.each_with_index do |t, index|
            hms = t.split(':')
            hour = hms[0].to_i
            min = hms[1].to_i
            # hour -= 24 if hour > 23
            if index == 0
              begin_day += 1 if hour > 23
              begin_hour = hour
              begin_hour -= 24 if begin_hour > 23
              begin_min = min
            else
              end_day += 1 if hour > 23
              end_hour = hour
              end_hour -= 24 if end_hour > 23
              end_min = min
            end
          end
          _start_time = Time.zone.local(att_date.year, att_date.month, att_date.day + begin_day, begin_hour, begin_min, 0)
          _end_time = Time.zone.local(att_date.year, att_date.month, att_date.day + end_day, end_hour, end_min, 0)
        end
      end
      { from: _start_time, to: _end_time }
    end

    def compact_time_range(attend_date, c_from, c_to, ot_from, ot_end)
      time = nil
      hours = nil
      if ot_from && ot_end
        time = "#{'次日' if ot_from.day > attend_date.day}#{ot_from.strftime('%H%M')}-#{'次日' if ot_end.day > attend_date.day}#{ot_end.strftime('%H%M')}"
        hours = (((ot_from - ot_end) / 1.minute).abs / 60).round(1)
      end
      # 不存在实际工作时间只计算加班时间
      unless c_from && c_to
        return { time: time, hours: hours }
      end
      if ot_from && ot_end
        if ot_end < c_from
          # 加班在工作时间之前
          work_t = "#{'次日' if c_from.day > attend_date.day}#{c_from.strftime('%H%M')}-#{'次日' if c_to.day > attend_date.day}#{c_to.strftime('%H%M')}"
          work_h = (((c_from - c_to) / 1.minute).abs / 60).round(1)
          return { time: time + ' ' + work_t, hours: hours + work_h }
        elsif ot_from > c_to
          # 加班在工作时间之后
          work_t = "#{'次日' if c_from.day > attend_date.day}#{c_from.strftime('%H%M')}-#{'次日' if c_to.day > attend_date.day}#{c_to.strftime('%H%M')}"
          work_h = (((c_from - c_to) / 1.minute).abs / 60).round(1)
          return { time: work_t + ' ' + time, hours: hours + work_h }
        else
          # 加班于上班有重合
          _begin = [c_from, ot_from].compact.min
          _end = [c_to, ot_end].compact.max
          t = "#{'次日' if _begin.day > attend_date.day}#{_begin.strftime('%H%M')}-#{'次日' if _end.day > attend_date.day}#{_end.strftime('%H%M')}"
          h = (((_begin - _end) / 1.minute).abs / 60).round(1)
          return { time: t, hours: h }
        end
      end
      {
          time: "#{'次日' if c_from.day > attend_date.day}#{c_from.strftime('%H%M')}-#{'次日' if c_to.day > attend_date.day}#{c_to.strftime('%H%M')}",
          hours: (((c_from - c_to) / 1.minute).abs / 60).round(1)
      }
    end

  end
end
