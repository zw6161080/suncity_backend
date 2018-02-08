class AddOvertimeTrueStartDateToOvertimeRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :overtime_records, :overtime_true_start_date, :date
  end
end
