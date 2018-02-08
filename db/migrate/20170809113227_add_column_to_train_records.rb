class AddColumnToTrainRecords < ActiveRecord::Migration[5.0]
  def change
    add_column :train_records, :cost, :decimal, precision: 5, scale: 2
  end
end
