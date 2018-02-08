class DismissionSalaryItemSerializer < ActiveModel::Serializer
  attributes *DismissionSalaryItem.column_names
  has_one :user
  has_one :dimission
end
