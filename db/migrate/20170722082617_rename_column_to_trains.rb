class RenameColumnToTrains < ActiveRecord::Migration[5.0]
  def change
    rename_column :trains, :train_begin_date, :train_date_begin
    rename_column :trains, :train_end_date, :train_date_end
    rename_column :trains, :registration_begin_date, :registration_date_begin
    rename_column :trains, :registration_end_date, :registration_date_end
  end
end
