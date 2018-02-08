class AddWorkingHoursTransactionToRosterObjectLog < ActiveRecord::Migration[5.0]
  def change
    add_column :roster_object_logs, :holiday_type, :string
    add_column :roster_object_logs, :borrow_return_type, :string
    add_column :roster_object_logs, :working_hours_transaction_record_id, :integer
  end
end
