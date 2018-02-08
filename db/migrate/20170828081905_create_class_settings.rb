class CreateClassSettings < ActiveRecord::Migration[5.0]
  def change
    create_table :class_settings do |t|
      t.string :region
      t.integer :department_id

      t.string :name
      t.string :display_name
      t.integer :code

      t.datetime :start_time
      t.datetime :end_time

      t.integer :late_be_allowed
      t.integer :leave_be_allowed

      t.integer :overtime_before_work
      t.integer :overtime_after_work

      t.boolean :be_used
      t.integer :be_used_count, default: 0

      t.timestamps
    end
  end
end
