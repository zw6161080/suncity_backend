class CreateAttendLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :attend_logs do |t|
      t.integer :user_id
      t.integer :attend_id
      t.date :log_date
      t.datetime:log_time
      t.integer :logger_id
      t.integer :apply_type

      t.timestamps
    end
  end
end
