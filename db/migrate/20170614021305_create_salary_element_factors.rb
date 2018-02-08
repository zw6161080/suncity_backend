class CreateSalaryElementFactors < ActiveRecord::Migration[5.0]
  def change
    create_table :salary_element_factors do |t|
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name
      t.string :key
      t.references :salary_element, foreign_key: true
      t.string :factor_type
      t.decimal :numerator, precision: 10, scale: 2
      t.decimal :denominator, precision: 10, scale: 2
      t.decimal :value, precision: 10, scale: 2
      t.string :comment

      t.timestamps
    end
  end
end
