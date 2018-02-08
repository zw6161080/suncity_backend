class AddSourceIdToWorkingHoursTransactionRecord < ActiveRecord::Migration[5.0]
  def change
    add_column :working_hours_transaction_records, :source_id, :integer
  end
end
