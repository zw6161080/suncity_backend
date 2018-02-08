class ReservedHolidayParticipatorSerializer < ActiveModel::Serializer
  attributes *ReservedHolidayParticipator.column_names

  belongs_to :reserved_holiday_setting
  belongs_to :user
end
