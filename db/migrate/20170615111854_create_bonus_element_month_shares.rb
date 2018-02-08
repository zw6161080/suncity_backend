class CreateBonusElementMonthShares < ActiveRecord::Migration[5.0]
  def change
    create_table :bonus_element_month_shares do |t|
      t.references :location, foreign_key: true
      t.references :position, foreign_key: true
      t.references :float_salary_month_entry, foreign_key: true
      t.references :bonus_element, foreign_key: true
      t.datetime :year_month
      t.decimal :shares, precision: 10, scale: 2
      t.string :key
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name

      t.timestamps
    end
  end
end
