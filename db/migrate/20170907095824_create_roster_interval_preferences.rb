class CreateRosterIntervalPreferences < ActiveRecord::Migration[5.0]
  def change
    create_table :roster_interval_preferences do |t|
      t.integer :roster_preference_id

      t.integer :position_id
      t.integer :interval_hours

      t.timestamps
    end
  end
end
