class AddRosterPreferenceIdToEmployeePreference < ActiveRecord::Migration[5.0]
  def change
    add_column :employee_preferences, :roster_preference_id, :integer
  end
end
