class AlterColumnToSalaryValues < ActiveRecord::Migration[5.0]
  def change
    remove_column :salary_values, :decimal_value, :decimal
    add_column :salary_values, :decimal_value, :decimal, precision: 30, scale: 2

  end
end
