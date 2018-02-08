class CreateGeneralHolidayIntervalPreferences < ActiveRecord::Migration[5.0]
  def change
    create_table :general_holiday_interval_preferences do |t|
      t.integer :roster_preference_id

      t.integer :position_id
      t.integer :max_interval_days

      t.timestamps
    end
  end
end
