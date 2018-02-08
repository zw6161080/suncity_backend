class ChangeColumnToTrainTemplates < ActiveRecord::Migration[5.0]
  def change
    rename_column :train_templates, :attendance_scores_percentage, :test_scores_percentage
  end
end
