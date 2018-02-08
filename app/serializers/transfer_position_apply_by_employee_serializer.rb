class TransferPositionApplyByEmployeeSerializer < ActiveModel::Serializer
  attributes *TransferPositionApplyByEmployee.column_names
  belongs_to :user
  has_many :attend_attachments
  has_many :approval_items
  has_many :training_courses
  belongs_to :transfer_location
  belongs_to :transfer_department
  belongs_to :transfer_position
  belongs_to :transfer_group
  belongs_to :apply_location
  belongs_to :apply_department
  belongs_to :apply_position
  belongs_to :apply_group

end
