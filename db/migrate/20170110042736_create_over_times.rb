class CreateOverTimes < ActiveRecord::Migration[5.0]
  def change
    create_table :over_times do |t|
      t.date :date
      t.integer :user_id
      t.integer :creator_id
      t.integer :status, null: false, default: 1
      t.integer :item_count
      t.text :comment

      t.timestamps
    end
  end
end
