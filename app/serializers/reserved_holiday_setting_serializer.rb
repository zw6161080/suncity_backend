class ReservedHolidaySettingSerializer < ActiveModel::Serializer
  attributes *ReservedHolidaySetting.column_names,
             :name

  belongs_to :creator

  def name
    {
      chinese_name: object.chinese_name,
      english_name: object.english_name,
      simple_chinese_name: object.simple_chinese_name
    }
  end

end
