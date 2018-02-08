class CreateEmployeePreferences < ActiveRecord::Migration[5.0]
  def change
    create_table :employee_preferences do |t|
      t.integer :user_id

      t.timestamps
    end
  end
end
