class CreateSalaryColumnTemplates < ActiveRecord::Migration[5.0]
  def change
    create_table :salary_column_templates do |t|
      t.string :name
      t.integer :column_array, array: true, default: []
      t.timestamps
    end
  end
end
