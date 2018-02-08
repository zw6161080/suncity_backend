class CreateRosterObjectLogs < ActiveRecord::Migration[5.0]
  def change
    create_table :roster_object_logs do |t|
      t.string :class_name
      t.string :working_time
      t.integer :modified_reason
      t.integer :approver_id
      t.datetime :approval_time

      t.timestamps
    end
  end
end
