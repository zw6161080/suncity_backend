class ApprovalItemSerializer < ActiveModel::Serializer
  attributes *ApprovalItem.column_names
  belongs_to :user, serializer: UserWithPAndLAndDSerializer

end
