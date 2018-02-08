class CreateWorkingHoursTransactionRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :working_hours_transaction_records do |t|
      t.string :region

      t.boolean :is_compensate

      t.integer :user_a_id
      t.integer :user_b_id

      t.integer :apply_type
      t.date :apply_date
      t.datetime :start_time
      t.datetime :end_time
      t.integer :hours_count

      t.boolean :is_deleted

      t.text :comment

      t.integer :creator_id

      t.timestamps
    end
  end
end
