class ChangeYearMonthTypeForAttendanceMonthReportItem < ActiveRecord::Migration[5.0]
  def up
    change_column :attendance_month_report_items, :year_month, :datetime
    add_column :report_columns, :value_format, :string
  end

  def down
    change_column :attendance_month_report_items, :year_month, :date
    remove_column :report_columns, :value_format, :string
  end
end
