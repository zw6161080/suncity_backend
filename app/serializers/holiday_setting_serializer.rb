class HolidaySettingSerializer < ActiveModel::Serializer
  attributes *HolidaySetting.column_names
end

