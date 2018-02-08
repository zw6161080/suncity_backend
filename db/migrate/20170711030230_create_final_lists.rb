class CreateFinalLists < ActiveRecord::Migration[5.0]
  def change
    create_table :final_lists do |t|
      t.integer :user_id
      t.integer :working_status
      t.decimal :cost, precision: 15, scale: 2
      t.integer :train_result
      t.decimal :attendance_percentage, precision: 15, scale: 2
      t.decimal :test_score, precision: 15, scale: 2
      t.integer :train_id
      t.integer :entry_list_id
      t.timestamps
    end
  end
end
