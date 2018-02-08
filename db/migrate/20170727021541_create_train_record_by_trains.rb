class CreateTrainRecordByTrains < ActiveRecord::Migration[5.0]
  def change
    create_table :train_record_by_trains do |t|
      t.references :train, foreign_key: true, index: true
      t.integer :final_list_count
      t.integer :entry_list_count
      t.integer :invited_count
      t.decimal :attendance_rate, precision: 10, scale: 2
      t.decimal :passing_rate, precision: 10, scale: 2
      t.decimal :satisfaction_degree, precision: 10, scale: 2

      t.timestamps
    end

    remove_column :trains, :train_number, :integer
    add_column :trains, :train_number, :string
  end
end
