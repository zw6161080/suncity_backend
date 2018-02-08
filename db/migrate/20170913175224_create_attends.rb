class CreateAttends < ActiveRecord::Migration[5.0]
  def change
    create_table :attends do |t|
      t.string :region
      t.integer :user_id

      t.date :attend_date
      t.integer :attend_weekday

      t.integer :roster_object_id

      t.datetime :on_work_time
      t.datetime :off_work_time

      t.timestamps
    end
  end
end
