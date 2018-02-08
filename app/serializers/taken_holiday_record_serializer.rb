class TakenHolidayRecordSerializer < ActiveModel::Serializer
  attributes *TakenHolidayRecord.column_names,
             :taken_roster_object

  belongs_to :user
  belongs_to :holiday_record
  belongs_to :attend

  def taken_roster_object
    attend = object.attend
    return nil unless attend
    roster_object = attend.roster_object if attend
    return nil unless roster_object
    class_setting = roster_object.class_setting if roster_object
    if class_setting
      _start = class_setting.start_time.strftime('%H%M')
      _end = class_setting.end_time.strftime('%H%M')
      _start_next = class_setting.is_next_of_start
      _end_next = class_setting.is_next_of_end
      return "#{'次日' if _start_next}#{_start}-#{'次日' if _end_next}#{_end}"
    end
  end
end
