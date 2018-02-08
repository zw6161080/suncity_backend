class SalaryColumnSerializer < ActiveModel::Serializer
  attributes *SalaryColumn.column_names
end
