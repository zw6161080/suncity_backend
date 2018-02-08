class CreateAttendanceStates < ActiveRecord::Migration[5.0]
  def change
    create_table :attendance_states do |t|
      t.string :code
      t.string :chinese_name
      t.string :english_name
      t.text :comment
      t.integer :parent_id
      t.timestamps
    end

    add_index :attendance_states, :code
    add_index :attendance_states, :parent_id
  end
end
