class MsrInfoSerializer < ActiveModel::Serializer
  attributes *MonthSalaryReport.column_names
end
