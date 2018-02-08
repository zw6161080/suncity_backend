class AddColumnToSalaryValues2 < ActiveRecord::Migration[5.0]
  def change
    add_column :salary_values, :boolean_value, :boolean
  end
end
