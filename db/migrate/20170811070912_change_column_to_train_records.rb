class ChangeColumnToTrainRecords < ActiveRecord::Migration[5.0]
  def change
    remove_column :train_records, :cost, :decimal, precision: 5, scale: 2
    add_column :train_records, :cost, :decimal, precision: 15, scale: 2
  end
end
