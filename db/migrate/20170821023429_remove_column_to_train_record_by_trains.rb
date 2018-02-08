class RemoveColumnToTrainRecordByTrains < ActiveRecord::Migration[5.0]
  def change
    remove_column :train_record_by_trains, :satisfaction_degree, :string
  end
end
