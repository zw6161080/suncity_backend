class ForceHolidayWorkingRecordSerializer < ActiveModel::Serializer
  attributes *ForceHolidayWorkingRecord.column_names,
             :origin_working_range,
             :origin_working_hours

  belongs_to :user
  belongs_to :holiday_setting
  belongs_to :attend

  def origin_working_range
    attend = object.attend
    roster_object = attend.roster_object
    class_setting = roster_object.class_setting if roster_object
    if class_setting
      _start = class_setting.start_time.strftime('%H%M')
      _end = class_setting.end_time.strftime('%H%M')
      _start_next = class_setting.is_next_of_start
      _end_next = class_setting.is_next_of_end
      return "#{'次日' if _start_next}#{_start}-#{'次日' if _end_next}#{_end}"
    end
  end

  def origin_working_hours
    attend = object.attend
    roster_object = attend.roster_object
    class_setting = roster_object.class_setting if roster_object
    if class_setting
      dt_start = class_setting.start_time.change(year: 2000, month: 1, day: 1)
      dt_end = class_setting.end_time.change(year: 2000, month: 1, day: 1)
      dt_start = dt_start.change(day: 2) if class_setting.is_next_of_start
      dt_end = dt_end.change(day: 2) if class_setting.is_next_of_end
      dt_end = dt_end.change(day: 3) if (class_setting.is_next_of_start && class_setting.is_next_of_end)
      return ((dt_end.to_time - dt_start.to_time) / 1.hour).abs.round
    end
  end

end
