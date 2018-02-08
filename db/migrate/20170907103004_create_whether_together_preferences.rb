class CreateWhetherTogetherPreferences < ActiveRecord::Migration[5.0]
  def change
    create_table :whether_together_preferences do |t|

      t.integer :roster_preference_id
      t.string :group_name

      t.integer :group_members, array: true, default: []

      t.string :date_range
      t.date :start_date
      t.date :end_date

      t.text :comment

      t.boolean :is_together

      t.timestamps
    end
  end
end
