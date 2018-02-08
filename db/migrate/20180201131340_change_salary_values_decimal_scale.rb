class ChangeSalaryValuesDecimalScale < ActiveRecord::Migration[5.0]
  def change
    remove_column :salary_values, :decimal_value, :decimal, precision: 30, scale: 2
    add_column :salary_values, :decimal_value, :decimal, precision: 30, scale: 4
  end
end
