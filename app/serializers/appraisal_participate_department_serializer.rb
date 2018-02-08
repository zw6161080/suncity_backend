class AppraisalParticipateDepartmentSerializer < ActiveModel::Serializer
  attributes *AppraisalParticipateDepartment.column_names

  belongs_to :location
  belongs_to :department
end
