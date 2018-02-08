class CreateBonusElementMonthAmounts < ActiveRecord::Migration[5.0]
  def change
    create_table :bonus_element_month_amounts do |t|
      t.references :location, foreign_key: true
      t.references :position, foreign_key: true
      t.references :float_salary_month_entry,
                   foreign_key: true,
                   index: {name: 'index_month_bonus_element_amounts_on_float_salary_entry_id'}
      t.references :bonus_element, foreign_key: true
      t.datetime :year_month
      t.decimal :amount, precision: 10, scale: 2
      t.string :key
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name

      t.timestamps
    end
  end
end
