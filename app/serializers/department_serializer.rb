class DepartmentSerializer < ActiveModel::Serializer
  attributes *Department.column_names
end