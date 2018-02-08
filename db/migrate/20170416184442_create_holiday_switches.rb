class CreateHolidaySwitches < ActiveRecord::Migration[5.0]
  def change
    create_table :holiday_switches do |t|
      t.references :user
      t.references :user_b
      t.integer :type
      t.integer :creator_id
      t.integer :status, null: false, default: 1
      t.text :comment

      t.timestamps
    end
  end
end
