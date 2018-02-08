class CreateAdjustRosterRecords < ActiveRecord::Migration[5.0]
  def change
    create_table :adjust_roster_records do |t|
      t.string :region
      t.integer :user_a_id
      t.integer :user_b_id

      t.date :user_a_adjust_date
      t.integer :user_a_roster_id

      t.date :user_b_adjust_date
      t.integer :user_b_roster_id

      t.integer :apply_type
      t.boolean :is_director_special_approval

      t.boolean :is_deleted

      t.text :comment

      t.timestamps
    end
  end
end
