class AttendanceMonthReportItemSerializer < ActiveModel::Serializer
  attributes *AttendanceMonthReportItem.column_names.map { |name| name.to_sym }

  belongs_to :user
end
