class AnnualAwardReportSerializer < ActiveModel::Serializer
  attributes *AnnualAwardReport.column_names
end
