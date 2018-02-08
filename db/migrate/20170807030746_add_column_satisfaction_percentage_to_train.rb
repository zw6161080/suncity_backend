class AddColumnSatisfactionPercentageToTrain < ActiveRecord::Migration[5.0]
  def change
    add_column :trains, :satisfaction_percentage, :decimal, precision: 10, scale: 2
  end
end
