class CreateEmployeeGeneralHolidayPreferences < ActiveRecord::Migration[5.0]
  def change
    create_table :employee_general_holiday_preferences do |t|

      t.integer :user_id
      t.integer :employee_preference_id
      t.string :date_range
      t.date :start_date
      t.date :end_date
      t.integer :day_group, array: true, default: []

      t.timestamps
    end
  end
end
