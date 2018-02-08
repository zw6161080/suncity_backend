class SpecialScheduleSettingSerializer < ActiveModel::Serializer
  attributes *SpecialScheduleSetting.column_names,
             :schedule_date

  belongs_to :user
  belongs_to :target_location
  belongs_to :target_department

  def schedule_date
    "#{object.date_begin.strftime('%Y/%m/%d')}~#{object.date_end.strftime('%Y/%m/%d')}"
  end
end

