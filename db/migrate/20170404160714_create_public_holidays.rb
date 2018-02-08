class CreatePublicHolidays < ActiveRecord::Migration[5.0]
  def change
    create_table :public_holidays do |t|
      t.string :chinese_name
      t.string :english_name
      t.integer :category
      t.date :start_date
      t.date :end_date
      t.text :comment
      t.timestamps
    end
  end
end
