class AddIsStartNextToWorkingHoursTransactionRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :working_hours_transaction_records, :is_start_next, :boolean, default: false
    add_column :working_hours_transaction_records, :is_end_next, :boolean, default: false
  end
end
