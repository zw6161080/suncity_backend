class AddColumnToSalaryColumnTemplates < ActiveRecord::Migration[5.0]
  def change
    add_column :salary_column_templates, :original_column_order, :integer , default: [] , array: true
  end
end
