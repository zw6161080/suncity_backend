class RevisionHistorySerializer < ActiveModel::Serializer
  attributes *RevisionHistory.column_names

  belongs_to :user

end
