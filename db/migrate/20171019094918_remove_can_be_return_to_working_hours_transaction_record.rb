class RemoveCanBeReturnToWorkingHoursTransactionRecord < ActiveRecord::Migration[5.0]
  def change
    remove_column :working_hours_transaction_records, :can_be_return
    add_column :working_hours_transaction_records, :can_be_return, :boolean, default: true
  end
end
