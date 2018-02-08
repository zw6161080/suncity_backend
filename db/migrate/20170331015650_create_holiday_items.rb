class CreateHolidayItems < ActiveRecord::Migration[5.0]
  def change
    create_table :holiday_items do |t|
      t.references :holiday, foreign_key: true
      t.integer :creator_id
      t.integer :status
      t.integer :holiday_type
      t.datetime :start_time
      t.datetime :end_time
      t.integer :duration
      t.text :comment
      t.timestamps
    end
  end
end
