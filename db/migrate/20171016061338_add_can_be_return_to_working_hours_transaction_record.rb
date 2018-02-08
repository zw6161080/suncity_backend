class AddCanBeReturnToWorkingHoursTransactionRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :working_hours_transaction_records, :can_be_return, :boolean
  end
end
