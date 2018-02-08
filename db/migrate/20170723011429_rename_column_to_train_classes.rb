class RenameColumnToTrainClasses < ActiveRecord::Migration[5.0]
  def change
    rename_column :train_classes, :begin_time, :time_begin
    rename_column :train_classes, :end_time, :time_end
  end
end
