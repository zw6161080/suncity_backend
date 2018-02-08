class AddColumnToTrainingPaper < ActiveRecord::Migration[5.0]
  def change
    add_column :training_papers, :train_id, :integer
  end
end
