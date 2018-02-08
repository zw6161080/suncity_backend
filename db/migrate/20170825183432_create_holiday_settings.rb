class CreateHolidaySettings < ActiveRecord::Migration[5.0]
  def change
    create_table :holiday_settings do |t|
      t.string :region
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name
      t.integer :category
      t.date :holiday_date
      t.text :comment

      t.timestamps
    end
  end
end
