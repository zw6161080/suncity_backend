class CreateHolidaySwitchItems < ActiveRecord::Migration[5.0]
  def change
    create_table :holiday_switch_items do |t|
      t.references :holiday_switch, foreign_key: true
      t.integer :type
      t.integer :user_id
      t.integer :user_b_id
      t.date :a_date
      t.date :b_date
      t.string :a_start
      t.string :a_end
      t.string :b_start
      t.string :b_end
      t.integer :status, null: false, default: 1
      t.text :comment
      t.timestamps
    end
  end
end
