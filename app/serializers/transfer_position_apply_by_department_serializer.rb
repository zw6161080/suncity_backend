class TransferPositionApplyByDepartmentSerializer < ActiveModel::Serializer
  attributes *TransferPositionApplyByDepartment.column_names
  belongs_to :user
  has_many :attend_attachments
  has_many :approval_items
  belongs_to :transfer_location
  belongs_to :transfer_department
  belongs_to :transfer_position
  belongs_to :apply_location
  belongs_to :apply_department
  belongs_to :apply_position
  belongs_to :apply_group
  belongs_to :transfer_group
end
