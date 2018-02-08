class TransferLocationItemSerializer < ActiveModel::Serializer
  attributes *TransferLocationItem.column_names
  belongs_to :user, serializer: UserWithPAndLAndDSerializer
  belongs_to :transfer_location


end
