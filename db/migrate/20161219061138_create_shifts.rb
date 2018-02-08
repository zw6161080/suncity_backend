class CreateShifts < ActiveRecord::Migration[5.0]
  def change
    create_table :shifts do |t|
      t.string :name
      t.string :start_time
      t.string :end_time
      t.string :time_length
      t.integer :min_workers_number
      t.integer :min_3_leval_workers_number
      t.integer :min_4_leval_workers_number

      t.timestamps
    end
  end
end
