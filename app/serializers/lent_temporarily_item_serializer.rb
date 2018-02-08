class LentTemporarilyItemSerializer < ActiveModel::Serializer
  attributes *LentTemporarilyItem.column_names
  belongs_to :user
  belongs_to :lent_location
end
