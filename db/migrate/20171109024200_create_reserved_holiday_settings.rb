class CreateReservedHolidaySettings < ActiveRecord::Migration[5.0]
  def change
    create_table :reserved_holiday_settings do |t|
      t.boolean :can_destroy
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name
      t.datetime :date_begin
      t.datetime :date_end
      t.integer :days_count
      t.integer :member_count
      t.text :comment
      t.timestamps
    end

    add_reference :reserved_holiday_settings, :creator, index: true
    add_foreign_key :reserved_holiday_settings, :users, column: :creator_id
  end
end