class ChangeColumnToTrain < ActiveRecord::Migration[5.0]
  def change
    add_column :trains, :by_invited, :integer, array: true, default: []
  end
end
