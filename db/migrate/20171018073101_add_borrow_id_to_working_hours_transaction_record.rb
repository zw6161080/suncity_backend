class AddBorrowIdToWorkingHoursTransactionRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :working_hours_transaction_records, :borrow_id, :integer
  end
end
