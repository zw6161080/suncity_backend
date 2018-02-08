class CreateClassesBetweenGeneralHolidayPreferences < ActiveRecord::Migration[5.0]
  def change
    create_table :classes_between_general_holiday_preferences do |t|
      t.integer :roster_preference_id

      t.integer :position_id
      t.integer :max_classes_count

      t.timestamps
    end
  end
end
