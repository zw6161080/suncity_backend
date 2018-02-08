class CreateClassPeoplePreferences < ActiveRecord::Migration[5.0]
  def change
    create_table :class_people_preferences do |t|

      t.integer :roster_preference_id
      t.integer :class_setting_id

      t.integer :max_of_total
      t.integer :min_of_total
      t.integer :max_of_manager_level
      t.integer :min_of_manager_level
      t.integer :max_of_director_level
      t.integer :min_of_director_level

      t.timestamps
    end
  end
end
