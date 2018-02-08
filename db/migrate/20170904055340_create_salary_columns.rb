class CreateSalaryColumns < ActiveRecord::Migration[5.0]
  def change
    create_table :salary_columns do |t|
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name
      t.string :column_type
      t.string :function
      t.string :add_deduct_type
      t.string :tax_type
      t.string :value_type
      t.string :category
      t.timestamps
    end
  end
end
