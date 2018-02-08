class SpecialScheduleRemarkSerializer < ActiveModel::Serializer
  attributes *SpecialScheduleRemark.column_names

  belongs_to :user

end
