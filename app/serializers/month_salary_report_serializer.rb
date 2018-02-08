class MonthSalaryReportSerializer < ActiveModel::Serializer
  attributes *MonthSalaryReport.column_names
end
