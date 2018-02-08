class PassEntryTrialRecordsSerializer < ActiveModel::Serializer
  attributes *CareerRecord.column_names

  belongs_to :user
  belongs_to :location
  belongs_to :department
  belongs_to :group

end
