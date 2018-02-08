class DepartureEmployeeTaxpayerNumberingReportItemSerializer < ActiveModel::Serializer
  attributes *DepartureEmployeeTaxpayerNumberingReportItem.column_names.map { |name| name.to_sym }
  belongs_to :user
end
