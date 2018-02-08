class RemoveColumnToSalaryColumnTemplates < ActiveRecord::Migration[5.0]
  def change
    remove_column :salary_column_templates, :column_array, :integer, array: true, default: []
  end
end
