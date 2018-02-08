class AddInputDateToOvertimeRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :overtime_records, :input_date, :date
    add_column :overtime_records, :input_time, :string
  end
end
