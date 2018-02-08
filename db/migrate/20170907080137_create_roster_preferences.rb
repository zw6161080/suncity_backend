class CreateRosterPreferences < ActiveRecord::Migration[5.0]
  def change
    create_table :roster_preferences do |t|
      t.integer :roster_list_id

      t.integer :location_id
      t.integer :department_id

      t.integer :latest_updater_id

      t.timestamps
    end
  end
end
