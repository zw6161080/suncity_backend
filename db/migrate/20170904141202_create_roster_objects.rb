class CreateRosterObjects < ActiveRecord::Migration[5.0]
  def change
    create_table :roster_objects do |t|
      t.string :region
      t.integer :user_id
      t.integer :location_id
      t.integer :department_id
      t.date :roster_date
      t.integer :roster_list_id
      t.integer :class_setting_id
      t.boolean :is_general_holiday

      t.timestamps
    end
  end
end
