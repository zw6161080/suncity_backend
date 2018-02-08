class CreateSalaryElements < ActiveRecord::Migration[5.0]
  def change
    create_table :salary_elements do |t|
      t.string :chinese_name
      t.string :english_name
      t.string :simple_chinese_name
      t.string :key
      t.references :salary_element_category, foreign_key: true
      t.string :display_template
      t.string :comment

      t.timestamps
    end
  end
end
